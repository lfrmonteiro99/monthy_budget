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
  await clickSemantic(page, /Settings|Defini/i, { role: 'button' });
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

    // Section titles may be merged in Flutter semantics. Match via titles,
    // subtitles, or distinctive child content that proves each section rendered.
    for (const pattern of [
      /Add member|Adicionar membro/i,          // Section 1: Household
      /Planning and active meals|ACTIVE MEALS|Planeamento/i, // Section 2: Goals
      /Mon|Tue|Wed|Thu|Fri|Sat|Sun|Seg|Ter|Qua|Qui|Sex|Sab|Dom/i, // Section 3: Eating out weekdays
      /Gluten|Lactose|Shellfish|Marisco/i,     // Section 4: Dietary
      /Easy|Medium|Pro|Facil|Medio/i,          // Section 5: Preparation (SegmentedButton)
      /Protein variety|Variedade de prot/i,    // Section 7: Protein
      /Advanced|Avancado|Avanc/i,              // Section 10: Advanced
    ]) {
      expect(content).toMatch(pattern);
    }

    for (const pattern of [/15 min/i, /30 min/i, /45 min/i]) {
      expect(content).toMatch(pattern);
    }
  });
});
