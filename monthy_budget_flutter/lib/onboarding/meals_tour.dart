import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../constants/app_constants.dart';
import '../l10n/generated/app_localizations.dart';
import 'tour_step_content.dart';

class MealsTourKeys {
  static final generateButton = GlobalKey(debugLabel: 'tour_meals_generate');
  static final weekTabs = GlobalKey(debugLabel: 'tour_meals_weeks');
  static final addToListButton = GlobalKey(debugLabel: 'tour_meals_add_list');
}

TutorialCoachMark buildMealsTour({
  required BuildContext context,
  required VoidCallback onFinish,
  required VoidCallback onSkip,
}) {
  final l10n = S.of(context);
  final targets = <TargetFocus>[
    if (MealsTourKeys.generateButton.currentContext != null)
      TargetFocus(
        identify: 'generate',
        keyTarget: MealsTourKeys.generateButton,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: TourStepContent(
              title: l10n.onbTourMeals1Title,
              body: l10n.onbTourMeals1Body,
            ),
          ),
        ],
      ),
    if (MealsTourKeys.weekTabs.currentContext != null)
      TargetFocus(
        identify: 'weeks',
        keyTarget: MealsTourKeys.weekTabs,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: TourStepContent(
              title: l10n.onbTourMeals2Title,
              body: l10n.onbTourMeals2Body,
            ),
          ),
        ],
      ),
    if (MealsTourKeys.addToListButton.currentContext != null)
      TargetFocus(
        identify: 'addToList',
        keyTarget: MealsTourKeys.addToListButton,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: TourStepContent(
              title: l10n.onbTourMeals3Title,
              body: l10n.onbTourMeals3Body,
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
          duration: AppConstants.animPageTransition,
          alignment: 0.5,
        );
      }
    },
  );
}
