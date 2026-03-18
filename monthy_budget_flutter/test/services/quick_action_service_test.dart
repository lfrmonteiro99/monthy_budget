import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/constants/app_constants.dart';
import 'package:monthly_management/navigation/app_route.dart';
import 'package:monthly_management/services/quick_action_service.dart';

void main() {
  group('QuickActionService.routeFromUri', () {
    test('parses supported deep links into typed routes', () {
      expect(
        QuickActionService.routeFromUri(
          Uri.parse('orcamentomensal://quick-add/expense'),
        ),
        const AppRoute.addExpense(),
      );
      expect(
        QuickActionService.routeFromUri(
          Uri.parse('orcamentomensal://quick-add/shopping'),
        ),
        const AppRoute.shoppingList(),
      );
      expect(
        QuickActionService.routeFromUri(Uri.parse('orcamentomensal://meals')),
        const AppRoute.mealPlanner(),
      );
      expect(
        QuickActionService.routeFromUri(
          Uri.parse('orcamentomensal://dashboard'),
        ),
        const AppRoute.tab(AppTab.dashboard),
      );
    });

    test('returns null for unsupported links', () {
      expect(
        QuickActionService.routeFromUri(Uri.parse('orcamentomensal://unknown')),
        isNull,
      );
      expect(
        QuickActionService.routeFromUri(Uri.parse('https://example.com')),
        isNull,
      );
    });
  });

  group('AppRoute command and feature mapping', () {
    test('maps command targets to typed routes', () {
      expect(
        AppRoute.fromCommandTarget('expenses'),
        const AppRoute.tab(AppTab.expenses),
      );
      expect(AppRoute.fromCommandTarget('settings'), const AppRoute.settings());
      expect(AppRoute.fromCommandTarget('coach'), const AppRoute.coach());
    });

    test('maps feature discovery targets to typed routes', () {
      expect(
        AppRoute.fromFeatureKey('meal_planner'),
        const AppRoute.mealPlanner(),
      );
      expect(
        AppRoute.fromFeatureKey('shopping_list'),
        const AppRoute.tab(AppTab.planHub),
      );
      expect(
        AppRoute.fromFeatureKey('tax_simulator'),
        const AppRoute.settings(),
      );
    });
  });
}
