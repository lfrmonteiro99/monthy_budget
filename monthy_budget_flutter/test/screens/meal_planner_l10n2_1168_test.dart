// TDD for issue #1168 — meal_planner_screen remaining l10n
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations_en.dart';

void main() {
  late SEn en;

  setUpAll(() {
    en = SEn();
  });

  tearDownAll(() {});

  test('mealPlannerMonthlyPlanEyebrow exists and is not hardcoded PT', () {
    expect(en.mealPlannerMonthlyPlanEyebrow, isNotNull);
    expect(en.mealPlannerMonthlyPlanEyebrow, isNot('PLANO DO MÊS'));
  });

  test('mealPlannerWeekEyebrow exists and is not hardcoded PT', () {
    expect(en.mealPlannerWeekEyebrow, isNotNull);
    expect(en.mealPlannerWeekEyebrow, isNot('SEMANA'));
  });
}
