import '../models/app_settings.dart';
import '../models/budget_summary.dart';

/// Snapshot of derived income figures for the current month.
///
/// Built by [IncomeService.calculate] from the user's salaries (already
/// processed in [BudgetSummary]) plus the extra entries stored in
/// [AppSettings.incomeSources] (rentals, freelance, interest, IRS refund…).
///
/// All amounts are in the user's currency, no conversions performed.
class IncomeBreakdown {
  /// Sum of income that has effectively been credited this month.
  ///
  /// Includes: enabled salaries (as net-with-meal, treated as already
  /// received) + extra sources flagged `received == true`.
  final double receivedThisMonth;

  /// Sum of monthly extra sources that are still pending in the current
  /// month. Yearly entries (e.g. IRS refund) are excluded — they only
  /// surface in the list, never inflate the planned total.
  final double expected;

  /// `receivedThisMonth + expected`. Anchor for the hairline progress and
  /// the allocation breakdown.
  final double planned;

  /// Last 6 months of income (oldest → current). Length is always 6.
  final List<double> trend6m;

  /// Average of [trend6m] (rounded to integer for the hero pill).
  final double trend6mAverage;

  /// Delta vs previous month, expressed as fraction (0.042 → +4.2%).
  /// 0 when previous month is 0.
  final double trendDelta;

  /// Allocation of [planned] across the 4 buckets. Always sums to
  /// `planned` (`remaining` absorbs the residue).
  final IncomeAllocation allocation;

  /// Fraction of [planned] that ends up as savings (`saved / planned`).
  /// 0 when [planned] is 0. Computed in service to keep a single source
  /// of truth.
  final double savingsRate;

  const IncomeBreakdown({
    required this.receivedThisMonth,
    required this.expected,
    required this.planned,
    required this.trend6m,
    required this.trend6mAverage,
    required this.trendDelta,
    required this.allocation,
    required this.savingsRate,
  });

  bool get isEmpty => planned <= 0;
}

class IncomeAllocation {
  final double fixed;
  final double variable;
  final double saved;
  final double remaining;

  const IncomeAllocation({
    this.fixed = 0,
    this.variable = 0,
    this.saved = 0,
    this.remaining = 0,
  });

  double get total => fixed + variable + saved + remaining;
}

/// Pure functions over [IncomeSource] + [BudgetSummary] for the Income
/// screen. Stateless on purpose — no Supabase coupling.
class IncomeService {
  const IncomeService();

  /// Builds the current-month breakdown shown on the Income screen.
  ///
  /// - [summary] supplies the salary side (already net of taxes) and the
  ///   total monthly expenses.
  /// - [sources] are the extra entries stored on [AppSettings.incomeSources].
  /// - [savedThisMonth] is the explicit amount contributed to savings goals
  ///   in the current month (when known). When 0, falls back to
  ///   `max(0, planned - totalExpenses)`.
  /// - [previousMonthsIncome] are oldest → most-recent net incomes for the
  ///   5 months **before** the current one. Missing entries are padded
  ///   with the current month's salary baseline.
  /// - [fixedExpenses] is the portion of [summary.totalExpenses] that is
  ///   fixed (rent, telecom…). Defaults to 60% of total when not provided
  ///   so we never crash on legacy data.
  IncomeBreakdown calculate({
    required BudgetSummary summary,
    required List<IncomeSource> sources,
    double savedThisMonth = 0,
    List<double> previousMonthsIncome = const [],
    double? fixedExpenses,
  }) {
    final salaryNet = summary.totalNetWithMeal;
    final extrasReceived = sources
        .where((s) => s.received)
        .fold<double>(0, (a, s) => a + s.amount);
    final extrasExpected = sources
        .where((s) => !s.received && s.period == IncomePeriod.monthly)
        .fold<double>(0, (a, s) => a + s.amount);

    final receivedThisMonth = salaryNet + extrasReceived;
    final planned = receivedThisMonth + extrasExpected;

    // Trend: pad to 5 previous months, append current = receivedThisMonth.
    final trend = <double>[];
    for (var i = 0; i < 5; i++) {
      final idx = previousMonthsIncome.length - 5 + i;
      trend.add(idx >= 0 ? previousMonthsIncome[idx] : salaryNet);
    }
    trend.add(receivedThisMonth);
    final trendAvg = trend.reduce((a, b) => a + b) / trend.length;
    final prev = trend[trend.length - 2];
    final trendDelta = prev > 0 ? (receivedThisMonth - prev) / prev : 0.0;

    // Allocation: split planned into fixed / variable / saved / remaining.
    final totalExp = summary.totalExpenses;
    final fixed = (fixedExpenses ?? totalExp * 0.6).clamp(0, totalExp).toDouble();
    final variable = (totalExp - fixed).clamp(0, totalExp).toDouble();
    final saved = savedThisMonth > 0
        ? savedThisMonth.clamp(0, planned).toDouble()
        : (planned - totalExp).clamp(0, planned).toDouble();
    final remaining = (planned - fixed - variable - saved)
        .clamp(0, planned)
        .toDouble();

    final savingsRate = planned > 0 ? saved / planned : 0.0;

    return IncomeBreakdown(
      receivedThisMonth: _round2(receivedThisMonth),
      expected: _round2(extrasExpected),
      planned: _round2(planned),
      trend6m: trend.map(_round2).toList(growable: false),
      trend6mAverage: _round2(trendAvg),
      trendDelta: _round4(trendDelta),
      allocation: IncomeAllocation(
        fixed: _round2(fixed),
        variable: _round2(variable),
        saved: _round2(saved),
        remaining: _round2(remaining),
      ),
      savingsRate: _round4(savingsRate),
    );
  }

  /// Filters sources to those that should appear in the "Fontes" list,
  /// ordered as the spec wants: received first, then expected, then yearly.
  List<IncomeSource> orderedSources(List<IncomeSource> sources) {
    final list = [...sources];
    list.sort((a, b) {
      int rank(IncomeSource s) {
        if (s.received) return 0;
        if (s.period == IncomePeriod.yearly) return 2;
        return 1;
      }
      final r = rank(a).compareTo(rank(b));
      if (r != 0) return r;
      return b.amount.compareTo(a.amount);
    });
    return list;
  }
}

double _round2(double v) => (v * 100).roundToDouble() / 100;
double _round4(double v) => (v * 10000).roundToDouble() / 10000;
