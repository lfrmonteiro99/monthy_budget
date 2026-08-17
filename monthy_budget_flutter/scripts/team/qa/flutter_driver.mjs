// flutter_driver.mjs — toolkit for driving the Flutter web build in a browser.
//
// WHY THIS SHAPE. The app is compiled with the CanvasKit renderer, so the UI is
// painted into a <canvas>: there are no DOM text nodes, no CSS colours and no
// element boxes to inspect. That rules out the usual DOM-scraping approach and
// leaves exactly two sources of truth, which this module exposes:
//
//   1. The SEMANTICS TREE — Flutter mirrors the widget tree into <flt-semantics>
//      elements carrying aria-label, role and a real bounding box. This is the
//      structural view: what exists, what it is called, where it sits, whether
//      it can be reached. Everything programmatic (labels, taps, tap-target
//      sizes, off-viewport clipping, a11y naming) comes from here.
//   2. SCREENSHOTS — the only way to judge how it actually looks. The tester
//      agent reads the PNG and forms a visual verdict on layout, spacing,
//      typography and design consistency, the way a human reviewer would.
//
// Plus the out-of-band channels that reveal breakage the UI hides: console
// messages, uncaught page errors and failed network requests.
//
// The semantics tree only materialises once accessibility is switched on, which
// is what enableSemantics() does. Forgetting it is the single most common reason
// a probe "finds nothing".

import { chromium } from 'playwright';
import { mkdirSync } from 'node:fs';
import { dirname } from 'node:path';

export const VIEWPORTS = {
  phone: { width: 430, height: 932 },   // the real target: a large phone
  small: { width: 360, height: 640 },   // where cramped layouts break first
  tablet: { width: 834, height: 1112 },
};

/**
 * Boot a browser against the served QA build.
 *
 * Returns the page plus live-collected diagnostics. `logs.consoleErrors`,
 * `logs.pageErrors` and `logs.failedRequests` keep filling as you drive the
 * app, so read them at the END of a scenario.
 */
export async function launch({
  url,
  viewport = VIEWPORTS.phone,
  colorScheme = 'light',
  locale = 'pt-PT',
  headless = true,
  slowMo = 0,
} = {}) {
  const browser = await chromium.launch({ headless, slowMo });
  const context = await browser.newContext({
    viewport,
    colorScheme,
    locale,
    deviceScaleFactor: 2,
    hasTouch: true,
    isMobile: true,
  });
  const page = await context.newPage();

  const logs = {
    consoleErrors: [],
    consoleWarnings: [],
    pageErrors: [],
    failedRequests: [],
  };

  page.on('console', (msg) => {
    const text = msg.text();
    if (msg.type() === 'error') logs.consoleErrors.push(text);
    else if (msg.type() === 'warning') logs.consoleWarnings.push(text);
  });
  page.on('pageerror', (err) => logs.pageErrors.push(String(err?.message ?? err)));
  page.on('requestfailed', (req) => {
    // Font/analytics fetches are expected to fail on this offline QA box and
    // reporting them would drown the real findings.
    const u = req.url();
    if (/fonts\.g|googleapis|google-analytics|doubleclick|supabase/.test(u)) return;
    logs.failedRequests.push(`${req.method()} ${u} — ${req.failure()?.errorText ?? '?'}`);
  });

  await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 60_000 });
  await waitForApp(page);

  return { browser, context, page, logs };
}

/**
 * Wait until the app is actually USABLE, not merely until the bundle loaded.
 *
 * A fixed sleep is not good enough here and getting it wrong is expensive: a
 * cold boot has to fetch the CanvasKit wasm, the sqlite wasm and the fonts, and
 * the app holds a splash screen until its own async init finishes. Returning
 * early leaves the tester looking at the splash, which it then reports as "the
 * app is broken" — a false blocker that invalidates a whole run.
 *
 * So: poll for evidence of a real UI (semantic labels) and re-arm semantics each
 * time, because the tree is (re)built as the app settles. Give up only after the
 * full budget, and let the caller decide what an empty tree means.
 */
