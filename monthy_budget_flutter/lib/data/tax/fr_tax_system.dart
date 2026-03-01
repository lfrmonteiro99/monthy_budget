import 'dart:math' as math;
import 'tax_system.dart';

/// France IR simplified tax system (2024 rates)
/// 5 brackets: 0%, 11%, 30%, 41%, 45%
/// Social contributions: CSG 9.2% + CRDS 0.5% = 9.7% (simplified as single rate)
class FrTaxSystem extends TaxSystem {
  @override
  Country get country => Country.fr;

  @override
  double get socialContributionRate => 0.097;

  static const _brackets = [
    TaxBracket(upTo: 11294, rate: 0.0),
    TaxBracket(upTo: 28797, rate: 0.11),
    TaxBracket(upTo: 82341, rate: 0.30),
    TaxBracket(upTo: 177106, rate: 0.41),
    TaxBracket(upTo: double.infinity, rate: 0.45),
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
        socialContributionRate: 0.097,
        netSalary: 0,
      );
    }

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
