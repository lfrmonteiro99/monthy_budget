import { expect, Page, test } from '@playwright/test';

import { hasAuthCredentials, login, openApp } from './helpers/auth';
import {
  clickSemantic,
  collectSemanticNamesWhileScrolling,
  waitForSemanticMatch,
} from './helpers/flutter_semantics';

const homeTabPattern = /Home|In[i\u00ed]cio|Accueil/i;
const dashboardTitlePattern =
  /Monthly Budget|Or\u00e7amento Mensal|Budget Mensuel|Presupuesto Mensual/i;
const dashboardSummaryPattern =
  /FINANCIAL SUMMARY|RESUMO FINANCEIRO|R\u00c9SUM\u00c9 FINANCIER|RESUMEN FINANCIERO/i;
const coachTitlePattern =
  /Financial Coach|Coach Financeiro|Coach Financier|Coach Financiero/i;
const openSettingsPattern =
  /Open settings|Abrir defini|Ouvrir les param|Abrir configur/i;
const settingsTitlePattern =
  /^Settings$|^Defini\u00e7\u00f5es$|^Param\u00e8tres$|^Configuraci\u00f3n$/i;
const dashboardBodyPattern =
  /Set up your data to see the summary|Configure os seus dados para ver o resumo|Configurez vos donn\u00e9es pour voir le r\u00e9sum\u00e9|Configure sus datos para ver el resumen|Open Settings|Abrir Defini\u00e7\u00f5es|Ouvrir les Param\u00e8tres|Abrir Configuraci\u00f3n|MONTHLY LIQUIDITY|LIQUIDEZ MENSAL|LIQUIDIT\u00c9 MENSUELLE|LIQUIDEZ MENSUAL|A\u00c7\u00d5ES R\u00c1PIDAS|QUICK ACTIONS|ACTIONS RAPIDES|ACCIONES R\u00c1PIDAS|View month summary|Ver resumo do m\u00eas|Voir le r\u00e9sum\u00e9 du mois|Ver resumen del mes/i;

async function openDashboard(page: Page) {
  await page.keyboard.press('Escape');
  await page.waitForTimeout(300);
  await clickSemantic(page, homeTabPattern, { role: 'tab' });
  await page.waitForTimeout(2000);
  await waitForSemanticMatch(page, dashboardTitlePattern);
  await waitForSemanticMatch(page, dashboardSummaryPattern);
}

test.describe('Dashboard smoke', () => {
  test.skip(
    !hasAuthCredentials(),
    'Set E2E_EMAIL and E2E_PASSWORD to run authenticated Playwright smoke tests.',
  );

  test('shows the dashboard header and reaches settings', async ({ page }) => {
    await openApp(page);
    await login(page);
    await openDashboard(page);

    const dashboardContent = (
      await collectSemanticNamesWhileScrolling(page, 14)
    ).join('\n');

    for (const pattern of [
      dashboardTitlePattern,
      dashboardSummaryPattern,
      coachTitlePattern,
      openSettingsPattern,
    ]) {
      expect(dashboardContent).toMatch(pattern);
    }

    expect(dashboardContent).toMatch(dashboardBodyPattern);

    await page.evaluate(() => window.scrollTo(0, 0));
    await page.waitForTimeout(500);
    await clickSemantic(page, openSettingsPattern, { role: 'button' });
    await page.waitForTimeout(1500);
    await waitForSemanticMatch(page, settingsTitlePattern);
  });
});
