import {
  type PersonalInfo,
  type SalaryCalculation,
  type BudgetSummary,
  type ExpenseItem,
  type SalaryInfo,
} from "../types";
import { getApplicableTable, SOCIAL_SECURITY_RATE } from "../data/irsTables";

/**
 * Calcula a retenção de IRS para um dado salário bruto
 *
 * Fórmula: Retenção = Remuneração × Taxa - Parcela_a_abater - (Parcela_dependente × N_dependentes)
 */
export function calculateIRSRetention(
  grossSalary: number,
  personalInfo: PersonalInfo,
): { retention: number; rate: number } {
  if (grossSalary <= 0) return { retention: 0, rate: 0 };

  const table = getApplicableTable(
    personalInfo.maritalStatus,
    personalInfo.titulares,
    personalInfo.dependentes,
  );

  const bracket = table.brackets.find((b) => grossSalary <= b.upTo);
  if (!bracket || bracket.rate === 0) {
    return { retention: 0, rate: 0 };
  }

  const retention =
    grossSalary * bracket.rate -
    bracket.parcelaAbater -
    bracket.parcelaDependente * personalInfo.dependentes;

  // A retenção nunca pode ser negativa
  const finalRetention = Math.max(0, Math.round(retention * 100) / 100);
  const effectiveRate = grossSalary > 0 ? finalRetention / grossSalary : 0;

  return {
    retention: finalRetention,
    rate: Math.round(effectiveRate * 10000) / 10000,
  };
}

/**
 * Calcula a contribuição para a Segurança Social
 * Taxa fixa de 11% para trabalhadores por conta de outrem
 */
export function calculateSocialSecurity(grossSalary: number): number {
  if (grossSalary <= 0) return 0;
  return Math.round(grossSalary * SOCIAL_SECURITY_RATE * 100) / 100;
}

/**
 * Calcula o salário líquido completo
 */
export function calculateNetSalary(
  grossSalary: number,
  personalInfo: PersonalInfo,
): SalaryCalculation {
  if (grossSalary <= 0) {
    return {
      grossAmount: 0,
      irsRetention: 0,
      irsRate: 0,
      socialSecurity: 0,
      socialSecurityRate: SOCIAL_SECURITY_RATE,
      netAmount: 0,
    };
  }

  const { retention, rate } = calculateIRSRetention(grossSalary, personalInfo);
  const ss = calculateSocialSecurity(grossSalary);
  const net = Math.round((grossSalary - retention - ss) * 100) / 100;

  return {
    grossAmount: grossSalary,
    irsRetention: retention,
    irsRate: rate,
    socialSecurity: ss,
    socialSecurityRate: SOCIAL_SECURITY_RATE,
    netAmount: Math.max(0, net),
  };
}

/**
 * Calcula o resumo completo do orçamento mensal
 */
export function calculateBudgetSummary(
  salaries: [SalaryInfo, SalaryInfo],
  personalInfo: PersonalInfo,
  expenses: ExpenseItem[],
): BudgetSummary {
  const salary1 = salaries[0].enabled
    ? calculateNetSalary(salaries[0].grossAmount, personalInfo)
    : calculateNetSalary(0, personalInfo);

  const salary2 = salaries[1].enabled
    ? calculateNetSalary(salaries[1].grossAmount, personalInfo)
    : calculateNetSalary(0, personalInfo);

  const totalGross = salary1.grossAmount + salary2.grossAmount;
  const totalNet = salary1.netAmount + salary2.netAmount;
  const totalIRS = salary1.irsRetention + salary2.irsRetention;
  const totalSS = salary1.socialSecurity + salary2.socialSecurity;
  const totalDeductions = totalIRS + totalSS;

  const totalExpenses = expenses
    .filter((e) => e.enabled)
    .reduce((sum, e) => sum + e.amount, 0);

  const netLiquidity = Math.round((totalNet - totalExpenses) * 100) / 100;
  const savingsRate = totalNet > 0 ? netLiquidity / totalNet : 0;

  return {
    salary1,
    salary2,
    totalGross,
    totalNet,
    totalIRS,
    totalSS,
    totalDeductions,
    totalExpenses,
    netLiquidity,
    savingsRate: Math.round(savingsRate * 10000) / 10000,
  };
}

/**
 * Formata um valor em euros
 */
export function formatCurrency(value: number): string {
  return new Intl.NumberFormat("pt-PT", {
    style: "currency",
    currency: "EUR",
  }).format(value);
}

/**
 * Formata uma percentagem
 */
export function formatPercentage(value: number): string {
  return new Intl.NumberFormat("pt-PT", {
    style: "percent",
    minimumFractionDigits: 1,
    maximumFractionDigits: 1,
  }).format(value);
}
