import { expect, Locator, Page } from '@playwright/test';

type SemanticOptions = {
  role?: string;
};

async function findSemanticLocator(
  page: Page,
  labelPattern: RegExp,
  options: SemanticOptions = {},
) {
  const candidates: Locator[] = options.role
    ? [page.getByRole(options.role as never, { name: labelPattern }).first()]
    : [
        page.getByLabel(labelPattern).first(),
        page.getByRole('button', { name: labelPattern }).first(),
        page.getByRole('tab', { name: labelPattern }).first(),
        page.getByRole('link', { name: labelPattern }).first(),
        page.getByText(labelPattern).first(),
      ];

  for (const locator of candidates) {
    if ((await locator.count()) > 0) {
      return locator;
    }
  }

  return null;
}

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
    const labels = new Set<string>();
    const addText = (value?: string | null) => {
      value
        ?.split('\n')
        .map((part) => part.replace(/\s+/g, ' ').trim())
        .filter(Boolean)
        .forEach((part) => labels.add(part));
    };

    addText(document.body?.innerText);

    document.querySelectorAll('body *').forEach((element) => {
      addText(element.getAttribute('aria-label'));
      addText((element as HTMLElement).innerText);
      addText(element.textContent);
    });

    return [...labels];
  });
}

export async function clickSemantic(
  page: Page,
  labelPattern: RegExp,
  options: SemanticOptions = {},
) {
  const locator = await findSemanticLocator(page, labelPattern, options);
  expect(locator, `No semantic element matched ${labelPattern}`).not.toBeNull();
  await locator!.scrollIntoViewIfNeeded();
  await locator!.click();
}

export async function tryClickSemantic(
  page: Page,
  labelPattern: RegExp,
  options: SemanticOptions = {},
) {
  const locator = await findSemanticLocator(page, labelPattern, options);
  if (!locator) {
    return false;
  }

  await locator.scrollIntoViewIfNeeded();
  await locator.click();
  return true;
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

export async function hasSemanticMatch(page: Page, pattern: RegExp) {
  const names = await getSemanticNames(page);
  return names.some((name) => pattern.test(name));
}

export async function waitForSemanticMatch(
  page: Page,
  pattern: RegExp,
  timeoutMs = 20_000,
) {
  const startedAt = Date.now();
  while (Date.now() - startedAt < timeoutMs) {
    if (await hasSemanticMatch(page, pattern)) {
      return;
    }
    await page.waitForTimeout(500);
  }

  const names = await getSemanticNames(page);
  throw new Error(
    `Timed out waiting for semantic match ${pattern}. Current semantics: ${names.join(' | ')}`,
  );
}
