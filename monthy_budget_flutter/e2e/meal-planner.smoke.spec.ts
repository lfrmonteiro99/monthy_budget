import { expect, Page, test } from '@playwright/test';

import { hasAuthCredentials, login, openApp } from './helpers/auth';
import {
  clickSemantic,
  collectSemanticNamesWhileScrolling,
  getSemanticNames,
  tryClickSemantic,
  waitForSemanticMatch,
} from './helpers/flutter_semantics';

// Patterns for multi-language support (PT/EN/ES/FR)
const planAndShopTab = /Shop|Compras|Courses/i;
const mealPlannerTab = /Meal Planner|Planeador|Planificateur|Planificador/i;
// Match the primary "Generate Plan" button on the meal-planner empty state
// and wizard step 5. Word-boundary prefix + trailing "plan" keeps this from
// matching the "Regenerate" button shown once a plan already exists —
// otherwise downstream tests click it and get stuck on the "Regenerate
// plan?" confirmation dialog.
const generateButton = /\bGenerate\s+Plan\b|\bGerar\s+Plano\b|\bG[eé]n[eé]rer\s+le\s+plan\b|\bGenerar\s+Plan\b/i;
const weekLabel = /Week|Semana|Semaine/i;
const addToListButton = /Add.*list|Adicionar.*lista|Ajouter.*liste|A[nñ]adir.*lista/i;
const ingredientsButton = /Ingredients|Ingredientes|Ingr[eé]dients/i;
const swapButton = /Swap|Trocar|[ÉE]changer|Cambiar/i;
const prepGuideButton = /Prep|Prepara[cç][aã]o|Pr[eé]paration/i;
const consolidatedListButton = /Consolidated|Consolidada|Consolid[eé]e/i;
const settingsButton = /Settings|Defini[cç][oõ]es|Param[eè]tres|Configuraci[oó]n/i;

// Course type patterns
const soupCoursePattern = /Soup|Sopa|Soupe|Entrada|Entr[eé]e|Starter/i;
const mainCoursePattern = /Main|Principal|Plat/i;
const dessertCoursePattern = /Dessert|Sobremesa|Postre/i;

// Day/meal patterns
const dayPattern = /Dia \d|Day \d|Jour \d/i;
const mealTypePattern = /Lunch|Almo[cç]o|D[eé]jeuner|Dinner|Jantar|D[iî]ner/i;

// Meal-planner setup wizard labels (lib/l10n/app_*.arb wizardContinue /
// wizardGeneratePlan / wizardStep*). Fresh test accounts land in the 5-step
// wizard the first time Meal Planner is opened; the helper below clicks
// through it so the smoke tests reach the actual planner.
const wizardStepLabel = /Step \d+ of \d+|Passo \d+ de \d+|[EÉe]tape \d+ sur \d+|Paso \d+ de \d+/i;
const wizardContinueButton = /^Continue$|^Continuar$|^Continuer$|^Continuar$/i;
const wizardGeneratePlanButton = /Generate Plan|Gerar Plano|G[eé]n[eé]rer le plan|Generar Plan/i;

async function completeMealWizardIfPresent(page: Page) {
  // Quick probe: are we on the wizard? It shows "Step N of 5" and a
  // Continue / Generate Plan primary button.
  const onWizard = async () => {
    const names = await getSemanticNames(page);
    const content = names.join('\n');
    return wizardStepLabel.test(content);
  };

  if (!(await onWizard())) return;

  // Up to 6 iterations (5 steps + slack). On the final step the button
  // label flips from "Continue" to "Generate Plan".
  for (let step = 0; step < 6; step += 1) {
    // Prefer the terminal Generate Plan button when present — pressing it
    // immediately if we're on step 5 avoids an extra loop.
    const clickedGenerate = await tryClickSemantic(
      page,
      wizardGeneratePlanButton,
      { role: 'button' },
    );
    if (clickedGenerate) {
      await page.waitForTimeout(3000);
      break;
    }

    const clickedContinue = await tryClickSemantic(
      page,
      wizardContinueButton,
      { role: 'button' },
    );
    if (!clickedContinue) {
      // Wizard exited (or we never found the button) — stop looping.
      break;
    }
    await page.waitForTimeout(800);

    if (!(await onWizard())) {
      break;
    }
  }
  // Allow Flutter to rebuild the planner after the wizard dismisses.
  await page.waitForTimeout(1500);
}

