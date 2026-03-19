import { expect, Page, test } from '@playwright/test';

import { hasAuthCredentials, login, openApp } from './helpers/auth';
import {
  clickSemantic,
  getSemanticNames,
  waitForSemanticMatch,
} from './helpers/flutter_semantics';

const trackTabPattern = /Track|Despesas|D\u00e9penses|Gastos/i;
const trackerTitlePattern =
  /Expense Tracker|Controlo de Despesas|Suivi des D\u00e9penses|Control de Gastos/i;
const scanReceiptPattern =
  /Scan Receipt|Scan Recibo|Scanner Re\u00e7u|Escanear Recibo/i;
const exportPattern = /Export|Exportar|Exporter/i;
const searchPattern = /Search|Pesquisar|Rechercher|Buscar/i;
const recurringPattern =
  /Manage recurring payments|Gerir pagamentos recorrentes|G\u00e9rer les paiements r\u00e9currents|Gestionar pagos recurrentes/i;
const budgetedPattern = /Budgeted|Or\u00e7amentado|Budg\u00e9t\u00e9|Presupuestado/i;
const actualPattern = /Actual|Real|R\u00e9el/i;
const remainingOrOverPattern =
  /Remaining|Restante|Restant|Over budget|Acima do or\u00e7amento|D\u00e9passement|Sobrepasado/i;
const addExpensePattern =
  /Log expense|Registar despesa|Saisir une d\u00e9pense|Registrar gasto/i;
const dateRangePattern = /Date range|Per[i\u00ed]odo|P\u00e9riode/i;
const resultCountPattern = /\d+\s+(results|resultados|r\u00e9sultats)/i;

async function openExpenseTracker(page: Page) {
  await page.keyboard.press('Escape');
  await page.waitForTimeout(300);
  await clickSemantic(page, trackTabPattern, { role: 'tab' });
  await page.waitForTimeout(2000);
  await waitForSemanticMatch(page, trackerTitlePattern);
}

async function openSearch(page: Page) {
  await clickSemantic(page, searchPattern, { role: 'button' });
  await page.waitForTimeout(500);
  await waitForSemanticMatch(page, dateRangePattern, 30_000);
}

test.describe('Expense tracker smoke', () => {
  test.skip(
    !hasAuthCredentials(),
    'Set E2E_EMAIL and E2E_PASSWORD to run authenticated Playwright smoke tests.',
  );

  test('opens expense tracker and search without mutating data', async ({
    page,
  }) => {
    await openApp(page);
    await login(page);
    await openExpenseTracker(page);

    const trackerPatterns = [
      trackerTitlePattern,
      scanReceiptPattern,
      exportPattern,
      searchPattern,
      recurringPattern,
      budgetedPattern,
      actualPattern,
      remainingOrOverPattern,
      addExpensePattern,
    ];

    await expect
      .poll(async () => {
        const content = (await getSemanticNames(page)).join('\n');
        return trackerPatterns.every((pattern) => pattern.test(content));
      })
      .toBe(true);

    const trackerContent = (await getSemanticNames(page)).join('\n');

    for (const pattern of trackerPatterns) {
      expect(trackerContent).toMatch(pattern);
    }

    await openSearch(page);

    await expect
      .poll(async () => {
        const content = (await getSemanticNames(page)).join('\n');
        return (
          dateRangePattern.test(content) && resultCountPattern.test(content)
        );
      })
      .toBe(true);

    const searchContent = (await getSemanticNames(page)).join('\n');
    expect(searchContent).toMatch(dateRangePattern);
    expect(searchContent).toMatch(resultCountPattern);
  });
});
