import { expect, Page, test } from '@playwright/test';

import { hasAuthCredentials, login, openApp } from './helpers/auth';
import {
  clickSemantic,
  getSemanticNames,
  waitForSemanticMatch,
} from './helpers/flutter_semantics';

const homeTabPattern = /Home|In[ií]cio|Accueil/i;
const dashboardTitlePattern =
  /Monthly Budget|Orçamento Mensal|Budget Mensuel|Presupuesto Mensual/i;
const trendsPattern = /Trends|Evolução|Évolution|Evolución/i;
const insightsTitlePattern = /Insights|Análise|Analyses|Análisis/i;
const savingsGoalsPattern =
  /Savings Goals|Objetivos de Poupança|Objectifs d'Épargne|Objetivos de Ahorro/i;
const savingsEmptyStatePattern =
  /No savings goals|Sem objetivos de poupança|Aucun objectif d'épargne|Sin objetivos de ahorro/i;
const savingsGoalProgressPattern =
  /\d+%\s+(reached|alcançad[oa]?|atteint|alcanzado)/i;
const howItWorksPattern =
  /How does it work|Como funciona|Comment ça marche|Cómo funciona/i;

async function openDashboard(page: Page) {
  await page.keyboard.press('Escape');
  await page.waitForTimeout(300);
  await clickSemantic(page, homeTabPattern, { role: 'tab' });
  await page.waitForTimeout(1500);
  await waitForSemanticMatch(page, dashboardTitlePattern);
}

async function openSavingsGoals(page: Page) {
  await openDashboard(page);
  await clickSemantic(page, trendsPattern, { role: 'button' });
  await page.waitForTimeout(1500);
  await waitForSemanticMatch(page, insightsTitlePattern);
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
