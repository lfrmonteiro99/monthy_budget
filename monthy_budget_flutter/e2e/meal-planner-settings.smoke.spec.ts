import { expect, Page, test } from '@playwright/test';

import {
  clickSemantic,
  collectSemanticNamesWhileScrolling,
  enableFlutterSemantics,
  getSemanticNames,
} from './helpers/flutter_semantics';

const email = process.env.E2E_EMAIL;
const password = process.env.E2E_PASSWORD;
const hasCredentials = Boolean(email && password);

async function login(page: Page) {
  await page.goto('/');
  await page.waitForTimeout(3000);
  await enableFlutterSemantics(page);

  const names = await getSemanticNames(page);
  if (names.some((name) => /Home|Track|Shop/i.test(name))) {
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
}

async function openMealPlannerSettings(page: Page) {
  await page.keyboard.press('Escape');
  await page.waitForTimeout(300);
  await clickSemantic(page, /Shop/i, { role: 'tab' });
  await page.waitForTimeout(2000);
  await clickSemantic(page, /Meal Planner|Refei/i, { role: 'tab' });
  await page.waitForTimeout(2500);
  await clickSemantic(page, /Settings|Defini/i);
  await page.waitForTimeout(2500);
}

test.describe('Meal planner settings smoke', () => {
  test.skip(
    !hasCredentials,
    'Set E2E_EMAIL and E2E_PASSWORD to run authenticated Playwright smoke tests.',
  );

  test('shows the reorganized meal settings sections', async ({ page }) => {
    await login(page);
    await openMealPlannerSettings(page);

    const names = await collectSemanticNamesWhileScrolling(page);
    const content = names.join('\n');

    for (const pattern of [
      /Quem come\?/i,
      /Objetivo/i,
      /Refeicoes fora|Refei.+fora/i,
      /Restricoes alimentares|Restri.+alimentares/i,
      /Preparacao|Prepara/i,
      /Estrategias|Estrateg/i,
      /Variedade de proteina|Variedade de prot/i,
      /Nutricao e saude|Nutricao/i,
      /Despensa/i,
      /Avancado|Avanc/i,
    ]) {
      expect(content).toMatch(pattern);
    }

    for (const pattern of [/Vegetariano/i, /15 min/i, /30 min/i, /45 min/i]) {
      expect(content).toMatch(pattern);
    }
  });
});
