import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/services/quick_action_service.dart';

void main() {
  group('QuickAction.fromType', () {
    test('maps known types correctly', () {
      expect(QuickAction.fromType('quick_add_expense'), QuickAction.addExpense);
      expect(QuickAction.fromType('quick_add_shopping'), QuickAction.addShopping);
      expect(QuickAction.fromType('open_meals'), QuickAction.openMeals);
      expect(QuickAction.fromType('open_assistant'), QuickAction.openAssistant);
      expect(QuickAction.fromType('scan_receipt'), QuickAction.scanReceipt);
    });

    test('returns null for unknown type', () {
      expect(QuickAction.fromType('unknown'), isNull);
    });

    test('returns null for null', () {
      expect(QuickAction.fromType(null), isNull);
    });
  });

  group('Deep link URI host mapping', () {
    // Mirrors the logic from MainActivity.kt handleIntent()
    String? mapUriToActionType(String scheme, String host, String? path) {
      if (scheme != 'orcamentomensal') return null;
      if (host == 'quick-add' && path == '/expense') return 'quick_add_expense';
      if (host == 'quick-add' && path == '/shopping') return 'quick_add_shopping';
      if (host == 'quick-add' && path == '/receipt') return 'scan_receipt';
      if (host == 'quick-add') return 'quick_add_expense'; // default
      if (host == 'meals') return 'open_meals';
      if (host == 'assistant') return 'open_assistant';
      return null;
    }

    test('quick-add/expense maps to addExpense', () {
      final type = mapUriToActionType('orcamentomensal', 'quick-add', '/expense');
      expect(QuickAction.fromType(type), QuickAction.addExpense);
    });

    test('quick-add/shopping maps to addShopping', () {
      final type = mapUriToActionType('orcamentomensal', 'quick-add', '/shopping');
      expect(QuickAction.fromType(type), QuickAction.addShopping);
    });

    test('quick-add/receipt maps to scanReceipt', () {
      final type = mapUriToActionType('orcamentomensal', 'quick-add', '/receipt');
      expect(QuickAction.fromType(type), QuickAction.scanReceipt);
    });

    test('bare quick-add defaults to addExpense', () {
      final type = mapUriToActionType('orcamentomensal', 'quick-add', null);
      expect(QuickAction.fromType(type), QuickAction.addExpense);
    });

    test('meals maps to openMeals', () {
      final type = mapUriToActionType('orcamentomensal', 'meals', null);
      expect(QuickAction.fromType(type), QuickAction.openMeals);
    });

    test('assistant maps to openAssistant', () {
      final type = mapUriToActionType('orcamentomensal', 'assistant', null);
      expect(QuickAction.fromType(type), QuickAction.openAssistant);
    });

    test('unknown host returns null', () {
      final type = mapUriToActionType('orcamentomensal', 'unknown', null);
      expect(type, isNull);
    });

    test('wrong scheme returns null', () {
      final type = mapUriToActionType('https', 'meals', null);
      expect(type, isNull);
    });
  });
}
