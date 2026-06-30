import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/savings_goal.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../utils/savings_goal_format.dart';

/// List card representing a single savings goal, with progress, deadline and a
/// context menu for edit / activate / delete actions.
class GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final bool isFreeUser;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    this.isFreeUser = false,
    required this.onTap,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isPaused = !goal.isActive;
    final showProBadge = isPaused && isFreeUser;

    // Progress colour: completed → ok, paused-locked → ink20, else accent
    final progressColor = goal.isCompleted
        ? AppColors.ok(context)
        : (isPaused && isFreeUser)
            ? AppColors.ink20(context)
            : AppColors.accent(context);

    final deadlineInfo = savingsDeadlineLabel(goal, l10n);

    return Semantics(
      label: isPaused ? 'Paused - requires Pro subscription' : null,
      child: CalmCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isPaused && isFreeUser)
                  Icon(
                    Icons.lock_outline,
                    size: 12,
                    color: AppColors.ink50(context),
                  )
                else
                  CircleAvatar(
                    radius: 6,
                    backgroundColor: progressColor,
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    goal.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isPaused
                          ? AppColors.ink50(context)
                          : AppColors.ink(context),
                    ),
                  ),
                ),
                if (showProBadge)
                  CalmPill(
                    label: 'PRO',
                    color: AppColors.accent(context),
                  ),
                if (!showProBadge && goal.isCompleted)
                  CalmPill(
                    label: l10n.savingsGoalCompleted,
                    color: AppColors.ok(context),
                  ),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  onSelected: (action) {
                    switch (action) {
                      case 'edit':
                        onEdit();
                      case 'toggle':
                        onToggle();
                      case 'delete':
                        onDelete();
                    }
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(l10n.savingsGoalEdit),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Text(
                        goal.isActive
                            ? l10n.savingsGoalInactive
                            : l10n.savingsGoalActive,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        l10n.delete,
                        style: TextStyle(color: AppColors.bad(context)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: goal.progress,
                backgroundColor: AppColors.ink20(context),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),

            // Amount row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${formatCurrency(goal.currentAmount)} / ${formatCurrency(goal.targetAmount)}',
                  style: CalmText.amount(
                    context,
                    size: 13,
                    weight: FontWeight.w500,
                  ).copyWith(
                    color: isPaused
                        ? AppColors.ink50(context)
                        : AppColors.ink70(context),
                  ),
                ),
                Text(
                  l10n.savingsGoalProgress(
                    '${(goal.progress * 100).toStringAsFixed(0)}%',
                  ),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPaused
                        ? AppColors.ink50(context)
                        : progressColor,
                  ),
                ),
              ],
            ),

            if (!goal.isCompleted) ...[
              const SizedBox(height: 4),
              Text(
                l10n.savingsGoalRemaining(formatCurrency(goal.remaining)),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.ink50(context),
                ),
              ),
            ],

            if (deadlineInfo != null) ...[
              const SizedBox(height: 4),
              Text(
                deadlineInfo,
                style: TextStyle(
                  fontSize: 12,
                  color: savingsGoalIsOverdue(goal)
                      ? AppColors.bad(context)
                      : AppColors.ink50(context),
                ),
              ),
            ],

            if (isPaused && isFreeUser) ...[
              const SizedBox(height: 4),
              Text(
                'Paused — Free plan allows 1 goal',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: AppColors.ink50(context),
                ),
              ),
            ] else if (isPaused) ...[
              const SizedBox(height: 4),
              Text(
                l10n.savingsGoalInactive,
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: AppColors.ink50(context),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
