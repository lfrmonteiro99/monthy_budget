import {
  type PersonalInfo,
  type SalaryCalculation,
  type BudgetSummary,
  type ExpenseItem,
  type SalaryInfo,
  type TitularCount,
  type MealAllowanceCalculation,
  type MealAllowanceType,
} from "../types";
import {
  getApplicableTable,
  SOCIAL_SECURITY_RATE,
  MEAL_CARD_EXEMPT_LIMIT,
  MEAL_CASH_EXEMPT_LIMIT,
} from "../data/irsTables";

/**
 * Calcula a retenção de IRS para um dado salário bruto
 *
 * Fórmula: Retenção = Remuneração × Taxa - Parcela_a_abater - (Parcela_dependente × N_dependentes)
 */
export function calculateIRSRetention(
  grossSalary: number,
  personalInfo: PersonalInfo,
  titulares: TitularCount,
): { retention: number; rate: number } {
  if (grossSalary <= 0) return { retention: 0, rate: 0 };

  const table = getApplicableTable(
    personalInfo.maritalStatus,
    titulares,
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
 * Calcula o subsidio de alimentacao mensal
 *
 * - Cartao: isento ate 10,20 EUR/dia; excedente sujeito a IRS + SS
 * - Dinheiro (junto com base): isento ate 6,00 EUR/dia; excedente sujeito a IRS + SS
 */
export function calculateMealAllowance(
  type: MealAllowanceType,
  perDay: number,
  workingDays: number,
  irsRate: number,
): MealAllowanceCalculation {
  const empty: MealAllowanceCalculation = {
    totalMonthly: 0,
    exemptPortion: 0,
    taxablePortion: 0,
    irsTaxOnMeal: 0,
    ssTaxOnMeal: 0,
    netMealAllowance: 0,
  };

  if (type === "none" || perDay <= 0 || workingDays <= 0) return empty;

  const exemptLimit = type === "card" ? MEAL_CARD_EXEMPT_LIMIT : MEAL_CASH_EXEMPT_LIMIT;
  const totalMonthly = round2(perDay * workingDays);
  const exemptPerDay = Math.min(perDay, exemptLimit);
  const taxablePerDay = Math.max(0, perDay - exemptLimit);

  const exemptPortion = round2(exemptPerDay * workingDays);
  const taxablePortion = round2(taxablePerDay * workingDays);

  const irsTaxOnMeal = round2(taxablePortion * irsRate);
  const ssTaxOnMeal = round2(taxablePortion * SOCIAL_SECURITY_RATE);
  const netMealAllowance = round2(totalMonthly - irsTaxOnMeal - ssTaxOnMeal);

  return {
    totalMonthly,
    exemptPortion,
    taxablePortion,
    irsTaxOnMeal,
    ssTaxOnMeal,
    netMealAllowance,
  };
}

function round2(v: number): number {
  return Math.round(v * 100) / 100;
}

/**
 * Calcula o salário líquido completo
 */
export function calculateNetSalary(
  salary: SalaryInfo,
  personalInfo: PersonalInfo,
): SalaryCalculation {
  const grossSalary = salary.grossAmount;

  if (grossSalary <= 0) {
    const meal = calculateMealAllowance(salary.mealAllowanceType, salary.mealAllowancePerDay, salary.workingDaysPerMonth, 0);
    return {
      grossAmount: 0,
      irsRetention: 0,
      irsRate: 0,
      socialSecurity: 0,
      socialSecurityRate: SOCIAL_SECURITY_RATE,
      netAmount: 0,
      mealAllowance: meal,
      totalNetWithMeal: meal.netMealAllowance,
    };
  }

  const { retention, rate } = calculateIRSRetention(grossSalary, personalInfo, salary.titulares);
  const ss = calculateSocialSecurity(grossSalary);
  const net = round2(grossSalary - retention - ss);
  const netAmount = Math.max(0, net);

  const meal = calculateMealAllowance(salary.mealAllowanceType, salary.mealAllowancePerDay, salary.workingDaysPerMonth, rate);

  return {
    grossAmount: grossSalary,
    irsRetention: retention,
    irsRate: rate,
    socialSecurity: ss,
    socialSecurityRate: SOCIAL_SECURITY_RATE,
    netAmount,
    mealAllowance: meal,
    totalNetWithMeal: round2(netAmount + meal.netMealAllowance),
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
  const disabledSalary = (s: SalaryInfo): SalaryInfo => ({
    ...s,
    grossAmount: 0,
  });

  const salary1 = calculateNetSalary(
    salaries[0].enabled ? salaries[0] : disabledSalary(salaries[0]),
    personalInfo,
  );
  const salary2 = calculateNetSalary(
    salaries[1].enabled ? salaries[1] : disabledSalary(salaries[1]),
    personalInfo,
  );

  const totalGross = salary1.grossAmount + salary2.grossAmount;
  const totalNet = salary1.netAmount + salary2.netAmount;
  const totalMealAllowance = salary1.mealAllowance.netMealAllowance + salary2.mealAllowance.netMealAllowance;
  const totalNetWithMeal = salary1.totalNetWithMeal + salary2.totalNetWithMeal;
  const totalIRS = salary1.irsRetention + salary2.irsRetention + salary1.mealAllowance.irsTaxOnMeal + salary2.mealAllowance.irsTaxOnMeal;
  const totalSS = salary1.socialSecurity + salary2.socialSecurity + salary1.mealAllowance.ssTaxOnMeal + salary2.mealAllowance.ssTaxOnMeal;
  const totalDeductions = totalIRS + totalSS;

  const totalExpenses = expenses
    .filter((e) => e.enabled)
    .reduce((sum, e) => sum + e.amount, 0);

  const netLiquidity = round2(totalNetWithMeal - totalExpenses);
  const savingsRate = totalNetWithMeal > 0 ? netLiquidity / totalNetWithMeal : 0;

  return {
    salary1,
    salary2,
    totalGross,
    totalNet,
    totalNetWithMeal,
    totalMealAllowance,
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
