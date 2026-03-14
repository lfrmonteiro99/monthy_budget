import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/data/tax/tax_factory.dart';
import 'package:monthly_management/data/tax/tax_system.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/utils/calculations.dart';

void main() {
  group('calculateMealAllowance', () {
    test('applies card exempt limit and taxes only taxable portion', () {
      final result = calculateMealAllowance(
        MealAllowanceType.card,
        12,
        22,
        0.2,
        0.11,
      );

      expect(result.totalMonthly, 264);
      expect(result.exemptPortion, 224.4);
      expect(result.taxablePortion, 39.6);
      expect(result.irsTaxOnMeal, 7.92);
      expect(result.ssTaxOnMeal, closeTo(4.36, 0.01));
      expect(result.netMealAllowance, closeTo(251.72, 0.01));
    });

    test('returns zeroed calculation for invalid input', () {
      final result = calculateMealAllowance(
        MealAllowanceType.none,
        0,
        0,
        0.2,
        0.11,
      );

      expect(result.totalMonthly, 0);
      expect(result.netMealAllowance, 0);
    });
  });

  group('calculateBudgetSummary', () {
    test('uses monthlyBudgets for variable expenses and fixed amounts for fixed', () {
      final taxSystem = getTaxSystem(Country.pt);
      final settings = AppSettings(
        salaries: const [
          SalaryInfo(
            label: 'Salary 1',
            grossAmount: 1800,
            enabled: true,
            subsidyMode: SubsidyMode.none,
          ),
        ],
        personalInfo: const PersonalInfo(
          maritalStatus: MaritalStatus.solteiro,
          dependentes: 0,
        ),
        expenses: const [
          ExpenseItem(
            id: 'rent',
            label: 'Rent',
            category: 'habitacao',
            amount: 700,
            isFixed: true,
          ),
          ExpenseItem(
            id: 'food',
            label: 'Food',
            category: 'alimentacao',
            amount: 500,
            isFixed: false,
          ),
        ],
      );

      final summary = calculateBudgetSummary(
        settings.salaries,
        settings.personalInfo,
        settings.expenses,
        taxSystem,
        monthlyBudgets: const {'alimentacao': 320},
      );

      expect(summary.totalExpenses, 1020);
      expect(summary.totalNetWithMeal, greaterThan(0));
      expect(summary.netLiquidity, closeTo(summary.totalNetWithMeal - 1020, 0.01));
    });

    test('returns zero savings rate when net income is zero', () {
      final summary = calculateBudgetSummary(
        const [],
        const PersonalInfo(),
        const [
          ExpenseItem(
            id: 'a',
            amount: 200,
            category: 'outros',
          ),
        ],
        getTaxSystem(Country.pt),
      );

      expect(summary.totalNetWithMeal, 0);
      expect(summary.savingsRate, 0);
    });
  });
}
