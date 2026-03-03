import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/savings_goal.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

/// Compact dashboard card showing top 1-2 active savings goals with progress bars.
class SavingsGoalCard extends StatelessWidget {
  final List<SavingsGoal> goals;
  final VoidCallback onSeeAll;

  const SavingsGoalCard({
    super.key,
    required this.goals,
    required this.onSeeAll,
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
      return const SizedBox.shrink();
    }

    return _wrapper(
      context,
      l10n,
      children: display.map((g) => _GoalRow(goal: g)).toList(),
    );
  }

  Widget _wrapper(
    BuildContext context,
    S l10n, {
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.savings_outlined,
                  size: 18, color: AppColors.primary(context)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.savingsGoals,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: Text(
                  l10n.savingsGoalSeeAll,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary(context),
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
  const _GoalRow({required this.goal});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final goalColor = goal.color != null
        ? _hexToColor(goal.color!)
        : AppColors.primary(context);

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
                  color: goalColor,
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
                    color: AppColors.textPrimary(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                l10n.savingsGoalProgress(
                    '${(goal.progress * 100).toStringAsFixed(0)}%'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: goalColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: AppColors.border(context),
              color: goalColor,
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${formatCurrency(goal.currentAmount)} / ${formatCurrency(goal.targetAmount)}',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMuted(context),
            ),
          ),
        ],
      ),
    );
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
            size: 16, color: AppColors.success(context)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${goal.name} - ${l10n.savingsGoalCompleted}',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.success(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

Color _hexToColor(String hex) {
  final h = hex.replaceFirst('#', '');
  return Color(int.parse('FF$h', radix: 16));
}
