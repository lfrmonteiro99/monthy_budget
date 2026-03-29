import 'dart:math' as math;
import 'tax_system.dart';

/// France IR tax system (2026 rates — revenus 2025)
/// Barème progressif revalorisé de +0,9% (Loi de Finances 2026)
/// 5 tranches: 0%, 11%, 30%, 41%, 45%
/// Cotisations sociales: CSG 9,2% + CRDS 0,5% = 9,7%
/// Source: economie.gouv.fr, service-public.fr
class FrTaxSystem extends TaxSystem {
  @override
  Country get country => Country.fr;

  @override
  double get socialContributionRate => 0.097;

  static const _brackets = [
    TaxBracket(upTo: 11600, rate: 0.0),
    TaxBracket(upTo: 29579, rate: 0.11),
    TaxBracket(upTo: 84577, rate: 0.30),
    TaxBracket(upTo: 181917, rate: 0.41),
    TaxBracket(upTo: double.infinity, rate: 0.45),
  ];

  /// Quotient familial: number of fiscal parts based on family situation.
  /// Single: 1, Married/PACS: 2, +0.5 per dependent (first two), +1 each after.
  static double _parts(String maritalStatus, int dependentes) {
    final isCouple = maritalStatus == 'casado' || maritalStatus == 'uniao_facto';
    double parts = isCouple ? 2.0 : 1.0;
    if (dependentes >= 1) parts += 0.5;
    if (dependentes >= 2) parts += 0.5;
    if (dependentes >= 3) parts += dependentes - 2; // 1 full part per child from 3rd
    return parts;
  }

  @override
  TaxResult calculateTax({
    required double grossSalary,
    required String maritalStatus,
    required int titulares,
    required int dependentes,
  }) {
    if (grossSalary <= 0) {
      return const TaxResult(
        incomeTax: 0,
        incomeTaxRate: 0,
        socialContribution: 0,
        socialContributionRate: 0.097,
        netSalary: 0,
      );
    }

    final annualGross = grossSalary * 12;
    final parts = _parts(maritalStatus, dependentes);
    // Apply brackets to income per part, then multiply back
    final perPart = annualGross / parts;
    final taxPerPart = TaxBracket.applyBrackets(perPart, _brackets);
    final annualTax = round2(taxPerPart * parts);
    final monthlyTax = round2(annualTax / 12);

    final ss = calculateSocialContribution(grossSalary);
    final effectiveRate = grossSalary > 0 ? monthlyTax / grossSalary : 0.0;
    final net = math.max(0.0, round2(grossSalary - monthlyTax - ss));

    return TaxResult(
      incomeTax: monthlyTax,
      incomeTaxRate: (effectiveRate * 10000).roundToDouble() / 10000,
      socialContribution: ss,
      socialContributionRate: socialContributionRate,
      netSalary: net,
    );
  }
}