export async function waitForApp(page, timeoutMs = 45_000) {
  await page.waitForSelector('flt-glass-pane, flutter-view, flt-scene-host', {
    timeout: Math.min(timeoutMs, 30_000),
  }).catch(() => {});

  const deadline = Date.now() + timeoutMs;
  let lastCount = -1;
  while (Date.now() < deadline) {
    await enableSemantics(page);
    const names = await labels(page);
    // Settled = we have labels and the count stopped changing between polls.
    if (names.length > 0 && names.length === lastCount) return true;
    lastCount = names.length;
    await page.waitForTimeout(1_000);
  }
  return lastCount > 0;
}

/**
 * Turn on the semantics tree. Flutter ships a hidden "Enable accessibility"
 * placeholder; activating it makes the whole <flt-semantics> mirror appear.
 */
export async function enableSemantics(page) {
  await page.evaluate(() => {
    const target =
      document.querySelector('[aria-label="Enable accessibility"]') ??
      document.querySelector('flt-semantics-placeholder');
    target?.dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true }));
  });
  await page.waitForTimeout(1_500);
}

/**
 * The semantics tree as a flat array of nodes:
 *   { label, role, x, y, w, h, disabled }
 * This is the structural inventory a tester reasons over.
 */
export async function semantics(page) {
  return page.evaluate(() => {
    const out = [];
    document.querySelectorAll('flt-semantics, [aria-label], [role]').forEach((el) => {
      const label = (el.getAttribute('aria-label') || el.textContent || '')
        .replace(/\s+/g, ' ')
        .trim();
      if (!label) return;
      const r = el.getBoundingClientRect();
      out.push({
        label,
        role: el.getAttribute('role') || el.tagName.toLowerCase(),
        x: Math.round(r.x), y: Math.round(r.y),
        w: Math.round(r.width), h: Math.round(r.height),
        disabled: el.getAttribute('aria-disabled') === 'true',
      });
    });
    // Same label at the same spot appears repeatedly through nested wrappers.
    const seen = new Set();
    return out.filter((n) => {
      const k = `${n.label}|${n.x},${n.y},${n.w},${n.h}`;
      if (seen.has(k)) return false;
      seen.add(k);
      return true;
    });
  });
}

/** Just the visible labels — the quickest way to assert "what is on screen". */
export async function labels(page) {
  const nodes = await semantics(page);
  return [...new Set(nodes.filter((n) => n.w > 0 && n.h > 0).map((n) => n.label))];
}

function toRegExp(pattern) {
  return pattern instanceof RegExp ? pattern : new RegExp(pattern, 'i');
}

/** Find the smallest visible semantic node whose label matches. */
export async function find(page, pattern) {
  const re = toRegExp(pattern);
  const nodes = await semantics(page);
  const hits = nodes
    .filter((n) => n.w > 0 && n.h > 0 && re.test(n.label))
    // Prefer the tightest box: the outer wrappers match too, and clicking the
    // wrapper can land on padding instead of the control.
    .sort((a, b) => a.w * a.h - b.w * b.h);
  return hits[0] ?? null;
}

/**
 * Tap a control by label. Clicks the centre of its semantic box, which works
 * for canvas-painted widgets where there is no DOM element to click.
 * Returns false instead of throwing so a probe can keep going.
 */
export async function tap(page, pattern, { timeoutMs = 8_000 } = {}) {
  const deadline = Date.now() + timeoutMs;
  while (Date.now() < deadline) {
    const node = await find(page, pattern);
    if (node) {
      await page.mouse.click(node.x + node.w / 2, node.y + node.h / 2);
      await page.waitForTimeout(1_200);
      return true;
    }
    await page.waitForTimeout(400);
  }
  return false;
}

/** Type into a field identified by its label. */
export async function fill(page, pattern, value) {
  const inputs = page.locator('input, textarea, [role="textbox"]');
  const count = await inputs.count();
  for (let i = 0; i < count; i += 1) {
    const el = inputs.nth(i);
    const aria = (await el.getAttribute('aria-label')) ?? '';
    if (toRegExp(pattern).test(aria)) {
      await el.click();
      try { await el.fill(String(value)); }
      catch { await page.keyboard.type(String(value), { delay: 15 }); }
      return true;
    }
  }
  if (!(await tap(page, pattern))) return false;
  await page.keyboard.type(String(value), { delay: 15 });
  return true;
}

