import 'dart:math' as math;
import '../models/app_settings.dart';
import '../models/budget_summary.dart';
import '../data/tax/tax_system.dart';
import '../data/irs_tables.dart';

double _round2(double v) => (v * 100).roundToDouble() / 100;

/// Calcula o subsidio de alimentação mensal (PT only)
MealAllowanceCalculation calculateMealAllowance(
  MealAllowanceType type,
  double perDay,
  int workingDays,
  double irsRate,
  double ssRate,
) {
  if (type == MealAllowanceType.none || perDay <= 0 || workingDays <= 0) {
    return const MealAllowanceCalculation();
  }

  final exemptLimit = type == MealAllowanceType.card ? mealCardExemptLimit : mealCashExemptLimit;
  final totalMonthly = _round2(perDay * workingDays);
  final exemptPerDay = math.min(perDay, exemptLimit);
  final taxablePerDay = math.max(0.0, perDay - exemptLimit);

  final exemptPortion = _round2(exemptPerDay * workingDays);
  final taxablePortion = _round2(taxablePerDay * workingDays);

  final irsTaxOnMeal = _round2(taxablePortion * irsRate);
  final ssTaxOnMeal = _round2(taxablePortion * ssRate);
  final netMealAllowance = _round2(totalMonthly - irsTaxOnMeal - ssTaxOnMeal);

  return MealAllowanceCalculation(
    totalMonthly: totalMonthly,
    exemptPortion: exemptPortion,
    taxablePortion: taxablePortion,
    irsTaxOnMeal: irsTaxOnMeal,
    ssTaxOnMeal: ssTaxOnMeal,
    netMealAllowance: netMealAllowance,
  );
}

/// Calcula o salário líquido completo, usando o sistema fiscal do país selecionado
SalaryCalculation calculateNetSalary(
  SalaryInfo salary,
  PersonalInfo personalInfo,
  TaxSystem taxSystem,
) {
  final country = taxSystem.country;
  final baseGross = salary.grossAmount;

  // Subsidies: PT and ES have duodécimos/pagas extras, FR and UK don't
  final factor = country.hasSubsidies ? salary.subsidyMode.monthlyFactor : 1.0;
  final effectiveGross = _round2(baseGross * factor);
  final subsidyBonus = _round2(effectiveGross - baseGross);

  if (effectiveGross <= 0) {
    final meal = country.hasMealAllowance
        ? calculateMealAllowance(
            salary.mealAllowanceType,
            salary.mealAllowancePerDay,
            salary.workingDaysPerMonth,
            0,
            taxSystem.socialContributionRate,
          )
        : const MealAllowanceCalculation();
    return SalaryCalculation(
      grossAmount: baseGross,
      effectiveGrossAmount: 0,
      subsidyMonthlyBonus: 0,
      otherExemptIncome: salary.otherExemptIncome,
      irsRetention: 0,
      irsRate: 0,
      socialSecurity: 0,
      socialSecurityRate: taxSystem.socialContributionRate,
      netAmount: 0,
      mealAllowance: meal,
      totalNetWithMeal: _round2(meal.netMealAllowance + salary.otherExemptIncome),
    );
  }

  final taxResult = taxSystem.calculateTax(
    grossSalary: effectiveGross,
    maritalStatus: personalInfo.maritalStatus.jsonValue,
    titulares: salary.titulares,
    dependentes: personalInfo.dependentes,
  );

  final netAmount = math.max(0.0, _round2(effectiveGross - taxResult.incomeTax - taxResult.socialContribution));

  final meal = country.hasMealAllowance
      ? calculateMealAllowance(
          salary.mealAllowanceType,
          salary.mealAllowancePerDay,
          salary.workingDaysPerMonth,
          taxResult.incomeTaxRate,
          taxSystem.socialContributionRate,
        )
      : const MealAllowanceCalculation();

  return SalaryCalculation(
    grossAmount: baseGross,
    effectiveGrossAmount: effectiveGross,
    subsidyMonthlyBonus: subsidyBonus,
    otherExemptIncome: salary.otherExemptIncome,
    irsRetention: taxResult.incomeTax,
    irsRate: taxResult.incomeTaxRate,
    socialSecurity: taxResult.socialContribution,
    socialSecurityRate: taxSystem.socialContributionRate,
    netAmount: netAmount,
    mealAllowance: meal,
    totalNetWithMeal: _round2(netAmount + meal.netMealAllowance + salary.otherExemptIncome),
  );
}

/// Calcula o resumo completo do orçamento mensal
BudgetSummary calculateBudgetSummary(
  List<SalaryInfo> salaries,
  PersonalInfo personalInfo,
  List<ExpenseItem> expenses,
  TaxSystem taxSystem, {
  Map<String, double> monthlyBudgets = const {},
}) {
  final calcs = salaries.map((s) {
    if (!s.enabled) return const SalaryCalculation();
    return calculateNetSalary(s, personalInfo, taxSystem);
  }).toList();

  final totalGross = calcs.fold(0.0, (sum, s) => sum + s.effectiveGrossAmount);
  final totalNet = calcs.fold(0.0, (sum, s) => sum + s.netAmount);
  final totalMealAllowance = calcs.fold(0.0, (sum, s) => sum + s.mealAllowance.netMealAllowance);
  final totalNetWithMeal = calcs.fold(0.0, (sum, s) => sum + s.totalNetWithMeal);
  final totalIRS = calcs.fold(0.0, (sum, s) => sum + s.irsRetention + s.mealAllowance.irsTaxOnMeal);
  final totalSS = calcs.fold(0.0, (sum, s) => sum + s.socialSecurity + s.mealAllowance.ssTaxOnMeal);
  final totalDeductions = totalIRS + totalSS;

  // Sum per-category default amounts, then apply monthly overrides
  final defaultByCategory = <String, double>{};
  for (final e in expenses.where((e) => e.enabled)) {
    defaultByCategory[e.category.name] =
        (defaultByCategory[e.category.name] ?? 0) + e.amount;
  }
  final totalExpenses = defaultByCategory.entries.fold(0.0, (sum, entry) {
    return sum + (monthlyBudgets[entry.key] ?? entry.value);
  });

  final netLiquidity = _round2(totalNetWithMeal - totalExpenses);
  final savingsRate = totalNetWithMeal > 0 ? netLiquidity / totalNetWithMeal : 0.0;

  return BudgetSummary(
    salaries: calcs,
    totalGross: totalGross,
    totalNet: totalNet,
    totalNetWithMeal: totalNetWithMeal,
    totalMealAllowance: totalMealAllowance,
    totalIRS: totalIRS,
    totalSS: totalSS,
    totalDeductions: totalDeductions,
    totalExpenses: totalExpenses,
    netLiquidity: netLiquidity,
    savingsRate: (savingsRate * 10000).roundToDouble() / 10000,
  );
}
