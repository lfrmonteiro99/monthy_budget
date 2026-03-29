import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/data/tax/es_tax_system.dart';
import 'package:monthly_management/data/tax/fr_tax_system.dart';
import 'package:monthly_management/data/tax/pt_tax_system.dart';
import 'package:monthly_management/data/tax/tax_factory.dart';
import 'package:monthly_management/data/tax/tax_system.dart';
import 'package:monthly_management/data/irs_tables.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/utils/calculations.dart';

void main() {
  // ─── Portugal IRS 2026 ──────────────────────────────────────────────
  group('Portugal IRS 2026', () {
    final pt = PtTaxSystem();

    test('zero tax below minimum existence (920€)', () {
      final r = pt.calculateTax(
        grossSalary: 900,
        maritalStatus: 'solteiro',
        titulares: 1,
        dependentes: 0,
      );
      expect(r.incomeTax, 0);
      expect(r.socialContribution, closeTo(99.0, 0.01)); // 900 * 0.11
    });

    test('Table I: single, no dependents, 1500€', () {
      final r = pt.calculateTax(
        grossSalary: 1500,
        maritalStatus: 'solteiro',
        titulares: 1,
        dependentes: 0,
      );
      // Bracket: up to 1819€ → rate 24.1%, parcela 193.33, dep 0
      // IRS = 1500 * 0.241 - 193.33 = 361.50 - 193.33 = 168.17
      expect(r.incomeTax, closeTo(168.17, 0.5));
      expect(r.socialContribution, closeTo(165.0, 0.01));
      expect(r.netSalary, closeTo(1500 - 168.17 - 165.0, 1.0));
    });

    test('Table I: single, no dependents, 2500€', () {
      final r = pt.calculateTax(
        grossSalary: 2500,
        maritalStatus: 'solteiro',
        titulares: 1,
        dependentes: 0,
      );
      // Bracket: up to 2499€ → actually 2500 falls in next bracket (3305)
      // Rate 38.36%, parcela 487.66
      // IRS = 2500 * 0.3836 - 487.66 = 959.00 - 487.66 = 471.34
      expect(r.incomeTax, closeTo(471.34, 0.5));
    });

    test('Table II: single with 1 dependent, 2000€', () {
      final r = pt.calculateTax(
        grossSalary: 2000,
        maritalStatus: 'solteiro',
        titulares: 1,
        dependentes: 1,
      );
      // Table II: bracket 1819-2119, rate 31.1%, parcela 320.66, dep 34.29
      // IRS = 2000 * 0.311 - 320.66 - 34.29*1 = 622.0 - 320.66 - 34.29 = 267.05
      expect(r.incomeTax, closeTo(267.05, 0.5));
    });

    test('Table III: married, sole earner, 2500€', () {
      final r = pt.calculateTax(
        grossSalary: 2500,
        maritalStatus: 'casado',
        titulares: 1,
        dependentes: 0,
      );
      // Table III: bracket 2240-2773, rate 22.77%, parcela 289.47, dep 0
      // IRS = 2500 * 0.2277 - 289.47 = 569.25 - 289.47 = 279.78
      expect(r.incomeTax, closeTo(279.78, 0.5));
    });

    test('Table III: married, sole earner, 2500€, 2 dependents', () {
      final r = pt.calculateTax(
        grossSalary: 2500,
        maritalStatus: 'casado',
        titulares: 1,
        dependentes: 2,
      );
      // IRS = 2500 * 0.2277 - 289.47 - 42.86*2 = 569.25 - 289.47 - 85.72 = 194.06
      expect(r.incomeTax, closeTo(194.06, 0.5));
    });

    test('Social Security is always 11%', () {
      expect(pt.socialContributionRate, 0.11);
      expect(pt.calculateSocialContribution(2000), closeTo(220.0, 0.01));
    });

    test('IRS table selection logic', () {
      expect(getApplicableTable('solteiro', 1, 0).id, 'table_I');
      expect(getApplicableTable('solteiro', 1, 1).id, 'table_II');
      expect(getApplicableTable('casado', 2, 0).id, 'table_I');
      expect(getApplicableTable('casado', 1, 0).id, 'table_III');
      expect(getApplicableTable('uniao_facto', 1, 0).id, 'table_III');
      expect(getApplicableTable('divorciado', 1, 2).id, 'table_II');
    });
  });

  // ─── Spain IRPF 2026 ───────────────────────────────────────────────
  group('Spain IRPF 2026', () {
    final es = EsTaxSystem();

    test('zero tax for zero salary', () {
      final r = es.calculateTax(
        grossSalary: 0,
        maritalStatus: 'solteiro',
        titulares: 1,
        dependentes: 0,
      );
      expect(r.incomeTax, 0);
      expect(r.netSalary, 0);
    });

    test('mínimo personal reduces tax for low salary', () {
      // 1000€/month = 12000€/year, below mínimo personal of 5550€ taxable base
      // Gross tax on 12000 = 12000 * 0.19 = 2280
      // Mínimo tax on 5550 = 5550 * 0.19 = 1054.50
      // Net IRPF = 2280 - 1054.50 = 1225.50 / 12 = ~102.13
      final r = es.calculateTax(
        grossSalary: 1000,
        maritalStatus: 'solteiro',
        titulares: 1,
        dependentes: 0,
      );
      expect(r.incomeTax, closeTo(102.13, 0.5));
    });

    test('mínimo personal + descendientes reduces tax further', () {
      final noKids = es.calculateTax(
        grossSalary: 2500,
        maritalStatus: 'solteiro',
        titulares: 1,
        dependentes: 0,
      );
      final withKids = es.calculateTax(
        grossSalary: 2500,
        maritalStatus: 'solteiro',
        titulares: 1,
        dependentes: 2,
      );
      // 2 kids = 2400 + 2700 = 5100€ extra deduction
      expect(withKids.incomeTax, lessThan(noKids.incomeTax));
      // The difference should be roughly the tax on 5100€ at marginal rate
      expect(noKids.incomeTax - withKids.incomeTax, greaterThan(50));
    });

    test('2500€ single no dependents — known values', () {
      // Annual gross = 30000
      // Gross tax: 12450*0.19 + 7750*0.24 + 9800*0.30 = 2365.5 + 1860 + 2940 = 7165.50
      // Mínimo (5550): 5550*0.19 = 1054.50
      // Net annual tax = 7165.50 - 1054.50 = 6111.00
      // Monthly = 6111 / 12 = 509.25
      final r = es.calculateTax(
        grossSalary: 2500,
        maritalStatus: 'solteiro',
        titulares: 1,
        dependentes: 0,
      );
      expect(r.incomeTax, closeTo(509.25, 0.5));
      expect(r.socialContribution, closeTo(158.75, 0.01)); // 2500 * 0.0635
    });

    test('Social Security is 6.35%', () {
      expect(es.socialContributionRate, 0.0635);
    });
  });

  // ─── France IR 2026 ─────────────────────────────────────────────────
  group('France IR 2026', () {
    final fr = FrTaxSystem();

    test('zero tax for zero salary', () {
      final r = fr.calculateTax(
        grossSalary: 0,
        maritalStatus: 'solteiro',
        titulares: 1,
        dependentes: 0,
      );
      expect(r.incomeTax, 0);
      expect(r.netSalary, 0);
    });

    test('no income tax below 11600€ annual (966€/month)', () {
      final r = fr.calculateTax(
        grossSalary: 900,
        maritalStatus: 'solteiro',
        titulares: 1,
        dependentes: 0,
      );
      // 900 * 12 = 10800 < 11600 → 0% bracket → no income tax
      expect(r.incomeTax, 0);
      expect(r.socialContribution, closeTo(87.30, 0.01)); // 900 * 0.097
    });

    test('2500€ single — uses 2026 brackets', () {
      // Annual = 30000, 1 part
      // 0-11600: 0, 11600-29579: (29579-11600)*0.11 = 1977.69, 29579-30000: 421*0.30 = 126.30
      // Total annual = 2103.99, monthly = 175.33
      final r = fr.calculateTax(
        grossSalary: 2500,
        maritalStatus: 'solteiro',
        titulares: 1,
        dependentes: 0,
      );
      expect(r.incomeTax, closeTo(175.33, 1.0));
      expect(r.socialContribution, closeTo(242.50, 0.01)); // 2500 * 0.097
    });

    test('quotient familial: married couple pays less than single', () {
      final single = fr.calculateTax(
        grossSalary: 3000,
        maritalStatus: 'solteiro',
        titulares: 1,
        dependentes: 0,
      );
      final married = fr.calculateTax(
        grossSalary: 3000,
        maritalStatus: 'casado',
        titulares: 1,
        dependentes: 0,
      );
      // Married has 2 parts → income/2 per part → lower marginal rate
      expect(married.incomeTax, lessThan(single.incomeTax));
    });

    test('quotient familial: dependents reduce tax', () {
      final noKids = fr.calculateTax(
        grossSalary: 4000,
        maritalStatus: 'casado',
        titulares: 1,
        dependentes: 0,
      );
      final withKids = fr.calculateTax(
        grossSalary: 4000,
        maritalStatus: 'casado',
        titulares: 1,
        dependentes: 2,
      );
      // 2 kids → 2 + 0.5 + 0.5 = 3 parts (vs 2 parts)
      expect(withKids.incomeTax, lessThan(noKids.incomeTax));
    });

    test('social contributions are 9.7% (CSG+CRDS)', () {
      expect(fr.socialContributionRate, 0.097);
    });
  });

  // ─── Cross-country comparisons ──────────────────────────────────────
  group('Cross-country', () {
    test('all systems produce consistent results for 2000€', () {
      for (final country in Country.values) {
        final system = getTaxSystem(country);
        final r = system.calculateTax(
          grossSalary: 2000,
          maritalStatus: 'solteiro',
          titulares: 1,
          dependentes: 0,
        );
        expect(r.netSalary, greaterThan(0), reason: '${country.name} net > 0');
        expect(r.netSalary, lessThan(2000), reason: '${country.name} net < gross');
        expect(r.incomeTax + r.socialContribution, greaterThan(0),
            reason: '${country.name} deductions > 0');
        expect(r.incomeTaxRate, greaterThanOrEqualTo(0),
            reason: '${country.name} rate >= 0');
        expect(r.incomeTaxRate, lessThan(1),
            reason: '${country.name} rate < 100%');
      }
    });

    test('higher salary always means higher tax', () {
      for (final country in Country.values) {
        final system = getTaxSystem(country);
        final low = system.calculateTax(
          grossSalary: 1500,
          maritalStatus: 'solteiro',
          titulares: 1,
          dependentes: 0,
        );
        final high = system.calculateTax(
          grossSalary: 5000,
          maritalStatus: 'solteiro',
          titulares: 1,
          dependentes: 0,
        );
        expect(high.incomeTax, greaterThan(low.incomeTax),
            reason: '${country.name}: 5000€ tax > 1500€ tax');
      }
    });
  });

  // ─── Salary calculation with meal allowance ─────────────────────────
  group('Net salary with meal allowance (PT)', () {
    final taxSystem = getTaxSystem(Country.pt);

    test('meal allowance card increases total net', () {
      final salaryWithMeal = SalaryInfo(
        label: 'Test',
        grossAmount: 1500,
        enabled: true,
        mealAllowanceType: MealAllowanceType.card,
        mealAllowancePerDay: 9.60,
        workingDaysPerMonth: 22,
      );
      final salaryNoMeal = SalaryInfo(
        label: 'Test',
        grossAmount: 1500,
        enabled: true,
        mealAllowanceType: MealAllowanceType.none,
      );
      final personal = const PersonalInfo();

      final withMeal = calculateNetSalary(salaryWithMeal, personal, taxSystem);
      final noMeal = calculateNetSalary(salaryNoMeal, personal, taxSystem);

      // Net salary (before meal) should be the same
      expect(withMeal.netAmount, noMeal.netAmount);
      // Total net with meal should be higher
      expect(withMeal.totalNetWithMeal, greaterThan(noMeal.totalNetWithMeal));
      // Meal allowance should be ~211.20 (9.60 * 22, all exempt since < 10.20)
      expect(withMeal.mealAllowance.totalMonthly, closeTo(211.20, 0.01));
      expect(withMeal.mealAllowance.taxablePortion, 0); // 9.60 < 10.20 limit
    });

    test('meal allowance cash has taxable portion above 6€', () {
      final salary = SalaryInfo(
        label: 'Test',
        grossAmount: 1500,
        enabled: true,
        mealAllowanceType: MealAllowanceType.cash,
        mealAllowancePerDay: 8.00,
        workingDaysPerMonth: 22,
      );
      final personal = const PersonalInfo();
      final calc = calculateNetSalary(salary, personal, taxSystem);

      // Taxable = (8.00 - 6.00) * 22 = 44.00
      expect(calc.mealAllowance.taxablePortion, closeTo(44.0, 0.01));
      expect(calc.mealAllowance.irsTaxOnMeal, greaterThan(0));
      expect(calc.mealAllowance.ssTaxOnMeal, greaterThan(0));
    });

    test('subsidy mode duodécimos increases effective gross', () {
      final full = SalaryInfo(
        label: 'Test',
        grossAmount: 1500,
        enabled: true,
        subsidyMode: SubsidyMode.full,
      );
      final none = SalaryInfo(
        label: 'Test',
        grossAmount: 1500,
        enabled: true,
        subsidyMode: SubsidyMode.none,
      );
      final personal = const PersonalInfo();

      final fullCalc = calculateNetSalary(full, personal, taxSystem);
      final noneCalc = calculateNetSalary(none, personal, taxSystem);

      // Full duodécimos: effective = 1500 * 14/12 = 1750
      expect(fullCalc.effectiveGrossAmount, closeTo(1750, 0.01));
      expect(noneCalc.effectiveGrossAmount, 1500);
      // Full duodécimos yields higher effective gross but also more tax
      expect(fullCalc.effectiveGrossAmount, greaterThan(noneCalc.effectiveGrossAmount));
    });
  });
}
