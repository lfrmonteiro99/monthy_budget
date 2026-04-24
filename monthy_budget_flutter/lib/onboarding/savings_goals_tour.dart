import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../l10n/generated/app_localizations.dart';
import 'tour_helpers.dart';
import 'tour_step_content.dart';

class SavingsGoalsTourKeys {
  static final goalCard = GlobalKey(debugLabel: 'tour_sg_card');
  static final addFab = GlobalKey(debugLabel: 'tour_sg_add');
}

TutorialCoachMark buildSavingsGoalsTour({
  required BuildContext context,
  required VoidCallback onFinish,
  required VoidCallback onSkip,
}) {
  final l10n = S.of(context);
  final targets = <TargetFocus>[
    if (SavingsGoalsTourKeys.goalCard.currentContext != null)
      TargetFocus(
        identify: 'goal_card',
        keyTarget: SavingsGoalsTourKeys.goalCard,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: pickAlign(SavingsGoalsTourKeys.goalCard),
            child: TourStepContent(
              title: l10n.onbTourSavings1Title,
              body: l10n.onbTourSavings1Body,
            ),
          ),
        ],
      ),
    if (SavingsGoalsTourKeys.addFab.currentContext != null)
      TargetFocus(
        identify: 'add_fab',
        keyTarget: SavingsGoalsTourKeys.addFab,
        enableOverlayTab: true,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: pickAlign(SavingsGoalsTourKeys.addFab),
            child: TourStepContent(
              title: l10n.onbTourSavings2Title,
              body: l10n.onbTourSavings2Body,
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
