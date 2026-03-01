import 'dart:math' as math;
import 'tax_system.dart';

/// Spain IRPF simplified tax system (2024 rates)
/// 6 brackets: 19%, 24%, 30%, 37%, 45%, 47%
/// Social Security: 6.35% employee contribution
class EsTaxSystem extends TaxSystem {
  @override
  Country get country => Country.es;

  @override
  double get socialContributionRate => 0.0635;

  static const _brackets = [
    TaxBracket(upTo: 12450, rate: 0.19),
    TaxBracket(upTo: 20200, rate: 0.24),
    TaxBracket(upTo: 35200, rate: 0.30),
    TaxBracket(upTo: 60000, rate: 0.37),
    TaxBracket(upTo: 300000, rate: 0.45),
    TaxBracket(upTo: double.infinity, rate: 0.47),
  ];

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
        socialContributionRate: 0.0635,
        netSalary: 0,
      );
    }

    // Annualize for bracket lookup, then de-annualize
    final annualGross = grossSalary * 12;
    final annualTax = TaxBracket.applyBrackets(annualGross, _brackets);
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