/** Scroll the view and accumulate every label seen along the way. */
export async function scrollCollect(page, steps = 12, dy = 280) {
  const seen = new Set();
  for (let i = 0; i < steps; i += 1) {
    (await labels(page)).forEach((l) => seen.add(l));
    await page.mouse.wheel(0, dy);
    await page.waitForTimeout(300);
  }
  (await labels(page)).forEach((l) => seen.add(l));
  return [...seen];
}

export async function shoot(page, path) {
  mkdirSync(dirname(path), { recursive: true });
  await page.screenshot({ path, fullPage: false });
  return path;
}

/**
 * Structural defects derivable from the semantics boxes alone. These are
 * reported as SUSPECTS, not proof: confirm each against the screenshot before
 * filing, because a semantic box is not always exactly the painted box.
 */
export async function layoutSuspects(page) {
  const vp = page.viewportSize();
  const nodes = await semantics(page);
  const suspects = [];

  for (const n of nodes) {
    if (n.w <= 0 || n.h <= 0) continue;

    // Content pushed past the right edge: the classic RenderFlex overflow,
    // which a release build no longer prints to the console.
    if (n.x + n.w > vp.width + 2 && n.x < vp.width) {
      suspects.push({
        kind: 'horizontal-overflow',
        label: n.label.slice(0, 80),
        detail: `extends to x=${n.x + n.w} beyond viewport width ${vp.width}`,
      });
    }
    if (n.x < -2) {
      suspects.push({
        kind: 'clipped-left',
        label: n.label.slice(0, 80),
        detail: `starts at x=${n.x}`,
      });
    }
    // Interactive targets below the 44px accessibility floor.
    const interactive = /button|tab|link|checkbox|switch|menuitem|textbox/i.test(n.role);
    if (interactive && (n.w < 44 || n.h < 44)) {
      suspects.push({
        kind: 'small-tap-target',
        label: n.label.slice(0, 80),
        detail: `${n.w}x${n.h}px, below the 44x44 minimum`,
      });
    }
  }

  // A control with no accessible name is unusable with a screen reader.
  const unnamed = await page.evaluate(() =>
    [...document.querySelectorAll('flt-semantics[role="button"], flt-semantics[role="tab"]')]
      .filter((el) => !(el.getAttribute('aria-label') || '').trim()).length);
  if (unnamed > 0) {
    suspects.push({
      kind: 'unnamed-control',
      label: '(various)',
      detail: `${unnamed} button/tab semantic node(s) with no accessible name`,
    });
  }

  const seen = new Set();
  return suspects.filter((s) => {
    const k = `${s.kind}|${s.label}`;
    if (seen.has(k)) return false;
    seen.add(k);
    return true;
  });
}

/** Rough load metrics — enough to spot a pathological screen, not a benchmark. */
export async function metrics(page) {
  return page.evaluate(() => {
    const nav = performance.getEntriesByType('navigation')[0];
    return {
      domContentLoadedMs: Math.round(nav?.domContentLoadedEventEnd ?? 0),
      loadMs: Math.round(nav?.loadEventEnd ?? 0),
      transferredKb: Math.round(
        performance.getEntriesByType('resource')
          .reduce((sum, r) => sum + (r.transferSize || 0), 0) / 1024),
      jsHeapMb: performance.memory
        ? Math.round(performance.memory.usedJSHeapSize / 1048576)
        : null,
    };
  });
}

/**
 * The app's bottom navigation. Returned in the order the user meets them, so a
 * probe can walk the whole app without hardcoding labels at every call site.
 */
export const TABS = [
  { key: 'home', pattern: /^(Home|In[íi]cio|Accueil|Inicio)$/i },
  { key: 'track', pattern: /^(Track|Registar|Suivi|Registrar|Gastos)$/i },
  { key: 'shop', pattern: /^(Shop|Compras|Courses)$/i },
  { key: 'plan', pattern: /^(Plan|Planear|Planifier|Planear)$/i },
  { key: 'more', pattern: /^(More|Mais|Plus|M[áa]s)$/i },
];

export async function openTab(page, key) {
  const tab = TABS.find((t) => t.key === key);
  if (!tab) throw new Error(`unknown tab: ${key}`);
  await page.keyboard.press('Escape').catch(() => {});
  await page.waitForTimeout(200);
  const ok = await tap(page, tab.pattern);
  if (ok) await page.waitForTimeout(1_500);
  return ok;
}

export async function close(session) {
  await session?.browser?.close().catch(() => {});
}
