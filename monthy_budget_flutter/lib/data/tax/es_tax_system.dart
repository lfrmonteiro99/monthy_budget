import 'dart:math' as math;
import 'tax_system.dart';

/// Spain IRPF tax system (2026 rates)
/// 6 escalones estatales: 19%, 24%, 30%, 37%, 45%, 47%
/// Seguridad Social: 6,35% cotización trabajador
/// Mínimo personal: 5.550€ (Art. 63 LIRPF)
/// Mínimo por descendientes: 1er hijo 2.400€, 2º 2.700€, 3º 4.000€, 4º+ 4.500€
/// Source: Agencia Tributaria, sede.agenciatributaria.gob.es
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

  /// Mínimo personal + mínimo por descendientes (Art. 63-64 LIRPF).
  /// Returns the annual tax-free personal/family allowance.
  static double _minimoPersonalFamiliar(int dependentes) {
    double minimo = 5550; // Mínimo del contribuyente
    // Mínimo por descendientes
    const childAmounts = [2400, 2700, 4000, 4500];
    for (int i = 0; i < dependentes; i++) {
      minimo += i < childAmounts.length ? childAmounts[i] : 4500;
    }
    return minimo;
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
        socialContributionRate: 0.0635,
        netSalary: 0,
      );
    }

    final annualGross = grossSalary * 12;

    // Cuota íntegra = tax on gross - tax on mínimo personal/familiar
    final grossTax = TaxBracket.applyBrackets(annualGross, _brackets);
    final minimo = _minimoPersonalFamiliar(dependentes);
    final minimoTax = TaxBracket.applyBrackets(minimo, _brackets);
    final annualTax = math.max(0.0, grossTax - minimoTax);
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
