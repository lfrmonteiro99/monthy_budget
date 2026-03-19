import { expect, test } from '@playwright/test';

import {
  hasAuthCredentials,
  isAuthenticated,
  login,
  logout,
  openApp,
} from './helpers/auth';
import {
  enableFlutterSemantics,
  waitForSemanticMatch,
} from './helpers/flutter_semantics';

test.describe('Authentication smoke', () => {
  test.skip(
    !hasAuthCredentials(),
    'Set E2E_EMAIL and E2E_PASSWORD to run authenticated Playwright smoke tests.',
  );

  test('login restores session on reload and can sign out', async ({ page }) => {
    await openApp(page);
    await login(page);

    await expect.poll(async () => isAuthenticated(page)).toBe(true);

    await page.reload();
    await page.waitForTimeout(4000);
    await enableFlutterSemantics(page);
    await waitForSemanticMatch(page, /Home|Track|Shop/i);

    await logout(page);
    await waitForSemanticMatch(page, /Sign in|Entrar na conta|Entrar/i);
  });
});
