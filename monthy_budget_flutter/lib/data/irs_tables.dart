// Tabelas de Retenção na Fonte de IRS 2026 - Continente (trabalho dependente)
//
// Fonte oficial: Portal das Finanças, Tabelas_RF_Continente_2026.xlsx.
//
// Fórmula: Retenção = Remuneração × Taxa - Parcela_a_abater
//                     - (Parcela_dependente × N_dependentes)
//
// Nos dois primeiros escalões com taxa > 0 de cada tabela, a "parcela a abater"
// não é um valor fixo: é dada por  Taxa × k × (C - R), onde R é a remuneração
// mensal. É este termo que garante a transição suave no mínimo de existência
// (sem ele há um degrau no rendimento líquido logo acima do limiar de isenção).
//
// Segurança Social: 11% para trabalhadores por conta de outrem.

const double socialSecurityRate = 0.11;
const double mealCardExemptLimit = 10.20;
const double mealCashExemptLimit = 6.00;
const double minimumExistenceMonthly = 920.0;

/// Indexante dos Apoios Sociais (IAS) 2026.
const double iasMonthly2026 = 537.13;

/// Tecto anual da isenção do IRS Jovem: 55 × IAS (≈ 29.542,15 € em 2026).
const double irsJovemAnnualCap = 55 * iasMonthly2026;

class IRSBracket {
  final double upTo;
  final double rate;

  /// Parcela a abater fixa (usada quando [parcelaCeiling] é nulo).
  final double parcelaAbater;
  final double parcelaDependente;

  /// Coeficiente `k` da parcela a abater por fórmula (mínimo de existência).
  final double? parcelaFactor;

  /// Limite `C` da parcela a abater por fórmula.
  final double? parcelaCeiling;

  const IRSBracket({
    required this.upTo,
    required this.rate,
    this.parcelaAbater = 0.0,
    required this.parcelaDependente,
    this.parcelaFactor,
    this.parcelaCeiling,
  });

  /// Parcela a abater efetiva para uma dada remuneração mensal [remuneracao].
  /// Usa a fórmula `Taxa × k × (C - R)` quando definida, senão o valor fixo.
  double parcelaFor(double remuneracao) {
    if (parcelaFactor != null && parcelaCeiling != null) {
      return rate * parcelaFactor! * (parcelaCeiling! - remuneracao);
    }
    return parcelaAbater;
  }
}

class IRSTable {
  final String id;
  final String label;
  final String description;
  final List<IRSBracket> brackets;

  const IRSTable({
    required this.id,
    required this.label,
    required this.description,
    required this.brackets,
  });
}

/// Tabela I — Não casado sem dependentes OU Casado dois titulares.
const _tableI = IRSTable(
  id: 'table_I',
  label: 'Tabela I',
  description: 'Não casado sem dependentes / Casado dois titulares',
  brackets: [
    IRSBracket(upTo: 920.0, rate: 0.0, parcelaDependente: 0.0),
    IRSBracket(upTo: 1042.0, rate: 0.125, parcelaFactor: 2.6, parcelaCeiling: 1273.85, parcelaDependente: 21.43),
    IRSBracket(upTo: 1108.0, rate: 0.157, parcelaFactor: 1.35, parcelaCeiling: 1554.83, parcelaDependente: 21.43),
    IRSBracket(upTo: 1154.0, rate: 0.157, parcelaAbater: 94.71, parcelaDependente: 21.43),
    IRSBracket(upTo: 1212.0, rate: 0.212, parcelaAbater: 158.18, parcelaDependente: 21.43),
    IRSBracket(upTo: 1819.0, rate: 0.241, parcelaAbater: 193.33, parcelaDependente: 21.43),
    IRSBracket(upTo: 2119.0, rate: 0.311, parcelaAbater: 320.66, parcelaDependente: 21.43),
    IRSBracket(upTo: 2499.0, rate: 0.349, parcelaAbater: 401.19, parcelaDependente: 21.43),
    IRSBracket(upTo: 3305.0, rate: 0.3836, parcelaAbater: 487.66, parcelaDependente: 21.43),
    IRSBracket(upTo: 5547.0, rate: 0.3969, parcelaAbater: 531.62, parcelaDependente: 21.43),
    IRSBracket(upTo: 20221.0, rate: 0.4495, parcelaAbater: 823.40, parcelaDependente: 21.43),
    IRSBracket(upTo: double.infinity, rate: 0.4717, parcelaAbater: 1272.31, parcelaDependente: 21.43),
  ],
);

