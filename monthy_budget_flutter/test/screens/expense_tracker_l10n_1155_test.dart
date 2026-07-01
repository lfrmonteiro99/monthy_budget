import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';

void main() {
  late S l10n;

  setUpAll(() async {
    l10n = await S.delegate.load(const Locale('en'));
  });

  group('expense_tracker_screen l10n #1155', () {
    test('expenseTrackerMovementEyebrow exists and is not hardcoded PT', () {
      final v = l10n.expenseTrackerMovementEyebrow;
      expect(v, isNotEmpty);
      expect(v.toUpperCase(), isNot(equals('MOVIMENTO')));
    });

    test('expenseTrackerExpensesTitle exists and is not hardcoded PT', () {
      final v = l10n.expenseTrackerExpensesTitle;
      expect(v, isNotEmpty);
      expect(v.toLowerCase(), isNot(equals('despesas')));
    });

    test('expenseTrackerThisMonthEyebrow exists and is not hardcoded PT', () {
      final v = l10n.expenseTrackerThisMonthEyebrow;
      expect(v, isNotEmpty);
      expect(v.toUpperCase(), isNot(contains('MÊS')));
    });

    test('expenseTrackerAvgPerDayEyebrow exists and is not hardcoded PT', () {
      final v = l10n.expenseTrackerAvgPerDayEyebrow;
      expect(v, isNotEmpty);
      expect(v.toUpperCase(), isNot(contains('MÉDIA')));
    });

    test('expenseTrackerBillsEyebrow exists and is not hardcoded PT', () {
      final v = l10n.expenseTrackerBillsEyebrow;
      expect(v, isNotEmpty);
      expect(v.toUpperCase(), isNot(equals('CONTAS')));
    });

    test('expenseTrackerBudgetedLabel contains amount', () {
      final v = l10n.expenseTrackerBudgetedLabel('€500.00');
      expect(v, contains('€500.00'));
    });

    test('expenseTrackerByCategoryEyebrow exists and is not hardcoded PT', () {
      final v = l10n.expenseTrackerByCategoryEyebrow;
      expect(v, isNotEmpty);
      expect(v.toUpperCase(), isNot(contains('CATEGORIA')));
    });

    test('expenseTrackerEmptyBody exists and is not hardcoded PT', () {
      final v = l10n.expenseTrackerEmptyBody;
      expect(v, isNotEmpty);
      expect(v.toLowerCase(), isNot(contains('adicione')));
    });
  });
}
