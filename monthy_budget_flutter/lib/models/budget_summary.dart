class MealAllowanceCalculation {
  final double totalMonthly;
  final double exemptPortion;
  final double taxablePortion;
  final double irsTaxOnMeal;
  final double ssTaxOnMeal;
  final double netMealAllowance;

  const MealAllowanceCalculation({
    this.totalMonthly = 0,
    this.exemptPortion = 0,
    this.taxablePortion = 0,
    this.irsTaxOnMeal = 0,
    this.ssTaxOnMeal = 0,
    this.netMealAllowance = 0,
  });
}

class SalaryCalculation {
  final double grossAmount;
  final double irsRetention;
  final double irsRate;
  final double socialSecurity;
  final double socialSecurityRate;
  final double netAmount;
  final MealAllowanceCalculation mealAllowance;
  final double totalNetWithMeal;

  const SalaryCalculation({
    this.grossAmount = 0,
    this.irsRetention = 0,
    this.irsRate = 0,
    this.socialSecurity = 0,
    this.socialSecurityRate = 0.11,
    this.netAmount = 0,
    this.mealAllowance = const MealAllowanceCalculation(),
    this.totalNetWithMeal = 0,
  });
}

class BudgetSummary {
  final SalaryCalculation salary1;
  final SalaryCalculation salary2;
  final double totalGross;
  final double totalNet;
  final double totalNetWithMeal;
  final double totalMealAllowance;
  final double totalIRS;
  final double totalSS;
  final double totalDeductions;
  final double totalExpenses;
  final double netLiquidity;
  final double savingsRate;

  const BudgetSummary({
    this.salary1 = const SalaryCalculation(),
    this.salary2 = const SalaryCalculation(),
    this.totalGross = 0,
    this.totalNet = 0,
    this.totalNetWithMeal = 0,
    this.totalMealAllowance = 0,
    this.totalIRS = 0,
    this.totalSS = 0,
    this.totalDeductions = 0,
    this.totalExpenses = 0,
    this.netLiquidity = 0,
    this.savingsRate = 0,
  });
}
