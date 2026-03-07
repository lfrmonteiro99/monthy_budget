import 'package:flutter/material.dart';
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
            child: const Text('Upgrade to Pro'),
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
              child: const Text('Create as Paused'),
            ),
          ),
        Center(
          child: TextButton(
            onPressed: () =>
                Navigator.of(context).pop(LimitReachedAction.cancel),
            child: Text(
              showCreatePaused ? 'Cancel' : 'Close',
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
    builder: (_) => LimitReachedDialog(
      title: 'Category limit reached',
      message:
          'The free plan allows 8 active categories. To activate "$categoryName", '
          'deactivate another category first, or upgrade to Pro for unlimited categories.',
      swapLabel: 'Swap Active',
    ),
  );
}

/// Show a dialog when the category limit is reached (trying to create new).
Future<LimitReachedAction?> showCategoryCreateLimitDialog(
    BuildContext context) {
  return showDialog<LimitReachedAction>(
    context: context,
    builder: (_) => LimitReachedDialog(
      title: 'Category limit reached',
      message:
          'You have 8 active categories, the maximum for the free plan. '
          'To add a new category, deactivate an existing one first, or upgrade to Pro.',
      showCreatePaused: true,
    ),
  );
}

/// Show a dialog when the savings goal limit is reached (trying to activate).
Future<LimitReachedAction?> showGoalLimitDialog(
    BuildContext context, String goalName) {
  return showDialog<LimitReachedAction>(
    context: context,
    builder: (_) => LimitReachedDialog(
      title: 'Savings goal limit reached',
      message:
          'The free plan allows 1 active savings goal. To activate "$goalName", '
          'deactivate your current active goal first, or upgrade to Pro for unlimited goals.',
      swapLabel: 'Choose Active Goal',
    ),
  );
}

/// Show a dialog when the savings goal limit is reached (trying to create new).
Future<LimitReachedAction?> showGoalCreateLimitDialog(BuildContext context) {
  return showDialog<LimitReachedAction>(
    context: context,
    builder: (_) => LimitReachedDialog(
      title: 'Savings goal limit reached',
      message:
          'The free plan allows 1 active savings goal. You can still create this '
          'goal — it will be saved as paused until you upgrade or deactivate your current active goal.',
      showCreatePaused: true,
    ),
  );
}
