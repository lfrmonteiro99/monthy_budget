// probe.mjs — baseline sweep of the whole app. Every tester starts here.
//
// Walks the bottom navigation, and for each tab records: a screenshot, every
// label reachable by scrolling, structural layout suspects, and any console /
// page / network errors triggered along the way. Writes a JSON report plus the
// PNGs, so the tester agent can read the report for structure and LOOK at the
// screenshots to judge appearance.
//
// This is deliberately a survey, not a test suite: it makes no assertions and
// never fails. Its job is to hand the agent an evidence base broad enough to
// decide where to dig, and screenshots concrete enough to justify a finding.
//
// Usage:
//   node probe.mjs --url http://127.0.0.1:7401 --out /tmp/qa-run --viewport phone
//                  [--scheme dark] [--locale en-US] [--tabs home,track]

import { writeFileSync, mkdirSync } from 'node:fs';
import { join } from 'node:path';
import {
  launch, close, shoot, labels, scrollCollect, layoutSuspects,
  metrics, openTab, semantics, TABS, VIEWPORTS,
} from './flutter_driver.mjs';

function arg(name, fallback = undefined) {
  const i = process.argv.indexOf(`--${name}`);
  return i > -1 && process.argv[i + 1] ? process.argv[i + 1] : fallback;
}

const url = arg('url', 'http://127.0.0.1:7401');
const out = arg('out', '/tmp/qa-probe');
const viewportName = arg('viewport', 'phone');
const scheme = arg('scheme', 'light');
const locale = arg('locale', 'pt-PT');
const only = arg('tabs', '')
  .split(',').map((s) => s.trim()).filter(Boolean);

const viewport = VIEWPORTS[viewportName] ?? VIEWPORTS.phone;
mkdirSync(out, { recursive: true });

const report = {
  url,
  viewport: `${viewportName} ${viewport.width}x${viewport.height}`,
  colorScheme: scheme,
  locale,
  bootedIntoApp: false,
  screens: {},
  diagnostics: {},
  metrics: {},
  screenshots: [],
};

let session;
try {
  session = await launch({ url, viewport, colorScheme: scheme, locale });
  const { page, logs } = session;

  report.screenshots.push(await shoot(page, join(out, 'boot.png')));
  const bootLabels = await labels(page);
  report.screens.boot = { labels: bootLabels };

  // The single most important signal in the whole report. QA mode is supposed
  // to land straight in the authenticated shell; if a login form is on screen
  // instead, the build is misconfigured and EVERY other finding in this run is
  // an artefact of that, not a real defect.
  const loginish = /Sign in|Entrar|Password|Palavra-passe|Iniciar sesi/i;
  const appish = /Home|In[íi]cio|Track|Registar|Shop|Compras|More|Mais/i;
  report.bootedIntoApp =
    bootLabels.some((l) => appish.test(l)) && !bootLabels.some((l) => loginish.test(l));

  if (!report.bootedIntoApp) {
    report.diagnostics.bootProblem =
      'The app did not reach the authenticated shell. Treat this as the only ' +
      'finding for this run: a misconfigured QA build invalidates the rest.';
  } else {
    const wanted = only.length ? TABS.filter((t) => only.includes(t.key)) : TABS;
    for (const tab of wanted) {
      const entry = { opened: false };
      try {
        entry.opened = await openTab(page, tab.key);
        if (entry.opened) {
          entry.labels = await scrollCollect(page, 10);
          entry.nodeCount = (await semantics(page)).length;
          entry.layoutSuspects = await layoutSuspects(page);
          const png = join(out, `tab-${tab.key}.png`);
          await shoot(page, png);
          report.screenshots.push(png);
          entry.screenshot = png;
        } else {
          entry.note = 'tab control not reachable by label';
        }
      } catch (err) {
        entry.error = String(err?.message ?? err);
      }
      report.screens[tab.key] = entry;
    }
  }

  report.metrics = await metrics(page);
  report.diagnostics.consoleErrors = logs.consoleErrors.slice(0, 40);
  report.diagnostics.pageErrors = logs.pageErrors.slice(0, 40);
  report.diagnostics.failedRequests = logs.failedRequests.slice(0, 40);
  report.diagnostics.consoleWarnings = logs.consoleWarnings.slice(0, 20);
} catch (err) {
  report.fatal = String(err?.stack ?? err);
} finally {
  await close(session);
}

const path = join(out, 'report.json');
writeFileSync(path, JSON.stringify(report, null, 2));
console.log(path);
console.log(`bootedIntoApp=${report.bootedIntoApp} screenshots=${report.screenshots.length}` +
  ` consoleErrors=${report.diagnostics.consoleErrors?.length ?? 0}`);
if (report.fatal) console.error(report.fatal);