/// Tabela II — Não casado com um ou mais dependentes.
const _tableII = IRSTable(
  id: 'table_II',
  label: 'Tabela II',
  description: 'Não casado com 1 ou mais dependentes',
  brackets: [
    IRSBracket(upTo: 920.0, rate: 0.0, parcelaDependente: 0.0),
    IRSBracket(upTo: 1042.0, rate: 0.125, parcelaFactor: 2.6, parcelaCeiling: 1273.85, parcelaDependente: 34.29),
    IRSBracket(upTo: 1108.0, rate: 0.157, parcelaFactor: 1.35, parcelaCeiling: 1554.83, parcelaDependente: 34.29),
    IRSBracket(upTo: 1154.0, rate: 0.157, parcelaAbater: 94.71, parcelaDependente: 34.29),
    IRSBracket(upTo: 1212.0, rate: 0.212, parcelaAbater: 158.18, parcelaDependente: 34.29),
    IRSBracket(upTo: 1819.0, rate: 0.241, parcelaAbater: 193.33, parcelaDependente: 34.29),
    IRSBracket(upTo: 2119.0, rate: 0.311, parcelaAbater: 320.66, parcelaDependente: 34.29),
    IRSBracket(upTo: 2499.0, rate: 0.349, parcelaAbater: 401.19, parcelaDependente: 34.29),
    IRSBracket(upTo: 3305.0, rate: 0.3836, parcelaAbater: 487.66, parcelaDependente: 34.29),
    IRSBracket(upTo: 5547.0, rate: 0.3969, parcelaAbater: 531.62, parcelaDependente: 34.29),
    IRSBracket(upTo: 20221.0, rate: 0.4495, parcelaAbater: 823.40, parcelaDependente: 34.29),
    IRSBracket(upTo: double.infinity, rate: 0.4717, parcelaAbater: 1272.31, parcelaDependente: 34.29),
  ],
);

/// Tabela III — Casado, único titular.
const _tableIII = IRSTable(
  id: 'table_III',
  label: 'Tabela III',
  description: 'Casado, único titular',
  brackets: [
    IRSBracket(upTo: 991.0, rate: 0.0, parcelaDependente: 0.0),
    IRSBracket(upTo: 1042.0, rate: 0.125, parcelaFactor: 2.6, parcelaCeiling: 1372.15, parcelaDependente: 42.86),
    IRSBracket(upTo: 1108.0, rate: 0.125, parcelaFactor: 1.35, parcelaCeiling: 1677.85, parcelaDependente: 42.86),
    IRSBracket(upTo: 1119.0, rate: 0.125, parcelaAbater: 96.17, parcelaDependente: 42.86),
    IRSBracket(upTo: 1432.0, rate: 0.1272, parcelaAbater: 98.64, parcelaDependente: 42.86),
    IRSBracket(upTo: 1962.0, rate: 0.157, parcelaAbater: 141.32, parcelaDependente: 42.86),
    IRSBracket(upTo: 2240.0, rate: 0.1938, parcelaAbater: 213.53, parcelaDependente: 42.86),
    IRSBracket(upTo: 2773.0, rate: 0.2277, parcelaAbater: 289.47, parcelaDependente: 42.86),
    IRSBracket(upTo: 3389.0, rate: 0.257, parcelaAbater: 370.72, parcelaDependente: 42.86),
    IRSBracket(upTo: 5965.0, rate: 0.2881, parcelaAbater: 476.12, parcelaDependente: 42.86),
    IRSBracket(upTo: 20265.0, rate: 0.3843, parcelaAbater: 1049.96, parcelaDependente: 42.86),
    IRSBracket(upTo: double.infinity, rate: 0.4717, parcelaAbater: 2821.13, parcelaDependente: 42.86),
  ],
);

/// Tabela IV — Não casado ou casado dois titulares sem dependentes — deficiência.
const _tableIV = IRSTable(
  id: 'table_IV',
  label: 'Tabela IV',
  description: 'Não casado / casado 2 titulares sem dependentes — deficiência',
  brackets: [
    IRSBracket(upTo: 1694.0, rate: 0.0, parcelaDependente: 0.0),
    IRSBracket(upTo: 2063.0, rate: 0.212, parcelaAbater: 359.13, parcelaDependente: 0.0),
    IRSBracket(upTo: 2492.0, rate: 0.311, parcelaAbater: 563.37, parcelaDependente: 0.0),
    IRSBracket(upTo: 4487.0, rate: 0.349, parcelaAbater: 658.07, parcelaDependente: 0.0),
    IRSBracket(upTo: 4753.0, rate: 0.3836, parcelaAbater: 813.33, parcelaDependente: 0.0),
    IRSBracket(upTo: 6687.0, rate: 0.3969, parcelaAbater: 876.55, parcelaDependente: 0.0),
    IRSBracket(upTo: 20468.0, rate: 0.4495, parcelaAbater: 1228.29, parcelaDependente: 0.0),
    IRSBracket(upTo: double.infinity, rate: 0.4717, parcelaAbater: 1682.68, parcelaDependente: 0.0),
  ],
);