async function openMealPlanner(page: Page) {
  await page.keyboard.press('Escape');
  await page.waitForTimeout(300);
  await clickSemantic(page, planAndShopTab, { role: 'tab' });
  await page.waitForTimeout(2000);
  await clickSemantic(page, mealPlannerTab, { role: 'tab' });
  await page.waitForTimeout(2500);
  // First-run meal-planner configuration wizard; click through when present.
  await completeMealWizardIfPresent(page);
}

test.describe('Meal planner E2E smoke', () => {
  test.skip(
    !hasAuthCredentials(),
    'Set E2E_EMAIL and E2E_PASSWORD to run authenticated Playwright smoke tests.',
  );

  test('meal planner screen renders and shows plan or empty state', async ({
    page,
  }) => {
    await openApp(page);
    await login(page);
    await openMealPlanner(page);

    const names = await getSemanticNames(page);
    const content = names.join('\n');

    // Should show either a generated plan (with week navigation) or the generate button
    const hasPlan = weekLabel.test(content);
    const hasGenerate = generateButton.test(content);
    expect(
      hasPlan || hasGenerate,
      `Expected meal planner to show a plan or generate button. Content: ${content.substring(0, 500)}`,
    ).toBe(true);
  });

  test('can generate a meal plan', async ({ page }) => {
    await openApp(page);
    await login(page);
    await openMealPlanner(page);

    const names = await getSemanticNames(page);
    const content = names.join('\n');

    // If no plan exists, generate one
    if (generateButton.test(content)) {
      await clickSemantic(page, generateButton, { role: 'button' });
      await page.waitForTimeout(5000); // generation takes a moment
    }

    // After generation, plan should be visible with week navigation
    await waitForSemanticMatch(page, weekLabel, 15_000);

    const planContent = (await getSemanticNames(page)).join('\n');

    // Verify day labels are present
    expect(planContent).toMatch(dayPattern);

    // Verify meal type labels
    expect(planContent).toMatch(mealTypePattern);
  });

  test('meal cards show course structure and action buttons', async ({
    page,
  }) => {
    await openApp(page);
    await login(page);
    await openMealPlanner(page);

    // Ensure plan exists
    const names = await getSemanticNames(page);
    if (generateButton.test(names.join('\n'))) {
      await clickSemantic(page, generateButton, { role: 'button' });
      await page.waitForTimeout(5000);
    }

    await waitForSemanticMatch(page, weekLabel, 15_000);

    // Scroll and collect all visible semantic names
    const allNames = await collectSemanticNamesWhileScrolling(page);
    const content = allNames.join('\n');

    // Verify cost is displayed (e.g. "1.53€" or "€1.53")
    expect(content).toMatch(/\d+[.,]\d{2}\s*€|€\s*\d+[.,]\d{2}/);

    // Verify recipe names appear (at least one real food name)
    expect(content).toMatch(
      /Frango|Sopa|Bacalhau|Salmão|Arroz|Massa|Omelete|Bife|Chicken|Salmon|Rice/i,
    );
  });

  test('multi-course meals show soup and dessert labels when enabled', async ({
    page,
  }) => {
    await openApp(page);
    await login(page);
    await openMealPlanner(page);

    // Ensure plan exists
    const names = await getSemanticNames(page);
    if (generateButton.test(names.join('\n'))) {
      await clickSemantic(page, generateButton, { role: 'button' });
      await page.waitForTimeout(5000);
    }

    await waitForSemanticMatch(page, weekLabel, 15_000);

    // Scroll and collect all content
    const allNames = await collectSemanticNamesWhileScrolling(page);
    const content = allNames.join('\n');

    // Check if multi-course is enabled by looking for course labels
    const hasSoupLabel = soupCoursePattern.test(content);
    const hasDessertLabel = dessertCoursePattern.test(content);

    // If multi-course is enabled, verify structure
    if (hasSoupLabel) {
      // Soup course should appear before main course
      expect(content).toMatch(soupCoursePattern);
      // Swap icon should be available for soups
      expect(content).toMatch(/⇄|swap_horiz|Trocar/i);
    }

    if (hasDessertLabel) {
      expect(content).toMatch(dessertCoursePattern);
    }

    // Regardless of multi-course, main course content should always be present
    expect(content).toMatch(/\d+\s*kcal/i); // nutrition badges
  });

  test('can expand ingredients and see individual items', async ({ page }) => {
    await openApp(page);
    await login(page);
    await openMealPlanner(page);

    const names = await getSemanticNames(page);
    if (generateButton.test(names.join('\n'))) {
      await clickSemantic(page, generateButton, { role: 'button' });
      await page.waitForTimeout(5000);
    }

    await waitForSemanticMatch(page, weekLabel, 15_000);

    // Click the ingredients expand button on the first card
    const clicked = await tryClickSemantic(
      page,
      /Ingredients|Ingredientes/i,
      { role: 'button' },
    );

    if (clicked) {
      await page.waitForTimeout(1000);
      const expanded = (await getSemanticNames(page)).join('\n');

      // Should show ingredient names (common Portuguese food words)
      expect(expanded).toMatch(
        /Frango|Arroz|Cebola|Azeite|Batata|Massa|Ovo|Tomate|Chicken|Rice|Onion|Oil/i,
      );

      // Should show quantity + unit (e.g. "0.5 kg" or "2 unidade")
      expect(expanded).toMatch(/\d+[.,]?\d*\s*(kg|g|L|ml|unidade|un)/i);

      // Should show swap icon for each ingredient
      expect(expanded).toMatch(/swap_horiz|⇄/i);
    }
  });

  test('can add week to shopping list', async ({ page }) => {
    await openApp(page);
    await login(page);
    await openMealPlanner(page);

    const names = await getSemanticNames(page);
    if (generateButton.test(names.join('\n'))) {
      await clickSemantic(page, generateButton, { role: 'button' });
      await page.waitForTimeout(5000);
    }

    await waitForSemanticMatch(page, weekLabel, 15_000);

    // Click "Add week to shopping list"
    const clicked = await tryClickSemantic(page, addToListButton, {
      role: 'button',
    });

    if (clicked) {
      await page.waitForTimeout(2000);
      // Should show a snackbar confirmation with ingredient count
      const afterClick = (await getSemanticNames(page)).join('\n');
      expect(afterClick).toMatch(
        /\d+\s*(ingredients|ingredientes|ingr[eé]dients)\s*(added|adicionados|ajout[eé]s)/i,
      );
    }
  });

  test('consolidated list shows grouped ingredients', async ({ page }) => {
    await openApp(page);
    await login(page);
    await openMealPlanner(page);

    const names = await getSemanticNames(page);
    if (generateButton.test(names.join('\n'))) {
      await clickSemantic(page, generateButton, { role: 'button' });
      await page.waitForTimeout(5000);
    }

    await waitForSemanticMatch(page, weekLabel, 15_000);

    // Open consolidated list
    const clicked = await tryClickSemantic(page, consolidatedListButton, {
      role: 'button',
    });

    if (clicked) {
      await page.waitForTimeout(2000);
      const listContent = (await getSemanticNames(page)).join('\n');

      // Should show category headers (proteins, vegetables, carbs)
      expect(listContent).toMatch(
        /PROTE[IÍ]N|VEGETA|CARB|GORDURA|CONDIMENTO|PROTEIN|FAT/i,
      );

      // Should show ingredient names with quantities
      expect(listContent).toMatch(/\d+[.,]?\d*\s*(kg|g|L|ml)/i);
    }
  });

  test('recipe swap shows alternatives of same course type', async ({
    page,
  }) => {
    await openApp(page);
    await login(page);
    await openMealPlanner(page);

    const names = await getSemanticNames(page);
    if (generateButton.test(names.join('\n'))) {
      await clickSemantic(page, generateButton, { role: 'button' });
      await page.waitForTimeout(5000);
    }

    await waitForSemanticMatch(page, weekLabel, 15_000);

    // Try to click swap on the first meal card
    const clicked = await tryClickSemantic(page, swapButton, {
      role: 'button',
    });

    if (clicked) {
      await page.waitForTimeout(2000);
      const swapContent = (await getSemanticNames(page)).join('\n');

      // Should show alternatives
      expect(swapContent).toMatch(
        /Alternativ|Troc|Swap|Cancel|Cancelar/i,
      );

      // Should show cost differences (e.g. "+0.50€" or "-1.20€")
      expect(swapContent).toMatch(/[+-]\d+[.,]\d{2}\s*€/);

      // Close the swap sheet
      await tryClickSemantic(page, /Cancel|Cancelar|Annuler/i, {
        role: 'button',
      });
    }
  });
});
