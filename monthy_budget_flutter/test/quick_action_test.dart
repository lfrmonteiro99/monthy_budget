import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/constants/app_constants.dart';
import 'package:monthly_management/navigation/app_route.dart';

void main() {
  group('AppRoute.fromUri', () {
    test('maps quick-add URIs correctly', () {
      expect(
        AppRoute.fromUri(Uri.parse('orcamentomensal://quick-add/expense')),
        const AppRoute.addExpense(),
      );
      expect(
        AppRoute.fromUri(Uri.parse('orcamentomensal://quick-add/shopping')),
        const AppRoute.shoppingList(),
      );
      expect(
        AppRoute.fromUri(Uri.parse('orcamentomensal://quick-add/receipt')),
        const AppRoute.scanReceipt(),
      );
    });

    test('maps meals and assistant URIs correctly', () {
      expect(
        AppRoute.fromUri(Uri.parse('orcamentomensal://meals')),
        const AppRoute.mealPlanner(),
      );
      expect(
        AppRoute.fromUri(Uri.parse('orcamentomensal://assistant')),
        const AppRoute.assistant(),
      );
    });

    test('maps tab and settings URIs correctly', () {
      expect(
        AppRoute.fromUri(Uri.parse('orcamentomensal://dashboard')),
        const AppRoute.tab(AppTab.dashboard),
      );
      expect(
        AppRoute.fromUri(Uri.parse('orcamentomensal://expenses')),
        const AppRoute.tab(AppTab.expenses),
      );
      expect(
        AppRoute.fromUri(Uri.parse('orcamentomensal://settings/meals')),
        const AppRoute.settings(section: SettingsSection.meals),
      );
    });

    test('returns null for unsupported URIs', () {
      expect(AppRoute.fromUri(Uri.parse('https://example.com/meals')), isNull);
      expect(AppRoute.fromUri(Uri.parse('orcamentomensal://unknown')), isNull);
    });
  });
}
