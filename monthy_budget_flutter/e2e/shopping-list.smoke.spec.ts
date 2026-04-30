import { expect, Page, test } from '@playwright/test';

import { hasAuthCredentials, login, openApp } from './helpers/auth';
import {
  clickSemantic,
  getSemanticNames,
  waitForSemanticMatch,
} from './helpers/flutter_semantics';

const planAndShopTabPattern = /Shop|Compras|Courses/i;
const shoppingListTabPattern = /Shopping List|Lista de Compras|Liste de Courses/i;
const scanReceiptPattern =
  /Scan Receipt|Scan Recibo|Scanner Re\u00e7u|Escanear Recibo/i;
const emptyStatePattern =
  /Empty list|Lista vazia|Liste vide|Lista vac[i\u00ed]a/i;
const populatedSummaryPattern =
  /\b\d+\s+(to buy|por comprar|\u00e0 acheter)\b/i;

async function openShoppingList(page: Page) {
  await page.keyboard.press('Escape');
  await page.waitForTimeout(300);
  await clickSemantic(page, planAndShopTabPattern, { role: 'tab' });
  await page.waitForTimeout(2000);
  await waitForSemanticMatch(page, scanReceiptPattern);
}

test.describe('Shopping list smoke', () => {
  test.skip(
    !hasAuthCredentials(),
    'Set E2E_EMAIL and E2E_PASSWORD to run authenticated Playwright smoke tests.',
  );

  test.skip('opens the shopping list default tab and shows a valid list state', async ({
    page,
  }) => {
    await openApp(page);
    await login(page);
    await openShoppingList(page);

    await expect
      .poll(async () => {
        const content = (await getSemanticNames(page)).join('\n');
        return (
          emptyStatePattern.test(content) || populatedSummaryPattern.test(content)
        );
      })
      .toBe(true);

    const content = (await getSemanticNames(page)).join('\n');

    expect(content).toMatch(shoppingListTabPattern);
    expect(content).toMatch(scanReceiptPattern);
    expect(
      emptyStatePattern.test(content) || populatedSummaryPattern.test(content),
    ).toBe(true);
  });
});
