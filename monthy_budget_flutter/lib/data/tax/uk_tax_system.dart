import 'dart:math' as math;
import 'tax_system.dart';

/// UK PAYE simplified tax system (2024/25 rates)
/// Personal allowance: 12,570 GBP
/// 3 bands: 20% basic, 40% higher, 45% additional
/// National Insurance: 8% on 12,570-50,270, 2% above 50,270
class UkTaxSystem extends TaxSystem {
  @override
  Country get country => Country.uk;

  @override
  double get socialContributionRate => 0.08; // effective NI rate

  static const _brackets = [
    TaxBracket(upTo: 12570, rate: 0.0),
    TaxBracket(upTo: 50270, rate: 0.20),
    TaxBracket(upTo: 125140, rate: 0.40),
    TaxBracket(upTo: double.infinity, rate: 0.45),
  ];

  static const _niBrackets = [
    TaxBracket(upTo: 12570, rate: 0.0),
    TaxBracket(upTo: 50270, rate: 0.08),
    TaxBracket(upTo: double.infinity, rate: 0.02),
  ];

  @override
  double calculateSocialContribution(double grossSalary) {
    if (grossSalary <= 0) return 0;
    final annualGross = grossSalary * 12;
    final annualNI = TaxBracket.applyBrackets(annualGross, _niBrackets);
    return round2(annualNI / 12);
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
        socialContributionRate: 0.08,
        netSalary: 0,
      );
    }

    final annualGross = grossSalary * 12;
    final annualTax = TaxBracket.applyBrackets(annualGross, _brackets);
    final monthlyTax = round2(annualTax / 12);

    final ni = calculateSocialContribution(grossSalary);
    final effectiveRate = grossSalary > 0 ? monthlyTax / grossSalary : 0.0;
    final net = math.max(0.0, round2(grossSalary - monthlyTax - ni));

    return TaxResult(
      incomeTax: monthlyTax,
      incomeTaxRate: (effectiveRate * 10000).roundToDouble() / 10000,
      socialContribution: ni,
      socialContributionRate: socialContributionRate,
      netSalary: net,
    );
  }
}
