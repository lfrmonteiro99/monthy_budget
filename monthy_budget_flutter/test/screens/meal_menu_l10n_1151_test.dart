import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';

void main() {
  late S l10n;

  setUpAll(() async {
    l10n = await S.delegate.load(const Locale('en'));
  });

  group('meal_menu_screen l10n #1151', () {
    test('mealMenuThisWeekEyebrow exists and is not hardcoded PT', () {
      final value = l10n.mealMenuThisWeekEyebrow;
      expect(value, isNotEmpty);
      expect(value.toUpperCase(), isNot(equals('ESTA SEMANA')));
    });

    test('mealMenuTitle exists and is not hardcoded PT', () {
      final value = l10n.mealMenuTitle;
      expect(value, isNotEmpty);
      expect(value.toLowerCase(), isNot(equals('ementa')));
    });

    test('mealMenuGenerateLabel exists and is not hardcoded PT', () {
      final value = l10n.mealMenuGenerateLabel;
      expect(value, isNotEmpty);
      expect(value.toLowerCase(), isNot(equals('gerar')));
    });

    test('mealMenuWeekSummaryEyebrow exists and is not hardcoded PT', () {
      final value = l10n.mealMenuWeekSummaryEyebrow;
      expect(value, isNotEmpty);
      expect(value.toUpperCase(), isNot(contains('RESUMO')));
    });

    test('mealMenuKpiMealsPlannedLabel exists', () {
      expect(l10n.mealMenuKpiMealsPlannedLabel, isNotEmpty);
    });

    test('mealMenuKpiMealsPlannedValue contains count', () {
      final value = l10n.mealMenuKpiMealsPlannedValue(14);
      expect(value, contains('14'));
    });

    test('mealMenuKpiCostEstimatedLabel exists', () {
      expect(l10n.mealMenuKpiCostEstimatedLabel, isNotEmpty);
    });

    test('mealMenuKpiCostPerPersonDayLabel exists', () {
      expect(l10n.mealMenuKpiCostPerPersonDayLabel, isNotEmpty);
    });

    test('mealMenuKpiOutsideLabel exists', () {
      expect(l10n.mealMenuKpiOutsideLabel, isNotEmpty);
    });

    test('mealMenuKpiOutsideValue uses ICU plural correctly', () {
      final singular = l10n.mealMenuKpiOutsideValue(1);
      final plural = l10n.mealMenuKpiOutsideValue(3);
      expect(singular, contains('1'));
      expect(plural, contains('3'));
      expect(singular, isNot(equals(plural)));
    });
  });
}
