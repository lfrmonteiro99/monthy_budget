import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/services/quick_action_service.dart';

void main() {
  group('QuickAction.fromType', () {
    test('returns correct action for each known type', () {
      expect(QuickAction.fromType('quick_add_expense'), QuickAction.addExpense);
      expect(
          QuickAction.fromType('quick_add_shopping'), QuickAction.addShopping);
      expect(QuickAction.fromType('open_meals'), QuickAction.openMeals);
      expect(QuickAction.fromType('open_assistant'), QuickAction.openAssistant);
      expect(QuickAction.fromType('scan_receipt'), QuickAction.scanReceipt);
    });

    test('returns null for unknown type', () {
      expect(QuickAction.fromType('unknown'), isNull);
      expect(QuickAction.fromType(''), isNull);
    });

    test('returns null for null input', () {
      expect(QuickAction.fromType(null), isNull);
    });
  });

  group('QuickAction enum', () {
    test('each value has a unique type string', () {
      final types = QuickAction.values.map((a) => a.type).toSet();
      expect(types.length, QuickAction.values.length);
    });

    test('scanReceipt enum value exists with correct type', () {
      expect(QuickAction.scanReceipt.type, 'scan_receipt');
    });

    test('has 5 values', () {
      expect(QuickAction.values, hasLength(5));
    });
  });
}
