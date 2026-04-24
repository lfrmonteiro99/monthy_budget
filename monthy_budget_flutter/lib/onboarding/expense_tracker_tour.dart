import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../l10n/generated/app_localizations.dart';
import 'tour_helpers.dart';
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
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: pickAlign(ExpenseTrackerTourKeys.monthNav),
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
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: pickAlign(ExpenseTrackerTourKeys.summary),
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
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: pickAlign(ExpenseTrackerTourKeys.categoryList),
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
        enableOverlayTab: true,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: pickAlign(ExpenseTrackerTourKeys.addFab),
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
    hideSkip: false,
    alignSkip: Alignment.topRight,
    useSafeArea: true,
    showSkipInLastTarget: true,
    onFinish: onFinish,
    onSkip: () {
      onSkip();
      return true;
    },
    beforeFocus: (target) async {
      final ctx = target.keyTarget?.currentContext;
      if (ctx != null) await safeEnsureVisible(ctx);
    },
  );
}
