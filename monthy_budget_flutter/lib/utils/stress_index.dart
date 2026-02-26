import '../models/app_settings.dart';
import '../models/budget_summary.dart';
import '../models/purchase_record.dart';

class StressFactorResult {
  final String label;
  final String valueLabel;
  final bool ok;
  final double normalizedScore;

  const StressFactorResult({
    required this.label,
    required this.valueLabel,
    required this.ok,
    required this.normalizedScore,
  });
}

class StressIndexResult {
  final int score;
  final String label;
  final List<StressFactorResult> factors;
  final int? previousScore;

  const StressIndexResult({
    required this.score,
    required this.label,
    required this.factors,
    this.previousScore,
  });

  int? get delta => previousScore != null ? score - previousScore! : null;
}

StressIndexResult calculateStressIndex({
  required BudgetSummary summary,
  required PurchaseHistory purchaseHistory,
  required AppSettings settings,
}) {
  final now = DateTime.now();
  final prevMonth = now.month == 1 ? 12 : now.month - 1;
  final prevYear = now.month == 1 ? now.year - 1 : now.year;
  final prevKey = '$prevYear-${prevMonth.toString().padLeft(2, '0')}';
  final previousScore = settings.stressHistory[prevKey];

  // Factor 1 — Taxa de poupança (35%)
  final savingsRate = summary.savingsRate.clamp(0.0, 1.0);
  final savingsScore = (savingsRate / 0.25 * 100).clamp(0.0, 100.0);
  final savingsFactor = StressFactorResult(
    label: 'Taxa de poupança',
    valueLabel: '${(savingsRate * 100).toStringAsFixed(0)}%',
    ok: savingsRate >= 0.10,
    normalizedScore: savingsScore,
  );

  // Factor 2 — Margem de segurança / liquidez (30%)
  final liquidity = summary.netLiquidity;
  final liquidityScore = (liquidity / 500.0 * 100).clamp(0.0, 100.0);
  final liquidityFactor = StressFactorResult(
    label: 'Margem de segurança',
    valueLabel: '${liquidity.toStringAsFixed(0)}€',
    ok: liquidity >= 100,
    normalizedScore: liquidityScore,
  );

  // Factor 3 — Orçamento alimentação (20%)
  final foodBudget = settings.expenses
      .where((e) => e.category == ExpenseCategory.alimentacao && e.enabled)
      .fold(0.0, (s, e) => s + e.amount);
  final foodSpent = purchaseHistory.spentInMonth(now.year, now.month);
  final hasFoodBudget = foodBudget > 0;
  final foodRatio =
      hasFoodBudget ? (foodSpent / foodBudget).clamp(0.0, 2.0) : 0.0;
  final foodScore = ((1.0 - foodRatio) * 100).clamp(0.0, 100.0);
  final foodFactor = StressFactorResult(
    label: 'Orçamento alimentação',
    valueLabel: hasFoodBudget
        ? '${(foodRatio * 100).toStringAsFixed(0)}% usado'
        : 'N/D',
    ok: foodRatio <= 0.80,
    normalizedScore: foodScore,
  );

  // Factor 4 — Estabilidade despesas (15%)
  final totalNet = summary.totalNetWithMeal;
  final expenseRatio = totalNet > 0
      ? (summary.totalExpenses / totalNet).clamp(0.0, 1.5)
      : 1.0;
  final stabilityScore = ((1.0 - expenseRatio) * 100).clamp(0.0, 100.0);
  final stabilityFactor = StressFactorResult(
    label: 'Estabilidade despesas',
    valueLabel: expenseRatio <= 0.70 ? 'Estável' : 'Elevada',
    ok: expenseRatio <= 0.70,
    normalizedScore: stabilityScore,
  );

  final score = (savingsScore * 0.35 +
          liquidityScore * 0.30 +
          foodScore * 0.20 +
          stabilityScore * 0.15)
      .round()
      .clamp(0, 100);

  final label = score >= 80
      ? 'Excelente'
      : score >= 60
          ? 'Bom'
          : score >= 40
              ? 'Atenção'
              : 'Crítico';

  return StressIndexResult(
    score: score,
    label: label,
    factors: [savingsFactor, liquidityFactor, foodFactor, stabilityFactor],
    previousScore: previousScore,
  );
}

class BudgetPaceResult {
  final double dailyPace;
  final double expectedPace;
  final double projectedTotal;
  final double projectedOverspend;
  final bool isOverPace;
  final String severity; // 'ok' | 'warning' | 'danger'
  final int daysElapsed;
  final int daysRemaining;

  const BudgetPaceResult({
    required this.dailyPace,
    required this.expectedPace,
    required this.projectedTotal,
    required this.projectedOverspend,
    required this.isOverPace,
    required this.severity,
    required this.daysElapsed,
    required this.daysRemaining,
  });
}

BudgetPaceResult checkBudgetPace({
  required double foodBudget,
  required double foodSpent,
  required DateTime now,
}) {
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  final daysElapsed = now.day;
  final daysRemaining = daysInMonth - daysElapsed;

  final dailyPace = daysElapsed > 0 ? foodSpent / daysElapsed : 0.0;
  final expectedPace = foodBudget / daysInMonth;
  final projectedTotal = foodSpent + (dailyPace * daysRemaining);
  final projectedOverspend = projectedTotal - foodBudget;

  final paceRatio = expectedPace > 0 ? dailyPace / expectedPace : 0.0;
  final severity = paceRatio <= 1.0
      ? 'ok'
      : paceRatio <= 1.2
          ? 'warning'
          : 'danger';

  return BudgetPaceResult(
    dailyPace: dailyPace,
    expectedPace: expectedPace,
    projectedTotal: projectedTotal,
    projectedOverspend: projectedOverspend,
    isOverPace: paceRatio > 1.0,
    severity: severity,
    daysElapsed: daysElapsed,
    daysRemaining: daysRemaining,
  );
}
