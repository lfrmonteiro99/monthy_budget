import { expect, test } from '@playwright/test';

import {
  clickSemantic,
  getSemanticNames,
  tryClickSemantic,
} from './flutter_semantics';

test.describe('flutter semantics helpers', () => {
  test('collects visible accessible names and clicks elements without aria-labels', async ({
    page,
  }) => {
    await page.setContent(`
      <main>
        <button type="button">Open settings</button>
        <div role="tablist">
          <button role="tab" aria-selected="true">Home</button>
          <button role="tab">Meal Planner</button>
        </div>
        <section>
          <h1>Monthly Budget</h1>
          <p>FINANCIAL SUMMARY</p>
        </section>
        <script>
          window.__clicked = [];
          document.querySelector('button[type="button"]').addEventListener('click', () => {
            window.__clicked.push('settings');
          });
          document.querySelectorAll('[role="tab"]').forEach((element) => {
            element.addEventListener('click', () => {
              window.__clicked.push(element.textContent.trim());
            });
          });
        </script>
      </main>
    `);

    const names = await getSemanticNames(page);
    expect(names).toEqual(
      expect.arrayContaining([
        'Open settings',
        'Home',
        'Meal Planner',
        'Monthly Budget',
        'FINANCIAL SUMMARY',
      ]),
    );

    expect(
      await tryClickSemantic(page, /Open settings/i, { role: 'button' }),
    ).toBe(true);
    await clickSemantic(page, /Meal Planner/i, { role: 'tab' });

    const clicked = await page.evaluate(() => (window as { __clicked: string[] }).__clicked);
    expect(clicked).toEqual(['settings', 'Meal Planner']);
  });
});
