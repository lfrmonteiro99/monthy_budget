import '../l10n/generated/app_localizations.dart';
import '../models/budget_summary.dart';
import '../screens/more_screen.dart' show MoreObservation;
import '../widgets/calm/calm_observation_card.dart';

/// Top spending category used to generate the headline observation.
///
/// Mirrors the shape returned by `_topCategoryUsage()` in `app_home.dart`.
class TopCategoryUsage {
  const TopCategoryUsage({required this.category, required this.percent});

  final String category;

  /// Percentage of budget consumed (e.g. 143.0 means spent 143% of budget).
  final double percent;
}

/// Bundle returned by [MoreContextBuilder.build]: ready-to-render coach
/// quote and observation list for the More tab.
class MoreContext {
  const MoreContext({
    required this.coachQuote,
    required this.observations,
  });

  final String coachQuote;
  final List<MoreObservation> observations;
}

/// Pure helper that derives the More tab's dynamic content from existing
/// budget data. Pulled out of `more_screen.dart` so it is unit-testable
/// without pumping a widget tree.
///
/// Coach quote precedence (highest first):
///   1. **`liveQuote`** — most recent LLM-generated insight from
///      `AiCoachService.loadInsights()`, when supplied and non-empty.
///      This matches the brief: "a citação tem de vir do back-end
///      (endpoint do coach LLM)".
///   2. **Projection rule** — if the user has positive net liquidity
///      this month, surface a projected savings line.
///   3. **Static fallback** — `moreCoachFallbackQuote`.
///
/// Observation rules (v1, deliberately small):
///   * **Over-budget category** — when the worst-spending category is
///     > 110% of its budget, emit a `warning` observation.
///   * **Good savings** — when the savings rate is ≥ 20%, emit a
///     `success` observation.
///   * **Low savings** — when the savings rate is < 10% *and* there is
///     no over-budget category to show, emit a `warning` about the
///     savings rate (we don't double-warn).
class MoreContextBuilder {
  const MoreContextBuilder._();

  /// Soft cap on how long an LLM-generated quote is allowed to render
  /// before it dwarfs the rest of the hero card. Anything longer is
  /// truncated with an ellipsis.
  static const int liveQuoteMaxChars = 220;

  static MoreContext build({
    required BudgetSummary summary,
    required TopCategoryUsage? topCategory,
    required S l10n,
    String? liveQuote,
  }) {
    final coachQuote = _resolveCoachQuote(
      summary: summary,
      l10n: l10n,
      liveQuote: liveQuote,
    );

    final observations = <MoreObservation>[];

    final overBudget = topCategory != null && topCategory.percent > 110
        ? topCategory
        : null;
    if (overBudget != null) {
      final overshoot = (overBudget.percent - 100).round();
      observations.add(
        MoreObservation(
          id: 'cat-over-${overBudget.category}',
          kind: CalmObservationKind.warning,
          title: l10n.moreObsCatOverTitle(overBudget.category, overshoot),
          body: l10n.moreObsCatOverBody,
        ),
      );
    }

    final savingsPct = (summary.savingsRate * 100).round();
    if (summary.savingsRate >= 0.20) {
      observations.add(
        MoreObservation(
          id: 'savings-good',
          kind: CalmObservationKind.success,
          title: l10n.moreObsGoodSavingsTitle(savingsPct),
          body: l10n.moreObsGoodSavingsBody,
        ),
      );
    } else if (overBudget == null &&
        summary.savingsRate < 0.10 &&
        summary.totalExpenses > 0) {
      observations.add(
        MoreObservation(
          id: 'savings-low',
          kind: CalmObservationKind.warning,
          title: l10n.moreObsLowSavingsTitle,
          body: l10n.moreObsLowSavingsBody,
        ),
      );
    }

    return MoreContext(
      coachQuote: coachQuote,
      observations: List.unmodifiable(observations),
    );
  }

  static String _resolveCoachQuote({
    required BudgetSummary summary,
    required S l10n,
    required String? liveQuote,
  }) {
    final live = liveQuote?.trim() ?? '';
    if (live.isNotEmpty) {
      return live.length > liveQuoteMaxChars
          ? '${live.substring(0, liveQuoteMaxChars - 1).trimRight()}…'
          : live;
    }
    final hasIncome = summary.totalNetWithMeal > 0;
    if (hasIncome && summary.netLiquidity > 0) {
      return l10n.moreCoachProjectionFmt(summary.netLiquidity.round());
    }
    return l10n.moreCoachFallbackQuote;
  }
}
