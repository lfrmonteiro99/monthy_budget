import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../l10n/generated/app_localizations.dart';
import 'tour_step_content.dart';

class RecurringExpensesTourKeys {
  static final expenseItem = GlobalKey(debugLabel: 'tour_re_item');
  static final addFab = GlobalKey(debugLabel: 'tour_re_add');
}

TutorialCoachMark buildRecurringExpensesTour({
  required BuildContext context,
  required VoidCallback onFinish,
  required VoidCallback onSkip,
}) {
  final l10n = S.of(context);
  final targets = <TargetFocus>[
    if (RecurringExpensesTourKeys.expenseItem.currentContext != null)
      TargetFocus(
        identify: 'expense_item',
        keyTarget: RecurringExpensesTourKeys.expenseItem,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: TourStepContent(
              title: l10n.onbTourRecurring1Title,
              body: l10n.onbTourRecurring1Body,
            ),
          ),
        ],
      ),
    if (RecurringExpensesTourKeys.addFab.currentContext != null)
      TargetFocus(
        identify: 'add_fab',
        keyTarget: RecurringExpensesTourKeys.addFab,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: TourStepContent(
              title: l10n.onbTourRecurring2Title,
              body: l10n.onbTourRecurring2Body,
            ),
          ),
        ],
      ),
  ];

  return TutorialCoachMark(
    targets: targets,
    colorShadow: Colors.black,
    opacityShadow: 0.7,
    hideSkip: true,
    onFinish: onFinish,
    onSkip: () {
      onSkip();
      return true;
    },
    beforeFocus: (target) async {
      final ctx = target.keyTarget?.currentContext;
      if (ctx != null) {
        await Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          alignment: 0.5,
        );
      }
    },
  );
}
