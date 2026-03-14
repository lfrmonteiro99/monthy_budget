import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/data/tax/tax_system.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/models/meal_settings.dart';

void main() {
  group('AppSettings serialization', () {
    test('round-trips core fields', () {
      final settings = AppSettings(
        personalInfo: const PersonalInfo(
          maritalStatus: MaritalStatus.casado,
          dependentes: 2,
          deficiente: true,
        ),
        salaries: const [
          SalaryInfo(
            label: 'Main Salary',
            grossAmount: 2500,
            enabled: true,
            titulares: 1,
            subsidyMode: SubsidyMode.full,
            mealAllowanceType: MealAllowanceType.card,
            mealAllowancePerDay: 9.5,
            otherExemptIncome: 50,
          ),
        ],
        expenses: const [
          ExpenseItem(
            id: 'rent',
            label: 'Rent',
            amount: 700,
            category: ExpenseCategory.habitacao,
            enabled: true,
          ),
        ],
        mealSettings: const MealSettings(glutenFree: true),
        stressHistory: const {'2026-02': 72},
        country: Country.es,
        localeOverride: 'es',
        setupWizardCompleted: true,
      );

      final decoded = AppSettings.fromJsonString(settings.toJsonString());

      expect(decoded.personalInfo.maritalStatus, MaritalStatus.casado);
      expect(decoded.personalInfo.dependentes, 2);
      expect(decoded.salaries.single.grossAmount, 2500);
      expect(decoded.salaries.single.subsidyMode, SubsidyMode.full);
      expect(decoded.expenses.single.category, ExpenseCategory.habitacao);
      expect(decoded.mealSettings.glutenFree, isTrue);
      expect(decoded.country, Country.es);
      expect(decoded.localeOverride, 'es');
      expect(decoded.stressHistory['2026-02'], 72);
      expect(decoded.setupWizardCompleted, isTrue);
    });

    test('copyWith can clear localeOverride explicitly', () {
      final updated = const AppSettings(localeOverride: 'pt').copyWith(
        localeOverride: null,
      );

      expect(updated.localeOverride, isNull);
    });

    test('fromJsonString defaults setupWizardCompleted to true for legacy rows', () {
      const legacyJson = '''
{
  "personalInfo": {},
  "salaries": [],
  "expenses": [],
  "country": "pt"
}
''';
      final decoded = AppSettings.fromJsonString(legacyJson);
      expect(decoded.setupWizardCompleted, isTrue);
    });
  });
}
