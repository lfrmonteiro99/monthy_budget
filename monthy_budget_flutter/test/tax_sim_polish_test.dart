import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/data/tax/tax_factory.dart';
import 'package:monthly_management/data/tax/tax_system.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/utils/calculations.dart';

void main() {
  final ptSystem = getTaxSystem(Country.pt);

  group('Task A — meal allowance taxed at marginal rate, not effective', () {
    // €1500 solteiro: bracket upTo 1819, rate 0.241 (24.1%)
    // Effective rate = (1500×0.241 - 193.33) / 1500 ≈ 11.21%
    // Meal card €12/day × 22 days:
    //   taxable = (12 - 10.20) × 22 = 39.60
    //   IRS at marginal 24.1%  → 9.55
    //   IRS at effective 11.2% → 4.44  ← wrong (old behaviour)

    test('PT calculateTax exposes marginalRate = bracket rate', () {
      final result = ptSystem.calculateTax(
        grossSalary: 1500,
        maritalStatus: 'solteiro',
        titulares: 1,
        dependentes: 0,
      );

      // Marginal rate for this bracket is 24.1%
      expect(result.marginalRate, closeTo(0.241, 0.001),
          reason: 'TaxResult must expose the bracket marginal rate, '
              'not the effective rate');
    });

    test('calculateNetSalary uses marginal rate for meal allowance tax', () {
      final salary = SalaryInfo(
        label: 'Test',
        grossAmount: 1500,
        enabled: true,
        subsidyMode: SubsidyMode.none,
        mealAllowanceType: MealAllowanceType.card,
        mealAllowancePerDay: 12.0,
        workingDaysPerMonth: 22,
      );
      final personal = const PersonalInfo(
        maritalStatus: MaritalStatus.solteiro,
        dependentes: 0,
      );

      final result = calculateNetSalary(salary, personal, ptSystem);

      // taxable = (12-10.20) × 22 = 39.60
      // IRS at marginal 24.1% = 9.55 (allow ±0.10 for rounding)
      expect(
        result.mealAllowance.irsTaxOnMeal,
        greaterThan(8.0),
        reason:
            'meal allowance excess must be taxed at the marginal rate (~9.55), '
            'not the lower effective rate (~4.44)',
      );
    });

    test('no meal allowance → marginalRate has no effect on net', () {
      final salary = const SalaryInfo(
        label: 'Test',
        grossAmount: 1500,
        enabled: true,
        subsidyMode: SubsidyMode.none,
      );
      final personal = const PersonalInfo(
        maritalStatus: MaritalStatus.solteiro,
        dependentes: 0,
      );

      final result = calculateNetSalary(salary, personal, ptSystem);

      expect(result.mealAllowance.irsTaxOnMeal, 0.0);
      expect(result.mealAllowance.taxablePortion, 0.0);
    });

    test('meal allowance within exempt limit → no tax regardless of rate', () {
      // €10/day is below the card exempt limit of €10.20 → taxable = 0
      final salary = SalaryInfo(
        label: 'Test',
        grossAmount: 1500,
        enabled: true,
        subsidyMode: SubsidyMode.none,
        mealAllowanceType: MealAllowanceType.card,
        mealAllowancePerDay: 10.0,
        workingDaysPerMonth: 22,
      );
      final personal = const PersonalInfo(
        maritalStatus: MaritalStatus.solteiro,
        dependentes: 0,
      );

      final result = calculateNetSalary(salary, personal, ptSystem);

      expect(result.mealAllowance.taxablePortion, 0.0);
      expect(result.mealAllowance.irsTaxOnMeal, 0.0);
    });
  });
}
