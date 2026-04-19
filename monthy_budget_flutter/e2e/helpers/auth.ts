import { expect, Page } from '@playwright/test';

import {
  clickSemantic,
  enableFlutterSemantics,
  fillSemanticField,
  getSemanticNames,
  tryClickSemantic,
  waitForSemanticMatch,
} from './flutter_semantics';

const email = process.env.E2E_EMAIL;
const password = process.env.E2E_PASSWORD;
const settingsTitlePattern =
  /^Settings$|^Definições$|^Paramètres$|^Configuración$/i;

// Auth-screen selectors. Labels come from the localized l10n strings on
// LoginScreen (lib/screens/auth/login_screen.dart) — keep these in sync.
const emailLabel = /Email/i;
const passwordLabel = /Password|Palavra-passe|Contrase[ñn]a|Mot de passe/i;
const signInLabel =
  /Sign in|Entrar|Se connecter|Iniciar sesi[oó]n/i;
const authenticatedPattern = /Home|Track|Shop/i;

export function hasAuthCredentials() {
  return Boolean(email && password);
}

export async function openApp(page: Page) {
  await page.goto('/');
  await page.waitForTimeout(3000);
  await enableFlutterSemantics(page);
}

export async function isAuthenticated(page: Page) {
  const names = await getSemanticNames(page);
  return names.some((name) => authenticatedPattern.test(name));
}

export async function login(page: Page) {
  expect(hasAuthCredentials()).toBeTruthy();

  if (await isAuthenticated(page)) {
    return;
  }

  // Ensure Flutter's semantics tree is attached. Flutter web renders
  // TextFields as real <input> elements once the "Enable accessibility"
  // placeholder has been activated — which openApp() does — but the tree
  // can be rebuilt on navigation, so re-enable to be safe.
  await enableFlutterSemantics(page);

  // Wait for the login form to mount. LoginScreen uses the l10n string
  // "Email" (or locale equivalent) as the email TextField labelText, which
  // shows up as on-screen text regardless of whether it's exposed on the
  // input's aria-label.
  await waitForSemanticMatch(page, emailLabel, 20_000);

  // Wait until Flutter has emitted at least 2 focusable input-like semantic
  // elements so the form is really ready, not just the Email label text.
  try {
    await page.waitForFunction(
      () =>
        document.querySelectorAll(
          'input, [role="textbox"], flt-semantics[role="textbox"]',
        ).length >= 2,
      null,
      { timeout: 10_000 },
    );
  } catch {
    // Non-fatal: fall through and let the strategies below retry.
  }

  // Strategy: Flutter web's semantic layer renders each TextField as an
  // <input> element. LoginScreen has exactly two TextFields (email, then
  // password), so we can find them in DOM order. If that fails, fall back
  // to the fillSemanticField helper which tries aria-label / role lookup
  // and keyboard typing.
  const inputs = page.locator('input');
  const inputCount = await inputs.count();

  if (inputCount >= 2) {
    const emailInput = inputs.nth(0);
    const passwordInput = inputs.nth(1);
    await emailInput.click();
    await page.waitForTimeout(150);
    try {
      await emailInput.fill(email!);
    } catch {
      await page.keyboard.press('Control+a');
      await page.keyboard.type(email!, { delay: 10 });
    }
    await passwordInput.click();
    await page.waitForTimeout(150);
    try {
      await passwordInput.fill(password!);
    } catch {
      await page.keyboard.press('Control+a');
      await page.keyboard.type(password!, { delay: 10 });
    }
  } else {
    await fillSemanticField(page, emailLabel, email!);
    await fillSemanticField(page, passwordLabel, password!);
  }

  // Click the localized Sign in button. If the button semantic isn't found
  // (e.g. Flutter hasn't exposed it), press Enter — the password field's
  // onSubmitted calls _submit() too.
  const submitted = await tryClickSemantic(page, signInLabel, {
    role: 'button',
  });
  if (!submitted) {
    await page.keyboard.press('Enter');
  }

  // Wait for the authenticated home to paint. Flutter rebuilds the semantic
  // tree on navigation, so re-enable first.
  await page.waitForTimeout(2000);
  await enableFlutterSemantics(page);

  try {
    await waitForSemanticMatch(page, authenticatedPattern, 30_000);
  } catch (err) {
    // Surface a detailed diagnostic instead of a raw timeout — the CI log
    // is our only debugging channel once the workflow finishes.
    const semantics = await getSemanticNames(page);
    const inputsFound = await page.locator('input').count();
    const buttonsFound = await page.getByRole('button').count();
    throw new Error(
      `login() timed out waiting for authenticated home (${authenticatedPattern}).\n` +
        `  inputs on page: ${inputsFound}\n` +
        `  buttons on page: ${buttonsFound}\n` +
        `  first 40 semantic labels: ${semantics.slice(0, 40).join(' | ')}\n` +
        `  cause: ${(err as Error).message}`,
    );
  }
}

export async function logout(page: Page) {
  const openedSettings =
    (await tryClickSemantic(page, /Open settings|Abrir defini/i, {
      role: 'button',
    })) || (await tryClickSemantic(page, /Settings|Defini/i));

  expect(openedSettings, 'Could not open settings before logout').toBeTruthy();
  await waitForSemanticMatch(page, settingsTitlePattern, 15_000);
  await clickSemantic(page, /Sign out|Terminar sess(?:ao|\u00e3o)|Sair/i, {
    role: 'button',
  });
  await enableFlutterSemantics(page);
  await waitForSemanticMatch(page, /Sign in|Entrar na conta|Entrar/i);
}
