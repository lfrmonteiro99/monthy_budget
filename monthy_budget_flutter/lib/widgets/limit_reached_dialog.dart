import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';

/// Result of the limit-reached dialog interaction.
enum LimitReachedAction { upgrade, swap, createPaused, cancel }

/// Dialog shown when user tries to activate/create an item beyond the free-tier limit.
class LimitReachedDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? swapLabel;
  final bool showCreatePaused;

  const LimitReachedDialog({
    super.key,
    required this.title,
    required this.message,
    this.swapLabel,
    this.showCreatePaused = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary(context),
        ),
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary(context),
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pop(LimitReachedAction.upgrade),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary(context),
              foregroundColor: AppColors.onPrimary(context),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(S.of(context).upgradeToPro),
          ),
        ),
        if (swapLabel != null && !showCreatePaused)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pop(LimitReachedAction.swap),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary(context),
                side: BorderSide(color: AppColors.border(context)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(swapLabel!),
            ),
          ),
        if (showCreatePaused)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () =>
                  Navigator.of(context).pop(LimitReachedAction.createPaused),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary(context),
                side: BorderSide(color: AppColors.border(context)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(S.of(context).createAsPaused),
            ),
          ),
        Center(
          child: TextButton(
            onPressed: () =>
                Navigator.of(context).pop(LimitReachedAction.cancel),
            child: Text(
              showCreatePaused ? S.of(context).cancel : S.of(context).close,
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ),
        ),
      ],
    );
  }
}

/// Show a dialog when the category limit is reached (trying to activate).
Future<LimitReachedAction?> showCategoryLimitDialog(
    BuildContext context, String categoryName) {
  return showDialog<LimitReachedAction>(
    context: context,
    builder: (ctx) => LimitReachedDialog(
      title: S.of(ctx).categoryLimitTitle,
      message: S.of(ctx).categoryLimitActivateMsg(categoryName),
      swapLabel: S.of(ctx).swapActive,
    ),
  );
}

/// Show a dialog when the category limit is reached (trying to create new).
Future<LimitReachedAction?> showCategoryCreateLimitDialog(
    BuildContext context) {
  return showDialog<LimitReachedAction>(
    context: context,
    builder: (ctx) => LimitReachedDialog(
      title: S.of(ctx).categoryLimitTitle,
      message: S.of(ctx).categoryLimitCreateMsg,
      showCreatePaused: true,
    ),
  );
}

/// Show a dialog when the savings goal limit is reached (trying to activate).
Future<LimitReachedAction?> showGoalLimitDialog(
    BuildContext context, String goalName) {
  return showDialog<LimitReachedAction>(
    context: context,
    builder: (ctx) => LimitReachedDialog(
      title: S.of(ctx).savingsGoalLimitTitle,
      message: S.of(ctx).savingsGoalLimitActivateMsg(goalName),
      swapLabel: S.of(ctx).chooseActiveGoal,
    ),
  );
}

/// Show a dialog when the savings goal limit is reached (trying to create new).
Future<LimitReachedAction?> showGoalCreateLimitDialog(BuildContext context) {
  return showDialog<LimitReachedAction>(
    context: context,
    builder: (ctx) => LimitReachedDialog(
      title: S.of(ctx).savingsGoalLimitTitle,
      message: S.of(ctx).savingsGoalLimitCreateMsg,
      showCreatePaused: true,
    ),
  );
}
