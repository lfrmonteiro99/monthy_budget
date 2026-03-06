// Tabelas de Retenção na Fonte de IRS 2026 - Continente
//
// Fórmula: Retenção = Remuneração × Taxa - Parcela_a_abater - (Parcela_dependente × N_dependentes)
//
// Segurança Social: 11% para trabalhadores por conta de outrem

import '../l10n/generated/app_localizations.dart';

const double socialSecurityRate = 0.11;
const double mealCardExemptLimit = 10.20;
const double mealCashExemptLimit = 6.00;
const double minimumExistenceMonthly = 920.0;

class IRSBracket {
  final double upTo;
  final double rate;
  final double parcelaAbater;
  final double parcelaDependente;

  const IRSBracket({
    required this.upTo,
    required this.rate,
    required this.parcelaAbater,
    required this.parcelaDependente,
  });
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

  String localizedLabel(S l10n) {
    switch (id) {
      case 'table_I':
        return l10n.taxTableI;
      case 'table_II':
        return l10n.taxTableII;
      case 'table_III':
        return l10n.taxTableIII;
      default:
        return label;
    }
  }

  String localizedDescription(S l10n) {
    switch (id) {
      case 'table_I':
        return l10n.taxTableIDescription;
      case 'table_II':
        return l10n.taxTableIIDescription;
      case 'table_III':
        return l10n.taxTableIIIDescription;
      default:
        return description;
    }
  }
}

/// Tabela I — Trabalho dependente: Não casado sem dependentes OU Casado dois titulares
const _tableI = IRSTable(
  id: 'table_I',
  label: 'Tabela I',
  description: 'Não casado sem dependentes / Casado dois titulares',
  brackets: [
    IRSBracket(upTo: 920.0, rate: 0.0, parcelaAbater: 0.0, parcelaDependente: 0.0),
    IRSBracket(upTo: 1042.0, rate: 0.125, parcelaAbater: 75.02, parcelaDependente: 21.43),
    IRSBracket(upTo: 1108.0, rate: 0.157, parcelaAbater: 94.18, parcelaDependente: 21.43),
    IRSBracket(upTo: 1154.0, rate: 0.157, parcelaAbater: 94.71, parcelaDependente: 21.43),
    IRSBracket(upTo: 1212.0, rate: 0.212, parcelaAbater: 158.18, parcelaDependente: 21.43),
    IRSBracket(upTo: 1819.0, rate: 0.241, parcelaAbater: 193.33, parcelaDependente: 21.43),
    IRSBracket(upTo: 2119.0, rate: 0.311, parcelaAbater: 320.66, parcelaDependente: 21.43),
    IRSBracket(upTo: 2499.0, rate: 0.349, parcelaAbater: 401.19, parcelaDependente: 21.43),
    IRSBracket(upTo: 3305.0, rate: 0.3836, parcelaAbater: 487.66, parcelaDependente: 21.43),
    IRSBracket(upTo: 5547.0, rate: 0.3969, parcelaAbater: 531.62, parcelaDependente: 21.43),
    IRSBracket(upTo: 20221.0, rate: 0.4495, parcelaAbater: 893.75, parcelaDependente: 21.43),
    IRSBracket(upTo: double.infinity, rate: 0.4717, parcelaAbater: 1272.31, parcelaDependente: 21.43),
  ],
);

/// Tabela II — Trabalho dependente: Não casado com um ou mais dependentes
const _tableII = IRSTable(
  id: 'table_II',
  label: 'Tabela II',
  description: 'Não casado com 1 ou mais dependentes',
  brackets: [
    IRSBracket(upTo: 920.0, rate: 0.0, parcelaAbater: 0.0, parcelaDependente: 0.0),
    IRSBracket(upTo: 1042.0, rate: 0.125, parcelaAbater: 75.02, parcelaDependente: 34.29),
    IRSBracket(upTo: 1108.0, rate: 0.157, parcelaAbater: 94.18, parcelaDependente: 34.29),
    IRSBracket(upTo: 1154.0, rate: 0.157, parcelaAbater: 94.71, parcelaDependente: 34.29),
    IRSBracket(upTo: 1212.0, rate: 0.212, parcelaAbater: 158.18, parcelaDependente: 34.29),
    IRSBracket(upTo: 1819.0, rate: 0.241, parcelaAbater: 193.33, parcelaDependente: 34.29),
    IRSBracket(upTo: 2119.0, rate: 0.311, parcelaAbater: 320.66, parcelaDependente: 34.29),
    IRSBracket(upTo: 2499.0, rate: 0.349, parcelaAbater: 401.19, parcelaDependente: 34.29),
    IRSBracket(upTo: 3305.0, rate: 0.3836, parcelaAbater: 487.66, parcelaDependente: 34.29),
    IRSBracket(upTo: 5547.0, rate: 0.3969, parcelaAbater: 531.62, parcelaDependente: 34.29),
    IRSBracket(upTo: 20221.0, rate: 0.4495, parcelaAbater: 823.4, parcelaDependente: 34.29),
    IRSBracket(upTo: double.infinity, rate: 0.4717, parcelaAbater: 1272.31, parcelaDependente: 34.29),
  ],
);

/// Tabela III — Trabalho dependente: Casado, único titular
const _tableIII = IRSTable(
  id: 'table_III',
  label: 'Tabela III',
  description: 'Casado, único titular',
  brackets: [
    IRSBracket(upTo: 991.0, rate: 0.0, parcelaAbater: 0.0, parcelaDependente: 0.0),
    IRSBracket(upTo: 1042.0, rate: 0.125, parcelaAbater: 107.33, parcelaDependente: 42.86),
    IRSBracket(upTo: 1108.0, rate: 0.125, parcelaAbater: 96.4, parcelaDependente: 42.86),
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

IRSTable getApplicableTable(String maritalStatus, int titulares, int dependentes) {
  final isCasado = maritalStatus == 'casado' || maritalStatus == 'uniao_facto';

  if (isCasado && titulares == 1) {
    return _tableIII;
  }

  if (isCasado && titulares == 2) {
    return _tableI;
  }

  // Não casado (solteiro, divorciado, viúvo)
  if (dependentes > 0) {
    return _tableII;
  }

  return _tableI;
}
