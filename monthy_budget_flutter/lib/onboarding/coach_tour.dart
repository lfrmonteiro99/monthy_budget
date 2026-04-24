import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../constants/app_constants.dart';
import '../l10n/generated/app_localizations.dart';
import 'tour_step_content.dart';

class CoachTourKeys {
  static final analyzeButton = GlobalKey(debugLabel: 'tour_coach_analyze');
  static final historyList = GlobalKey(debugLabel: 'tour_coach_history');
}

TutorialCoachMark buildCoachTour({
  required BuildContext context,
  required VoidCallback onFinish,
  required VoidCallback onSkip,
}) {
  final l10n = S.of(context);
  final targets = <TargetFocus>[
    if (CoachTourKeys.analyzeButton.currentContext != null)
      TargetFocus(
        identify: 'analyze',
        keyTarget: CoachTourKeys.analyzeButton,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: TourStepContent(
              title: l10n.onbTourCoach1Title,
              body: l10n.onbTourCoach1Body,
            ),
          ),
        ],
      ),
    if (CoachTourKeys.historyList.currentContext != null)
      TargetFocus(
        identify: 'history',
        keyTarget: CoachTourKeys.historyList,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: TourStepContent(
              title: l10n.onbTourCoach2Title,
              body: l10n.onbTourCoach2Body,
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
      if (ctx != null) {
        await Scrollable.ensureVisible(
          ctx,
          duration: AppConstants.animPageTransition,
          alignment: 0.5,
        );
      }
    },
  );
}
