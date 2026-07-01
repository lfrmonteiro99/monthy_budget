import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';

void main() {
  late S l10n;

  setUpAll(() async {
    l10n = await S.delegate.load(const Locale('en'));
  });

  group('expense widget l10n #1149', () {
    test('expenseAlertsEyebrow exists and is not hardcoded PT', () {
      final value = l10n.expenseAlertsEyebrow;
      expect(value, isNotEmpty);
      expect(value.toUpperCase(), isNot(equals('ALERTAS')));
    });

    test('expenseAlertsBudgetSubtitle contains both currency values', () {
      final value = l10n.expenseAlertsBudgetSubtitle('€100.00', '€80.00');
      expect(value, contains('€100.00'));
      expect(value, contains('€80.00'));
      expect(value.toLowerCase(), isNot(contains('orç.')));
    });

    test('expenseRecentEyebrow exists and is not hardcoded PT', () {
      final value = l10n.expenseRecentEyebrow;
      expect(value, isNotEmpty);
      expect(value.toUpperCase(), isNot(equals('RECENTES')));
    });

    test('expenseRecentViewAll exists and is not hardcoded PT', () {
      final value = l10n.expenseRecentViewAll;
      expect(value, isNotEmpty);
      expect(value.toLowerCase(), isNot(contains('ver todas')));
    });

    test('expenseRecentCountSubtitle contains count', () {
      final value = l10n.expenseRecentCountSubtitle(5);
      expect(value, contains('5'));
    });

    test('expenseSearchResultsEyebrow exists and is not hardcoded PT', () {
      final value = l10n.expenseSearchResultsEyebrow;
      expect(value, isNotEmpty);
      expect(value.toUpperCase(), isNot(equals('RESULTADOS')));
    });
  });
}
