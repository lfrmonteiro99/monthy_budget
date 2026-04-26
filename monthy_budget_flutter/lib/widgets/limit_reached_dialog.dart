import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/generated/app_localizations.dart';
import '../theme/app_colors.dart';
import 'calm/calm.dart';

/// Result of the limit-reached dialog interaction.
enum LimitReachedAction { upgrade, swap, createPaused, cancel }

/// Body widget for the limit-reached dialog. Used as `child` of
/// [CalmDialog.show] so the dialog itself follows the Calm chrome
/// (20px radius, card surface, no elevation).
class _LimitReachedBody extends StatelessWidget {
  const _LimitReachedBody({
    required this.title,
    required this.message,
    this.swapLabel,
    this.showCreatePaused = false,
  });

  final String title;
  final String message;
  final String? swapLabel;
  final bool showCreatePaused;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: AppColors.ink(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.ink70(context),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(LimitReachedAction.upgrade),
          child: Text(l10n.upgradeToPro),
        ),
        if (swapLabel != null && !showCreatePaused) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () =>
                Navigator.of(context).pop(LimitReachedAction.swap),
            child: Text(swapLabel!),
          ),
        ],
        if (showCreatePaused) ...[
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () =>
                Navigator.of(context).pop(LimitReachedAction.createPaused),
            child: Text(l10n.createAsPaused),
          ),
        ],
        const SizedBox(height: 4),
        Center(
          child: TextButton(
            onPressed: () =>
                Navigator.of(context).pop(LimitReachedAction.cancel),
            child: Text(showCreatePaused ? l10n.cancel : l10n.close),
          ),
        ),
      ],
    );
  }
}

Future<LimitReachedAction?> _show(
  BuildContext context, {
  required String title,
  required String message,
  String? swapLabel,
  bool showCreatePaused = false,
}) {
  return CalmDialog.show<LimitReachedAction>(
    context,
    child: _LimitReachedBody(
      title: title,
      message: message,
      swapLabel: swapLabel,
      showCreatePaused: showCreatePaused,
    ),
  );
}

/// Show a dialog when the category limit is reached (trying to activate).
Future<LimitReachedAction?> showCategoryLimitDialog(
    BuildContext context, String categoryName) {
  final l10n = S.of(context);
  return _show(
    context,
    title: l10n.categoryLimitReached,
    message:
        'The free plan allows 8 active categories. To activate "$categoryName", '
        'deactivate another category first, or upgrade to Pro for unlimited categories.',
    swapLabel: l10n.limitSwapActive,
  );
}

/// Show a dialog when the category limit is reached (trying to create new).
Future<LimitReachedAction?> showCategoryCreateLimitDialog(
    BuildContext context) {
  final l10n = S.of(context);
  return _show(
    context,
    title: l10n.categoryLimitReached,
    message:
        'You have 8 active categories, the maximum for the free plan. '
        'To add a new category, deactivate an existing one first, or upgrade to Pro.',
    showCreatePaused: true,
  );
}

/// Show a dialog when the savings goal limit is reached (trying to activate).
Future<LimitReachedAction?> showGoalLimitDialog(
    BuildContext context, String goalName) {
  final l10n = S.of(context);
  return _show(
    context,
    title: l10n.savingsGoalLimitReached,
    message:
        'The free plan allows 1 active savings goal. To activate "$goalName", '
        'deactivate your current active goal first, or upgrade to Pro for unlimited goals.',
    swapLabel: l10n.limitChooseActiveGoal,
  );
}

/// Show a dialog when the savings goal limit is reached (trying to create new).
Future<LimitReachedAction?> showGoalCreateLimitDialog(BuildContext context) {
  final l10n = S.of(context);
  return _show(
    context,
    title: l10n.savingsGoalLimitReached,
    message:
        'The free plan allows 1 active savings goal. You can still create this '
        'goal — it will be saved as paused until you upgrade or deactivate your current active goal.',
    showCreatePaused: true,
  );
}
