import 'dart:math' as math;
import 'tax_system.dart';
import '../irs_tables.dart';

class PtTaxSystem extends TaxSystem {
  @override
  Country get country => Country.pt;

  @override
  double get socialContributionRate => socialSecurityRate;

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
        socialContributionRate: 0.11,
        netSalary: 0,
      );
    }

    final table = getApplicableTable(maritalStatus, titulares, dependentes);
    final bracket = table.brackets.cast<IRSBracket?>().firstWhere(
          (b) => grossSalary <= b!.upTo,
          orElse: () => null,
        );

    double retention = 0;
    double rate = 0;

    if (bracket != null && bracket.rate > 0) {
      retention = grossSalary * bracket.rate -
          bracket.parcelaAbater -
          bracket.parcelaDependente * dependentes;
      retention = math.max(0.0, round2(retention));
      rate = grossSalary > 0 ? retention / grossSalary : 0.0;
      rate = (rate * 10000).roundToDouble() / 10000;
    }

    final ss = calculateSocialContribution(grossSalary);
    final net = math.max(0.0, round2(grossSalary - retention - ss));

    return TaxResult(
      incomeTax: retention,
      incomeTaxRate: rate,
      socialContribution: ss,
      socialContributionRate: socialSecurityRate,
      netSalary: net,
    );
  }
}
