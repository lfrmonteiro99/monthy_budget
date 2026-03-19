import { expect, Page } from '@playwright/test';

import {
  clickSemantic,
  enableFlutterSemantics,
  getSemanticNames,
  tryClickSemantic,
  waitForSemanticMatch,
} from './flutter_semantics';

const email = process.env.E2E_EMAIL;
const password = process.env.E2E_PASSWORD;

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
  return names.some((name) => /Home|Track|Shop/i.test(name));
}

export async function login(page: Page) {
  expect(hasAuthCredentials()).toBeTruthy();

  if (await isAuthenticated(page)) {
    return;
  }

  const viewport = page.viewportSize();
  expect(viewport).not.toBeNull();

  await page.mouse.click(viewport!.width / 2, 475);
  await page.waitForTimeout(300);
  await page.keyboard.press('Control+a');
  await page.keyboard.type(email!, { delay: 10 });
  await page.keyboard.press('Tab');
  await page.waitForTimeout(300);
  await page.keyboard.type(password!, { delay: 10 });
  await page.mouse.click(viewport!.width / 2, 590);
  await page.waitForTimeout(1000);
  await page.keyboard.press('Enter');
  await page.waitForTimeout(12_000);
  await enableFlutterSemantics(page);
  await waitForSemanticMatch(page, /Home|Track|Shop/i);
}

export async function logout(page: Page) {
  const openedSettings =
    (await tryClickSemantic(page, /Open settings|Abrir defini/i, {
      role: 'button',
    })) || (await tryClickSemantic(page, /Settings|Defini/i));

  expect(openedSettings, 'Could not open settings before logout').toBeTruthy();

  await page.waitForTimeout(1500);
  await clickSemantic(page, /Sign out|Terminar sess(?:ao|\u00e3o)|Sair/i);
  await page.waitForTimeout(1500);
  await enableFlutterSemantics(page);
  await waitForSemanticMatch(page, /Sign in|Entrar na conta|Entrar/i);
}
