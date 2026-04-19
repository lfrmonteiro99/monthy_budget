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

  // Ensure Flutter's semantics tree is attached — TextFields only expose
  // aria-labels once the "Enable accessibility" placeholder is activated.
  await enableFlutterSemantics(page);

  // The login form mounts the Email field first; wait for it before typing.
  await waitForSemanticMatch(page, emailLabel, 20_000);

  await fillSemanticField(page, emailLabel, email!);
  await fillSemanticField(page, passwordLabel, password!);

  // Click the localized "Sign in" button. Fall back to Enter if the button
  // can't be found (some locales or theme variants may not expose the role).
  const submitted = await tryClickSemantic(page, signInLabel, {
    role: 'button',
  });
  if (!submitted) {
    await page.keyboard.press('Enter');
  }

  // Wait for the authenticated home to paint. Re-enable semantics because
  // Flutter resets the tree on navigation.
  await page.waitForTimeout(2000);
  await enableFlutterSemantics(page);
  await waitForSemanticMatch(page, authenticatedPattern, 30_000);
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
