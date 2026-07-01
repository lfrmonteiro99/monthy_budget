// TDD for issue #1163 — meal_planner_screen l10n
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations_en.dart';

void main() {
  late SEn en;

  setUpAll(() {
    en = SEn();
  });

  tearDownAll(() {});

  test('mealPlannerDetailEyebrow exists and is not hardcoded PT', () {
    expect(en.mealPlannerDetailEyebrow, isNotNull);
    expect(en.mealPlannerDetailEyebrow, isNot('DETALHE'));
  });

  test('mealPlannerMealsEyebrow exists and is not hardcoded PT', () {
    expect(en.mealPlannerMealsEyebrow, isNotNull);
    expect(en.mealPlannerMealsEyebrow, isNot('REFEIÇÕES'));
  });
}
