/**
 * Tabelas de Retenção na Fonte de IRS 2026 - Continente
 *
 * Fonte: Autoridade Tributária e Aduaneira / Montepio / Doutor Finanças
 *
 * Fórmula: Retenção = Remuneração × Taxa - Parcela_a_abater - (Parcela_dependente × N_dependentes)
 *
 * Segurança Social: 11% para trabalhadores por conta de outrem
 */

export interface IRSBracket {
  /** Limite superior do escalão (Infinity para o último) */
  upTo: number;
  /** Taxa marginal (ex: 0.125 = 12.5%) */
  rate: number;
  /** Parcela a abater em euros */
  parcelaAbater: number;
  /** Parcela adicional a abater por dependente */
  parcelaDependente: number;
}

export interface IRSTable {
  id: string;
  label: string;
  description: string;
  brackets: IRSBracket[];
}

/**
 * Tabela I — Trabalho dependente: Não casado sem dependentes OU Casado dois titulares
 */
const TABLE_I: IRSTable = {
  id: "table_I",
  label: "Tabela I",
  description: "Não casado sem dependentes / Casado dois titulares",
  brackets: [
    { upTo: 920.0, rate: 0.0, parcelaAbater: 0.0, parcelaDependente: 0.0 },
    { upTo: 1042.0, rate: 0.125, parcelaAbater: 75.02, parcelaDependente: 21.43 },
    { upTo: 1108.0, rate: 0.157, parcelaAbater: 94.18, parcelaDependente: 21.43 },
    { upTo: 1154.0, rate: 0.157, parcelaAbater: 94.71, parcelaDependente: 21.43 },
    { upTo: 1212.0, rate: 0.212, parcelaAbater: 158.18, parcelaDependente: 21.43 },
    { upTo: 1819.0, rate: 0.241, parcelaAbater: 193.33, parcelaDependente: 21.43 },
    { upTo: 2119.0, rate: 0.311, parcelaAbater: 320.66, parcelaDependente: 21.43 },
    { upTo: 2499.0, rate: 0.349, parcelaAbater: 401.19, parcelaDependente: 21.43 },
    { upTo: 3305.0, rate: 0.3836, parcelaAbater: 487.66, parcelaDependente: 21.43 },
    { upTo: 5547.0, rate: 0.3969, parcelaAbater: 531.62, parcelaDependente: 21.43 },
    { upTo: 20221.0, rate: 0.4495, parcelaAbater: 893.75, parcelaDependente: 21.43 },
    { upTo: Infinity, rate: 0.4717, parcelaAbater: 1272.31, parcelaDependente: 21.43 },
  ],
};

/**
 * Tabela II — Trabalho dependente: Não casado com um ou mais dependentes
 */
const TABLE_II: IRSTable = {
  id: "table_II",
  label: "Tabela II",
  description: "Não casado com 1 ou mais dependentes",
  brackets: [
    { upTo: 920.0, rate: 0.0, parcelaAbater: 0.0, parcelaDependente: 0.0 },
    { upTo: 1042.0, rate: 0.125, parcelaAbater: 75.02, parcelaDependente: 34.29 },
    { upTo: 1108.0, rate: 0.157, parcelaAbater: 94.18, parcelaDependente: 34.29 },
    { upTo: 1154.0, rate: 0.157, parcelaAbater: 94.71, parcelaDependente: 34.29 },
    { upTo: 1212.0, rate: 0.212, parcelaAbater: 158.18, parcelaDependente: 34.29 },
    { upTo: 1819.0, rate: 0.241, parcelaAbater: 193.33, parcelaDependente: 34.29 },
    { upTo: 2119.0, rate: 0.311, parcelaAbater: 320.66, parcelaDependente: 34.29 },
    { upTo: 2499.0, rate: 0.349, parcelaAbater: 401.19, parcelaDependente: 34.29 },
    { upTo: 3305.0, rate: 0.3836, parcelaAbater: 487.66, parcelaDependente: 34.29 },
    { upTo: 5547.0, rate: 0.3969, parcelaAbater: 531.62, parcelaDependente: 34.29 },
    { upTo: 20221.0, rate: 0.4495, parcelaAbater: 823.4, parcelaDependente: 34.29 },
    { upTo: Infinity, rate: 0.4717, parcelaAbater: 1272.31, parcelaDependente: 34.29 },
  ],
};

/**
 * Tabela III — Trabalho dependente: Casado, único titular
 */
const TABLE_III: IRSTable = {
  id: "table_III",
  label: "Tabela III",
  description: "Casado, único titular",
  brackets: [
    { upTo: 991.0, rate: 0.0, parcelaAbater: 0.0, parcelaDependente: 0.0 },
    { upTo: 1042.0, rate: 0.125, parcelaAbater: 107.33, parcelaDependente: 42.86 },
    { upTo: 1108.0, rate: 0.125, parcelaAbater: 96.4, parcelaDependente: 42.86 },
    { upTo: 1119.0, rate: 0.125, parcelaAbater: 96.17, parcelaDependente: 42.86 },
    { upTo: 1432.0, rate: 0.1272, parcelaAbater: 98.64, parcelaDependente: 42.86 },
    { upTo: 1962.0, rate: 0.157, parcelaAbater: 141.32, parcelaDependente: 42.86 },
    { upTo: 2240.0, rate: 0.1938, parcelaAbater: 213.53, parcelaDependente: 42.86 },
    { upTo: 2773.0, rate: 0.2277, parcelaAbater: 289.47, parcelaDependente: 42.86 },
    { upTo: 3389.0, rate: 0.257, parcelaAbater: 370.72, parcelaDependente: 42.86 },
    { upTo: 5965.0, rate: 0.2881, parcelaAbater: 476.12, parcelaDependente: 42.86 },
    { upTo: 20265.0, rate: 0.3843, parcelaAbater: 1049.96, parcelaDependente: 42.86 },
    { upTo: Infinity, rate: 0.4717, parcelaAbater: 2821.13, parcelaDependente: 42.86 },
  ],
};

export const IRS_TABLES = {
  table_I: TABLE_I,
  table_II: TABLE_II,
  table_III: TABLE_III,
};

/** Taxa de Segurança Social para trabalhadores por conta de outrem */
export const SOCIAL_SECURITY_RATE = 0.11;

/** Limite diario isento do subsidio de alimentacao em cartao (EUR) */
export const MEAL_CARD_EXEMPT_LIMIT = 10.2;

/** Limite diario isento do subsidio de alimentacao em dinheiro (EUR) */
export const MEAL_CASH_EXEMPT_LIMIT = 6.0;

/** Mínimo de existência mensal 2026 */
export const MINIMUM_EXISTENCE_MONTHLY = 920.0;

/** Mínimo de existência anual 2026 */
export const MINIMUM_EXISTENCE_ANNUAL = 12880.0;

/**
 * Determina qual tabela de IRS usar com base no estado civil, nº de titulares e dependentes
 */
export function getApplicableTable(
  maritalStatus: string,
  titulares: number,
  dependentes: number,
): IRSTable {
  const isCasado = maritalStatus === "casado" || maritalStatus === "uniao_facto";

  if (isCasado && titulares === 1) {
    return TABLE_III;
  }

  if (isCasado && titulares === 2) {
    // Casado dois titulares usa Tabela I (mesma que não casado sem dependentes)
    return TABLE_I;
  }

  // Não casado (solteiro, divorciado, viúvo)
  if (dependentes > 0) {
    return TABLE_II;
  }

  return TABLE_I;
}
