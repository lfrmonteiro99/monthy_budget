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
    bool deficiente = false,
    int irsJovemYear = 0,
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

    final table = getApplicableTable(
      maritalStatus,
      titulares,
      dependentes,
      deficiente: deficiente,
    );
    final bracket = table.brackets.cast<IRSBracket?>().firstWhere(
          (b) => grossSalary <= b!.upTo,
          orElse: () => null,
        );

    double retention = 0;
    double rate = 0;

    if (bracket != null && bracket.rate > 0) {
      // Parcela a abater: fixa ou por fórmula (mínimo de existência).
      final parcela = bracket.parcelaFor(grossSalary);
      retention = grossSalary * bracket.rate -
          parcela -
          bracket.parcelaDependente * dependentes;
      retention = math.max(0.0, round2(retention));

      // IRS Jovem: reduz a retenção pela fração de isenção do ano de regime.
      // Nota: o tecto anual (55×IAS) não é aplicado nesta retenção mensal.
      final exemption = irsJovemExemption(irsJovemYear);
      if (exemption > 0) {
        retention = round2(retention * (1 - exemption));
      }

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
