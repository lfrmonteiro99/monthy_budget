import { expect, Page, test } from '@playwright/test';

import { hasAuthCredentials, login, openApp } from './helpers/auth';
import {
  clickSemantic,
  collectSemanticNamesWhileScrolling,
} from './helpers/flutter_semantics';

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
    !hasAuthCredentials(),
    'Set E2E_EMAIL and E2E_PASSWORD to run authenticated Playwright smoke tests.',
  );

  test('shows the reorganized meal settings sections', async ({ page }) => {
    await openApp(page);
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
