import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/constants/app_constants.dart';
import 'package:monthly_management/providers/navigation_providers.dart';

void main() {
  group('currentTabProvider', () {
    test('defaults to dashboard', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(currentTabProvider), AppTab.dashboard);
    });

    test('setTab updates the current tab', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(currentTabProvider.notifier).setTab(AppTab.planHub);

      expect(container.read(currentTabProvider), AppTab.planHub);
    });

    test('notifies listeners on change', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final seen = <AppTab>[];
      container.listen<AppTab>(
        currentTabProvider,
        (_, next) => seen.add(next),
        fireImmediately: false,
      );

      container.read(currentTabProvider.notifier).setTab(AppTab.expenses);
      container.read(currentTabProvider.notifier).setTab(AppTab.more);

      expect(seen, [AppTab.expenses, AppTab.more]);
    });
  });
}
