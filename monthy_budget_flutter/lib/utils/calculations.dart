import 'dart:math' as math;
import '../models/app_settings.dart';
import '../models/budget_summary.dart';
import '../data/irs_tables.dart';

double _round2(double v) => (v * 100).roundToDouble() / 100;

/// Calcula a retenção de IRS para um dado salário bruto
({double retention, double rate}) calculateIRSRetention(
  double grossSalary,
  PersonalInfo personalInfo,
  int titulares,
) {
  if (grossSalary <= 0) return (retention: 0, rate: 0);

  final table = getApplicableTable(
    personalInfo.maritalStatus.jsonValue,
    titulares,
    personalInfo.dependentes,
  );

  final bracket = table.brackets.cast<IRSBracket?>().firstWhere(
        (b) => grossSalary <= b!.upTo,
        orElse: () => null,
      );

  if (bracket == null || bracket.rate == 0) {
    return (retention: 0, rate: 0);
  }

  final retention = grossSalary * bracket.rate -
      bracket.parcelaAbater -
      bracket.parcelaDependente * personalInfo.dependentes;

  final finalRetention = math.max(0.0, _round2(retention));
  final effectiveRate = grossSalary > 0 ? finalRetention / grossSalary : 0.0;

  return (
    retention: finalRetention,
    rate: (effectiveRate * 10000).roundToDouble() / 10000,
  );
}

/// Calcula a contribuição para a Segurança Social (11%)
double calculateSocialSecurity(double grossSalary) {
  if (grossSalary <= 0) return 0;
  return _round2(grossSalary * socialSecurityRate);
}

/// Calcula o subsidio de alimentação mensal
MealAllowanceCalculation calculateMealAllowance(
  MealAllowanceType type,
  double perDay,
  int workingDays,
  double irsRate,
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
  final ssTaxOnMeal = _round2(taxablePortion * socialSecurityRate);
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

/// Calcula o salário líquido completo
SalaryCalculation calculateNetSalary(
  SalaryInfo salary,
  PersonalInfo personalInfo,
) {
  final grossSalary = salary.grossAmount;

  if (grossSalary <= 0) {
    final meal = calculateMealAllowance(
      salary.mealAllowanceType,
      salary.mealAllowancePerDay,
      salary.workingDaysPerMonth,
      0,
    );
    return SalaryCalculation(
      grossAmount: 0,
      irsRetention: 0,
      irsRate: 0,
      socialSecurity: 0,
      socialSecurityRate: socialSecurityRate,
      netAmount: 0,
      mealAllowance: meal,
      totalNetWithMeal: meal.netMealAllowance,
    );
  }

  final irs = calculateIRSRetention(grossSalary, personalInfo, salary.titulares);
  final ss = calculateSocialSecurity(grossSalary);
  final net = _round2(grossSalary - irs.retention - ss);
  final netAmount = math.max(0.0, net);

  final meal = calculateMealAllowance(
    salary.mealAllowanceType,
    salary.mealAllowancePerDay,
    salary.workingDaysPerMonth,
    irs.rate,
  );

  return SalaryCalculation(
    grossAmount: grossSalary,
    irsRetention: irs.retention,
    irsRate: irs.rate,
    socialSecurity: ss,
    socialSecurityRate: socialSecurityRate,
    netAmount: netAmount,
    mealAllowance: meal,
    totalNetWithMeal: _round2(netAmount + meal.netMealAllowance),
  );
}

/// Calcula o resumo completo do orçamento mensal
BudgetSummary calculateBudgetSummary(
  List<SalaryInfo> salaries,
  PersonalInfo personalInfo,
  List<ExpenseItem> expenses,
) {
  SalaryInfo disabledSalary(SalaryInfo s) => s.copyWith(grossAmount: 0);

  final salary1 = calculateNetSalary(
    salaries[0].enabled ? salaries[0] : disabledSalary(salaries[0]),
    personalInfo,
  );
  final salary2 = salaries.length > 1
      ? calculateNetSalary(
          salaries[1].enabled ? salaries[1] : disabledSalary(salaries[1]),
          personalInfo,
        )
      : const SalaryCalculation();

  final totalGross = salary1.grossAmount + salary2.grossAmount;
  final totalNet = salary1.netAmount + salary2.netAmount;
  final totalMealAllowance =
      salary1.mealAllowance.netMealAllowance + salary2.mealAllowance.netMealAllowance;
  final totalNetWithMeal = salary1.totalNetWithMeal + salary2.totalNetWithMeal;
  final totalIRS = salary1.irsRetention +
      salary2.irsRetention +
      salary1.mealAllowance.irsTaxOnMeal +
      salary2.mealAllowance.irsTaxOnMeal;
  final totalSS = salary1.socialSecurity +
      salary2.socialSecurity +
      salary1.mealAllowance.ssTaxOnMeal +
      salary2.mealAllowance.ssTaxOnMeal;
  final totalDeductions = totalIRS + totalSS;

  final totalExpenses = expenses
      .where((e) => e.enabled)
      .fold(0.0, (sum, e) => sum + e.amount);

  final netLiquidity = _round2(totalNetWithMeal - totalExpenses);
  final savingsRate = totalNetWithMeal > 0 ? netLiquidity / totalNetWithMeal : 0.0;

  return BudgetSummary(
    salary1: salary1,
    salary2: salary2,
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
