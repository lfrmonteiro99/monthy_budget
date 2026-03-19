import { expect, Page, test } from '@playwright/test';

import { hasAuthCredentials, login, openApp } from './helpers/auth';
import {
  clickSemantic,
  getSemanticNames,
  waitForSemanticMatch,
} from './helpers/flutter_semantics';

const homeTabPattern = /Home|In[i\u00ed]cio|Accueil/i;
const dashboardTitlePattern =
  /Monthly Budget|Or\u00e7amento Mensal|Budget Mensuel|Presupuesto Mensual/i;
const insightsTitlePattern =
  /Insights|An\u00e1lise|Analyses|An\u00e1lisis/i;
const savingsGoalsPattern =
  /Savings Goals|Objetivos de Poupan\u00e7a|Objectifs d'\u00c9pargne|Objetivos de Ahorro/i;
const savingsEmptyStatePattern =
  /No savings goals|Sem objetivos de poupan\u00e7a|Aucun objectif d'\u00e9pargne|Sin objetivos de ahorro/i;
const savingsGoalProgressPattern =
  /\d+%\s+(reached|alcan\u00e7ad[oa]?|atteint|alcanzado)/i;
const howItWorksPattern =
  /How does it work|Como funciona|Comment \u00e7a marche|C\u00f3mo funciona/i;
const openCommandAssistantPattern = /Open command assistant/i;

async function openDashboard(page: Page) {
  await page.keyboard.press('Escape');
  await page.waitForTimeout(300);
  await clickSemantic(page, homeTabPattern, { role: 'tab' });
  await page.waitForTimeout(1500);
  await waitForSemanticMatch(page, dashboardTitlePattern);
}

async function openInsights(page: Page) {
  await openDashboard(page);
  await clickSemantic(page, openCommandAssistantPattern, { role: 'button' });

  const commandInput = page.getByRole('textbox').first();
  await expect(commandInput).toBeVisible();
  await commandInput.fill('open insights');
  await commandInput.press('Enter');

  await page.waitForTimeout(1500);
  await waitForSemanticMatch(page, insightsTitlePattern);
}

async function openSavingsGoals(page: Page) {
  await openInsights(page);
  await clickSemantic(page, savingsGoalsPattern, { role: 'button' });

  await expect
    .poll(async () => {
      const content = (await getSemanticNames(page)).join('\n');
      return (
        savingsEmptyStatePattern.test(content) ||
        savingsGoalProgressPattern.test(content)
      );
    })
    .toBe(true);
}

test.describe('Savings goals smoke', () => {
  test.skip(
    !hasAuthCredentials(),
    'Set E2E_EMAIL and E2E_PASSWORD to run authenticated Playwright smoke tests.',
  );

  test('opens savings goals from insights and shows a valid state', async ({
    page,
  }) => {
    await openApp(page);
    await login(page);
    await openSavingsGoals(page);

    const content = (await getSemanticNames(page)).join('\n');

    expect(content).toMatch(savingsGoalsPattern);
    expect(
      savingsEmptyStatePattern.test(content) ||
        savingsGoalProgressPattern.test(content),
    ).toBe(true);

    if (savingsEmptyStatePattern.test(content)) {
      expect(content).toMatch(howItWorksPattern);
    } else {
      expect(content).toMatch(savingsGoalProgressPattern);
    }
  });
});
