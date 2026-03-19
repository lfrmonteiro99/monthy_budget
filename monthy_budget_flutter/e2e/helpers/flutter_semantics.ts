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
    ? [page.getByRole(options.role as never, { name: labelPattern })]
    : [
        page.getByLabel(labelPattern),
        page.getByRole('button', { name: labelPattern }),
        page.getByRole('tab', { name: labelPattern }),
        page.getByRole('link', { name: labelPattern }),
        page.getByText(labelPattern),
      ];

  for (const locator of candidates) {
    const count = await locator.count();

    for (let index = 0; index < count; index += 1) {
      const candidate = locator.nth(index);
      const box = await candidate.boundingBox();

      if (box && box.width > 0 && box.height > 0) {
        return candidate;
      }
    }

    if (count > 0) {
      return locator.first();
    }
  }

  return null;
}

async function clickLocatorCenter(page: Page, locator: Locator) {
  await locator.evaluate((element) => {
    element.scrollIntoView({ block: 'center', inline: 'center' });
  });

  const box = await locator.boundingBox();
  expect(box, 'Semantic element has no clickable bounding box').not.toBeNull();

  await page.mouse.click(box!.x + box!.width / 2, box!.y + box!.height / 2);
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
  await clickLocatorCenter(page, locator!);
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

  await clickLocatorCenter(page, locator);
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
