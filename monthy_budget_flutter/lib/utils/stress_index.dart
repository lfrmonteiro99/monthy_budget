import '../models/app_settings.dart';
import '../models/budget_summary.dart';
import '../models/purchase_record.dart';
import '../l10n/generated/app_localizations.dart';

enum StressFactorType {
  savings,
  safety,
  food,
  stability;

  String localizedLabel(S l10n) {
    switch (this) {
      case StressFactorType.savings: return l10n.stressFactorSavings;
      case StressFactorType.safety: return l10n.stressFactorSafety;
      case StressFactorType.food: return l10n.stressFactorFood;
      case StressFactorType.stability: return l10n.stressFactorStability;
    }
  }
}

enum StressLevel {
  excellent,
  good,
  warning,
  critical;

  String localizedLabel(S l10n) {
    switch (this) {
      case StressLevel.excellent: return l10n.stressExcellent;
      case StressLevel.good: return l10n.stressGood;
      case StressLevel.warning: return l10n.stressWarning;
      case StressLevel.critical: return l10n.stressCritical;
    }
  }
}

class StressFactorResult {
  final StressFactorType type;
  final String valueLabel;
  final bool ok;
  final double normalizedScore;

  const StressFactorResult({
    required this.type,
    required this.valueLabel,
    required this.ok,
    required this.normalizedScore,
  });
}

class StressIndexResult {
  final int score;
  final StressLevel level;
  final List<StressFactorResult> factors;
  final int? previousScore;

  const StressIndexResult({
    required this.score,
    required this.level,
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

  // Factor 1 — Savings rate (35%)
  final savingsRate = summary.savingsRate.clamp(0.0, 1.0);
  final savingsScore = (savingsRate / 0.25 * 100).clamp(0.0, 100.0);
  final savingsFactor = StressFactorResult(
    type: StressFactorType.savings,
    valueLabel: '${(savingsRate * 100).toStringAsFixed(0)}%',
    ok: savingsRate >= 0.10,
    normalizedScore: savingsScore,
  );

  // Factor 2 — Safety margin / liquidity (30%)
  final liquidity = summary.netLiquidity;
  final liquidityScore = (liquidity / 500.0 * 100).clamp(0.0, 100.0);
  final liquidityFactor = StressFactorResult(
    type: StressFactorType.safety,
    valueLabel: '${liquidity.toStringAsFixed(0)}\u20ac',
    ok: liquidity >= 100,
    normalizedScore: liquidityScore,
  );

  // Factor 3 — Food budget (20%)
  final foodBudget = settings.expenses
      .where((e) => e.category == ExpenseCategory.alimentacao && e.enabled)
      .fold(0.0, (s, e) => s + e.amount);
  final foodSpent = purchaseHistory.spentInMonth(now.year, now.month);
  final hasFoodBudget = foodBudget > 0;
  final foodRatio =
      hasFoodBudget ? (foodSpent / foodBudget).clamp(0.0, 2.0) : 0.0;
  final foodScore = ((1.0 - foodRatio) * 100).clamp(0.0, 100.0);
  final foodValueLabel = hasFoodBudget
      ? (foodRatio * 100).toStringAsFixed(0)
      : null;
  final foodFactor = StressFactorResult(
    type: StressFactorType.food,
    valueLabel: foodValueLabel ?? '',
    ok: foodRatio <= 0.80,
    normalizedScore: foodScore,
  );

  // Factor 4 — Expense stability (15%)
  final totalNet = summary.totalNetWithMeal;
  final expenseRatio = totalNet > 0
      ? (summary.totalExpenses / totalNet).clamp(0.0, 1.5)
      : 1.0;
  final stabilityScore = ((1.0 - expenseRatio) * 100).clamp(0.0, 100.0);
  final stabilityFactor = StressFactorResult(
    type: StressFactorType.stability,
    valueLabel: expenseRatio <= 0.70 ? 'stable' : 'high',
    ok: expenseRatio <= 0.70,
    normalizedScore: stabilityScore,
  );

  final score = (savingsScore * 0.35 +
          liquidityScore * 0.30 +
          foodScore * 0.20 +
          stabilityScore * 0.15)
      .round()
      .clamp(0, 100);

  final level = score >= 80
      ? StressLevel.excellent
      : score >= 60
          ? StressLevel.good
          : score >= 40
              ? StressLevel.warning
              : StressLevel.critical;

  return StressIndexResult(
    score: score,
    level: level,
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
  required double budget,
  required double spent,
  required DateTime now,
}) {
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
  final daysElapsed = now.day;
  final daysRemaining = daysInMonth - daysElapsed;

  final dailyPace = daysElapsed > 0 ? spent / daysElapsed : 0.0;
  final expectedPace = budget / daysInMonth;
  final projectedTotal = spent + (dailyPace * daysRemaining);
  final projectedOverspend = projectedTotal - budget;

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
