import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/savings_goal.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/savings_projections.dart';
import 'info_icon_button.dart';

/// Compact dashboard card showing top 1-2 active savings goals with progress bars
/// and projection info when available.
class SavingsGoalCard extends StatelessWidget {
  final List<SavingsGoal> goals;
  final VoidCallback onSeeAll;
  final Map<String, SavingsProjection> projections;

  const SavingsGoalCard({
    super.key,
    required this.goals,
    required this.onSeeAll,
    this.projections = const {},
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final active = goals.where((g) => g.isActive && !g.isCompleted).toList();
    final display = active.take(2).toList();

    if (display.isEmpty) {
      // Show completed or empty state
      final completed = goals.where((g) => g.isCompleted).toList();
      if (completed.isNotEmpty) {
        return _wrapper(
          context,
          l10n,
          children: [
            _CompletedRow(goal: completed.first),
          ],
        );
      }
      return _wrapper(
        context,
        l10n,
        children: [
          Text(
            l10n.savingsGoalEmpty,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.ink50(context),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onSeeAll,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.savingsGoalSeeAll),
            ),
          ),
        ],
      );
    }

    final pausedCount = goals.where((g) => !g.isActive).length;
    return _wrapper(
      context,
      l10n,
      children: [
        ...display.map((g) => _GoalRow(
              goal: g,
              projection: projections[g.id],
            )),
        if (pausedCount > 0)
          GestureDetector(
            onTap: onSeeAll,
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '+$pausedCount paused goals',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.ink50(context),
                ),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            l10n.savingsGoalDashboardHint,
            style: TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: AppColors.ink50(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _wrapper(
    BuildContext context,
    S l10n, {
    required List<Widget> children,
  }) {
    return CalmCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.savings_outlined,
                  size: 18, color: AppColors.ink70(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.savingsGoals,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink(context),
                  ),
                ),
              ),
              InfoIconButton(title: l10n.savingsGoals, body: l10n.infoSavingsGoals),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  l10n.savingsGoalSeeAll,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.accent(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  final SavingsGoal goal;
  final SavingsProjection? projection;
  const _GoalRow({required this.goal, this.projection});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final progressColor = goal.isCompleted
        ? AppColors.ok(context)
        : AppColors.accent(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: progressColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  goal.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.ink(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                l10n.savingsGoalProgress(
                    '${(goal.progress * 100).toStringAsFixed(0)}%'),
                style: CalmText.amount(context,
                    size: 11, weight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Semantics(
            label: '${goal.name} progress ${(goal.progress * 100).round()}%',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: goal.progress,
                backgroundColor: AppColors.ink20(context),
                valueColor:
                    AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                '${formatCurrency(goal.currentAmount)} / ${formatCurrency(goal.targetAmount)}',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.ink50(context),
                ),
              ),
              const Spacer(),
              if (projection != null) _buildProjectionText(context, l10n),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectionText(BuildContext context, S l10n) {
    final p = projection!;
    if (!p.hasData) {
      return Text(
        l10n.savingsProjectionNoData,
        style: TextStyle(
          fontSize: 10,
          color: AppColors.ink50(context),
          fontStyle: FontStyle.italic,
        ),
      );
    }

    if (p.projectedDate != null && p.onTrack != null) {
      final dateStr =
          '${p.projectedDate!.month.toString().padLeft(2, '0')}/${p.projectedDate!.year}';
      final statusColor =
          p.onTrack! ? AppColors.ok(context) : AppColors.warn(context);
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            p.onTrack! ? Icons.check_circle_outline : Icons.warning_amber,
            size: 12,
            color: statusColor,
          ),
          const SizedBox(width: 3),
          Text(
            l10n.savingsProjectionReachedBy(dateStr),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ],
      );
    }

    if (p.projectedDate != null) {
      final dateStr =
          '${p.projectedDate!.month.toString().padLeft(2, '0')}/${p.projectedDate!.year}';
      return Text(
        l10n.savingsProjectionReachedBy(dateStr),
        style: TextStyle(
          fontSize: 10,
          color: AppColors.ink70(context),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _CompletedRow extends StatelessWidget {
  final SavingsGoal goal;
  const _CompletedRow({required this.goal});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Row(
      children: [
        Icon(Icons.check_circle,
            size: 16, color: AppColors.ok(context)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${goal.name} - ${l10n.savingsGoalCompleted}',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.ok(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

