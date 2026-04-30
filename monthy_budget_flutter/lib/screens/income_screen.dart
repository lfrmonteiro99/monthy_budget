import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';
import '../models/budget_summary.dart';
import '../services/income_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart' show localizedMonthFull;
import '../widgets/income/add_income_source_sheet.dart';
import '../widgets/income/income.dart';

/// Calm rollout — Income screen.
///
/// Shows the user the current month's income from the perspective of:
///   1. how much landed already vs how much is still pending
///   2. how income trended over the last 6 months
///   3. where each source comes from (salary, rentals, freelance, …)
///   4. how the planned amount is allocated (fixed / variable / saved /
///      remaining)
///   5. an insight on the savings rate
///
/// The component is pure UI — it expects derived data via [breakdown] and
/// the user-managed list of extra entries via [sources]. State is hoisted
/// to `app_home.dart`, which persists `incomeSources` on `AppSettings`.
class IncomeScreen extends StatelessWidget {
  const IncomeScreen({
    super.key,
    required this.summary,
    required this.sources,
    required this.breakdown,
    required this.onAddSource,
    required this.onUpdateSource,
    required this.onDeleteSource,
    required this.onAllocateToGoal,
    required this.onViewProjection,
  });

  /// Current-month budget summary (for salary baseline + total expenses).
  final BudgetSummary summary;

  /// Extra income sources stored on `AppSettings.incomeSources`.
  final List<IncomeSource> sources;

  /// Pre-computed by `IncomeService.calculate`.
  final IncomeBreakdown breakdown;

  /// Persists a brand-new source to the user's settings.
  final ValueChanged<IncomeSource> onAddSource;

  /// Persists edits to an existing source.
  final ValueChanged<IncomeSource> onUpdateSource;

  /// Removes a source from the user's settings.
  final ValueChanged<IncomeSource> onDeleteSource;

  /// Opens the savings-goal picker.
  final VoidCallback onAllocateToGoal;

  /// Opens the yearly-summary projection.
  final VoidCallback onViewProjection;

  bool get _isEmpty =>
      sources.isEmpty && summary.totalNetWithMeal <= 0;

  Future<void> _openAddSheet(BuildContext context, {IncomeSource? edit}) async {
    final result = await showAddIncomeSourceSheet(
      context: context,
      existing: edit,
    );
    if (result == null) return;
    if (edit == null) {
      onAddSource(result);
    } else {
      onUpdateSource(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final now = DateTime.now();
    final monthName = localizedMonthFull(l10n, now.month);

    return CalmScaffold(
      bodyPadding: EdgeInsets.zero,
      body: Column(
        children: [
          CalmPageHeader(
            eyebrow: l10n.incomeHeaderEyebrow(monthName),
            title: l10n.incomeHeaderTitle,
            trailing: _AddButton(onTap: () => _openAddSheet(context)),
          ),
          Expanded(
            child: _isEmpty
                ? IncomeEmptyState(
                    onAddSource: () => _openAddSheet(context),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    children: [
                      IncomeHero(
                        received: breakdown.receivedThisMonth,
                        expected: breakdown.expected,
                        confirmedCount: _confirmedCount(),
                      ),
                      IncomeTrendCard(
                        values: breakdown.trend6m,
                        average: breakdown.trend6mAverage,
                        delta: breakdown.trendDelta,
                      ),
                      const SizedBox(height: 14),
                      _SectionHeader(label: l10n.incomeSourcesEyebrow),
                      const SizedBox(height: 8),
                      _SourcesCard(
                        sources: const IncomeService().orderedSources(sources),
                        onTap: (s) => _openAddSheet(context, edit: s),
                      ),
                      const SizedBox(height: 18),
                      _SectionHeader(label: l10n.incomeAllocationEyebrow),
                      const SizedBox(height: 8),
                      IncomeAllocationCard(
                        allocation: breakdown.allocation,
                        planned: breakdown.planned,
                      ),
                      const SizedBox(height: 14),
                      SavingsRateInsightCard(
                        savedThisMonth: breakdown.allocation.saved,
                        savingsRate: breakdown.savingsRate,
                        onAllocate: onAllocateToGoal,
                        onViewProjection: onViewProjection,
                      ),
                      const SizedBox(height: 16),
                      _Footnote(text: l10n.incomeFootnote),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  int _confirmedCount() {
    final extras = sources.where((s) => s.received).length;
    final salaries = summary.salaries
        .where((s) => s.totalNetWithMeal > 0)
        .length;
    return extras + salaries;
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: AppColors.ink(context),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Icon(
            Icons.add,
            size: 18,
            color: AppColors.inkInverse(context),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    this.action,
    this.onAction,
  });

  final String label;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: CalmEyebrow(label.toUpperCase())),
          if (action != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.accent(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SourcesCard extends StatelessWidget {
  const _SourcesCard({required this.sources, required this.onTap});

  final List<IncomeSource> sources;
  final ValueChanged<IncomeSource> onTap;

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) {
      return CalmCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            S.of(context).incomeSourcesEmpty,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.ink50(context),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < sources.length; i++)
            IncomeSourceRow(
              source: sources[i],
              onTap: () => onTap(sources[i]),
              dividerBelow: i < sources.length - 1,
            ),
        ],
      ),
    );
  }
}

class _Footnote extends StatelessWidget {
  const _Footnote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11.5,
          height: 1.5,
          color: AppColors.ink50(context),
        ),
      ),
    );
  }
}