/// Tabela V — Não casado com um ou mais dependentes — deficiência.
const _tableV = IRSTable(
  id: 'table_V',
  label: 'Tabela V',
  description: 'Não casado com dependentes — deficiência',
  brackets: [
    IRSBracket(upTo: 1938.0, rate: 0.0, parcelaDependente: 0.0),
    IRSBracket(upTo: 2063.0, rate: 0.2132, parcelaAbater: 413.19, parcelaDependente: 42.86),
    IRSBracket(upTo: 2854.0, rate: 0.311, parcelaAbater: 614.96, parcelaDependente: 42.86),
    IRSBracket(upTo: 4504.0, rate: 0.349, parcelaAbater: 723.42, parcelaDependente: 42.86),
    IRSBracket(upTo: 6826.0, rate: 0.3836, parcelaAbater: 879.26, parcelaDependente: 42.86),
    IRSBracket(upTo: 7048.0, rate: 0.3969, parcelaAbater: 970.05, parcelaDependente: 42.86),
    IRSBracket(upTo: 20468.0, rate: 0.4495, parcelaAbater: 1340.78, parcelaDependente: 42.86),
    IRSBracket(upTo: double.infinity, rate: 0.4717, parcelaAbater: 1795.17, parcelaDependente: 42.86),
  ],
);

/// Tabela VI — Casado dois titulares com um ou mais dependentes — deficiência.
const _tableVI = IRSTable(
  id: 'table_VI',
  label: 'Tabela VI',
  description: 'Casado 2 titulares com dependentes — deficiência',
  brackets: [
    IRSBracket(upTo: 1668.0, rate: 0.0, parcelaDependente: 0.0),
    IRSBracket(upTo: 2068.0, rate: 0.2049, parcelaAbater: 341.78, parcelaDependente: 21.43),
    IRSBracket(upTo: 2497.0, rate: 0.241, parcelaAbater: 416.44, parcelaDependente: 21.43),
    IRSBracket(upTo: 3107.0, rate: 0.311, parcelaAbater: 591.23, parcelaDependente: 21.43),
    IRSBracket(upTo: 4504.0, rate: 0.349, parcelaAbater: 709.30, parcelaDependente: 21.43),
    IRSBracket(upTo: 6826.0, rate: 0.3836, parcelaAbater: 865.14, parcelaDependente: 21.43),
    IRSBracket(upTo: 7048.0, rate: 0.3969, parcelaAbater: 955.93, parcelaDependente: 21.43),
    IRSBracket(upTo: 20468.0, rate: 0.4495, parcelaAbater: 1326.66, parcelaDependente: 21.43),
    IRSBracket(upTo: double.infinity, rate: 0.4717, parcelaAbater: 1781.05, parcelaDependente: 21.43),
  ],
);

/// Tabela VII — Casado, único titular — deficiência.
const _tableVII = IRSTable(
  id: 'table_VII',
  label: 'Tabela VII',
  description: 'Casado, único titular — deficiência',
  brackets: [
    IRSBracket(upTo: 2325.0, rate: 0.0, parcelaDependente: 0.0),
    IRSBracket(upTo: 3494.0, rate: 0.2277, parcelaAbater: 529.41, parcelaDependente: 42.86),
    IRSBracket(upTo: 3761.0, rate: 0.257, parcelaAbater: 631.79, parcelaDependente: 42.86),
    IRSBracket(upTo: 6687.0, rate: 0.2881, parcelaAbater: 748.76, parcelaDependente: 42.86),
    IRSBracket(upTo: 20468.0, rate: 0.4244, parcelaAbater: 1660.20, parcelaDependente: 42.86),
    IRSBracket(upTo: double.infinity, rate: 0.4717, parcelaAbater: 2628.34, parcelaDependente: 42.86),
  ],
);

IRSTable getApplicableTable(
  String maritalStatus,
  int titulares,
  int dependentes, {
  bool deficiente = false,
}) {
  final isCasado = maritalStatus == 'casado' || maritalStatus == 'uniao_facto';

  if (deficiente) {
    if (isCasado && titulares == 1) return _tableVII;
    if (isCasado && titulares == 2) {
      return dependentes > 0 ? _tableVI : _tableIV;
    }
    // Não casado (solteiro, divorciado, viúvo)
    return dependentes > 0 ? _tableV : _tableIV;
  }

  if (isCasado && titulares == 1) return _tableIII;
  if (isCasado && titulares == 2) return _tableI;

  // Não casado (solteiro, divorciado, viúvo)
  if (dependentes > 0) return _tableII;
  return _tableI;
}

/// Fração de isenção do IRS Jovem por ano de regime (1..10). 0 = não aderente.
/// 100% no ano 1; 75% nos anos 2-4; 50% nos anos 5-7; 25% nos anos 8-10.
double irsJovemExemption(int regimeYear) {
  if (regimeYear <= 0) return 0.0;
  if (regimeYear == 1) return 1.0;
  if (regimeYear <= 4) return 0.75;
  if (regimeYear <= 7) return 0.50;
  if (regimeYear <= 10) return 0.25;
  return 0.0; // Após o 10.º ano, sem isenção.
}
