import { expect, Page } from '@playwright/test';

type SemanticOptions = {
  role?: string;
};

export async function enableFlutterSemantics(page: Page) {
  await page.evaluate(() => {
    const target =
      document.querySelector('[aria-label="Enable accessibility"]') ??
      document.querySelector('flt-semantics-placeholder');
    if (target) {
      target.dispatchEvent(
        new MouseEvent('click', { bubbles: true, cancelable: true }),
      );
    }
  });
  await page.waitForTimeout(1500);
}

export async function getSemanticNames(page: Page): Promise<string[]> {
  return page.evaluate(() => {
    const names: string[] = [];
    document.querySelectorAll('[aria-label], [role]').forEach((element) => {
      const label = element.getAttribute('aria-label');
      if (label && label.trim()) {
        names.push(label.trim());
      }
    });
    return names;
  });
}

export async function clickSemantic(
  page: Page,
  labelPattern: RegExp,
  options: SemanticOptions = {},
) {
  const selector = options.role ? `[role="${options.role}"]` : '[aria-label]';
  const result = await page.evaluate(
    ({ pattern, patternFlags, selectorValue }) => {
      const regex = new RegExp(pattern, patternFlags);
      for (const element of document.querySelectorAll(selectorValue)) {
        const label = element.getAttribute('aria-label') ?? '';
        if (!regex.test(label)) continue;
        const rect = element.getBoundingClientRect();
        return {
          x: rect.x + rect.width / 2,
          y: rect.y + rect.height / 2,
        };
      }
      return null;
    },
    {
      pattern: labelPattern.source,
      patternFlags: labelPattern.flags,
      selectorValue: selector,
    },
  );

  expect(result, `No semantic element matched ${labelPattern}`).not.toBeNull();
  await page.mouse.click(result!.x, result!.y);
}

export async function collectSemanticNamesWhileScrolling(
  page: Page,
  scrolls = 12,
) {
  const seen = new Set<string>();
  for (let index = 0; index < scrolls; index += 1) {
    const names = await getSemanticNames(page);
    names.forEach((name) => seen.add(name));
    await page.mouse.wheel(0, 260);
    await page.waitForTimeout(250);
  }
  return [...seen];
}
