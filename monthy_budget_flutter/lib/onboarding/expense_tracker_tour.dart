import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../l10n/generated/app_localizations.dart';
import 'tour_step_content.dart';

class ExpenseTrackerTourKeys {
  static final monthNav = GlobalKey(debugLabel: 'tour_et_month');
  static final summary = GlobalKey(debugLabel: 'tour_et_summary');
  static final categoryList = GlobalKey(debugLabel: 'tour_et_categories');
  static final addFab = GlobalKey(debugLabel: 'tour_et_add');
}

TutorialCoachMark buildExpenseTrackerTour({
  required BuildContext context,
  required VoidCallback onFinish,
  required VoidCallback onSkip,
}) {
  final l10n = S.of(context);
  final targets = <TargetFocus>[
    if (ExpenseTrackerTourKeys.monthNav.currentContext != null)
      TargetFocus(
        identify: 'month_nav',
        keyTarget: ExpenseTrackerTourKeys.monthNav,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: TourStepContent(
              title: l10n.onbTourExpenseTracker1Title,
              body: l10n.onbTourExpenseTracker1Body,
            ),
          ),
        ],
      ),
    if (ExpenseTrackerTourKeys.summary.currentContext != null)
      TargetFocus(
        identify: 'summary',
        keyTarget: ExpenseTrackerTourKeys.summary,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: TourStepContent(
              title: l10n.onbTourExpenseTracker2Title,
              body: l10n.onbTourExpenseTracker2Body,
            ),
          ),
        ],
      ),
    if (ExpenseTrackerTourKeys.categoryList.currentContext != null)
      TargetFocus(
        identify: 'categories',
        keyTarget: ExpenseTrackerTourKeys.categoryList,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: TourStepContent(
              title: l10n.onbTourExpenseTracker3Title,
              body: l10n.onbTourExpenseTracker3Body,
            ),
          ),
        ],
      ),
    if (ExpenseTrackerTourKeys.addFab.currentContext != null)
      TargetFocus(
        identify: 'add_fab',
        keyTarget: ExpenseTrackerTourKeys.addFab,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: TourStepContent(
              title: l10n.onbTourExpenseTracker4Title,
              body: l10n.onbTourExpenseTracker4Body,
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
