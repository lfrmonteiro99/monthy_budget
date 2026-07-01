import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/data/tax/tax_factory.dart';
import 'package:monthly_management/data/tax/tax_system.dart';
import 'package:monthly_management/models/app_settings.dart';
import 'package:monthly_management/utils/calculations.dart';

void main() {
  final ptSystem = getTaxSystem(Country.pt);

  const personal = PersonalInfo(
    maritalStatus: MaritalStatus.solteiro,
    dependentes: 0,
  );

  SalaryInfo salaryWith(SubsidyMode mode) => SalaryInfo(
        label: 'Test',
        grossAmount: 1500,
        enabled: true,
        subsidyMode: mode,
      );

  group('subsidyMode in calculateNetSalary', () {
    test('SubsidyMode.none: effectiveGross equals grossAmount', () {
      final result = calculateNetSalary(salaryWith(SubsidyMode.none), personal, ptSystem);
      expect(result.effectiveGrossAmount, closeTo(1500.0, 0.01));
      expect(result.subsidyMonthlyBonus, closeTo(0.0, 0.01));
    });

    test('SubsidyMode.full: effectiveGross = grossAmount × 14/12', () {
      final result = calculateNetSalary(salaryWith(SubsidyMode.full), personal, ptSystem);
      expect(result.effectiveGrossAmount, closeTo(1500.0 * 14 / 12, 0.02));
      expect(result.subsidyMonthlyBonus, greaterThan(0.0));
    });

    test('SubsidyMode.half: effectiveGross = grossAmount × 13/12', () {
      final result = calculateNetSalary(salaryWith(SubsidyMode.half), personal, ptSystem);
      expect(result.effectiveGrossAmount, closeTo(1500.0 * 13 / 12, 0.02));
    });

    test('full-mode net is higher than none-mode net', () {
      final none = calculateNetSalary(salaryWith(SubsidyMode.none), personal, ptSystem);
      final full = calculateNetSalary(salaryWith(SubsidyMode.full), personal, ptSystem);
      expect(full.totalNetWithMeal, greaterThan(none.totalNetWithMeal),
          reason: 'duodécimos should increase total monthly net');
    });

    test('half-mode net is between none and full', () {
      final none = calculateNetSalary(salaryWith(SubsidyMode.none), personal, ptSystem);
      final half = calculateNetSalary(salaryWith(SubsidyMode.half), personal, ptSystem);
      final full = calculateNetSalary(salaryWith(SubsidyMode.full), personal, ptSystem);
      expect(half.totalNetWithMeal, greaterThan(none.totalNetWithMeal));
      expect(half.totalNetWithMeal, lessThan(full.totalNetWithMeal));
    });
  });
}
