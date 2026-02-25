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

/// Calcula o salário líquido completo, considerando duodécimos e rendimentos isentos
SalaryCalculation calculateNetSalary(
  SalaryInfo salary,
  PersonalInfo personalInfo,
) {
  final baseGross = salary.grossAmount;
  // Com duodécimos, o bruto efetivo mensal é mais alto (IRS/SS incidem sobre ele)
  final effectiveGross = _round2(baseGross * salary.subsidyMode.monthlyFactor);
  final subsidyBonus = _round2(effectiveGross - baseGross);

  if (effectiveGross <= 0) {
    final meal = calculateMealAllowance(
      salary.mealAllowanceType,
      salary.mealAllowancePerDay,
      salary.workingDaysPerMonth,
      0,
    );
    return SalaryCalculation(
      grossAmount: baseGross,
      effectiveGrossAmount: 0,
      subsidyMonthlyBonus: 0,
      otherExemptIncome: salary.otherExemptIncome,
      irsRetention: 0,
      irsRate: 0,
      socialSecurity: 0,
      socialSecurityRate: socialSecurityRate,
      netAmount: 0,
      mealAllowance: meal,
      totalNetWithMeal: _round2(meal.netMealAllowance + salary.otherExemptIncome),
    );
  }

  final irs = calculateIRSRetention(effectiveGross, personalInfo, salary.titulares);
  final ss = calculateSocialSecurity(effectiveGross);
  final net = _round2(effectiveGross - irs.retention - ss);
  final netAmount = math.max(0.0, net);

  final meal = calculateMealAllowance(
    salary.mealAllowanceType,
    salary.mealAllowancePerDay,
    salary.workingDaysPerMonth,
    irs.rate,
  );

  return SalaryCalculation(
    grossAmount: baseGross,
    effectiveGrossAmount: effectiveGross,
    subsidyMonthlyBonus: subsidyBonus,
    otherExemptIncome: salary.otherExemptIncome,
    irsRetention: irs.retention,
    irsRate: irs.rate,
    socialSecurity: ss,
    socialSecurityRate: socialSecurityRate,
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
) {
  final calcs = salaries.map((s) {
    if (!s.enabled) return const SalaryCalculation();
    return calculateNetSalary(s, personalInfo);
  }).toList();

  final totalGross = calcs.fold(0.0, (sum, s) => sum + s.effectiveGrossAmount);
  final totalNet = calcs.fold(0.0, (sum, s) => sum + s.netAmount);
  final totalMealAllowance = calcs.fold(0.0, (sum, s) => sum + s.mealAllowance.netMealAllowance);
  final totalNetWithMeal = calcs.fold(0.0, (sum, s) => sum + s.totalNetWithMeal);
  final totalIRS = calcs.fold(0.0, (sum, s) => sum + s.irsRetention + s.mealAllowance.irsTaxOnMeal);
  final totalSS = calcs.fold(0.0, (sum, s) => sum + s.socialSecurity + s.mealAllowance.ssTaxOnMeal);
  final totalDeductions = totalIRS + totalSS;

  final totalExpenses = expenses
      .where((e) => e.enabled)
      .fold(0.0, (sum, e) => sum + e.amount);

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
