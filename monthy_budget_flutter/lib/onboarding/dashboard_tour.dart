import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../l10n/generated/app_localizations.dart';
import 'tour_helpers.dart';
import 'tour_step_content.dart';

class DashboardTourKeys {
  static final heroCard = GlobalKey(debugLabel: 'tour_hero');
  static final stressIndex = GlobalKey(debugLabel: 'tour_stress');
  static final budgetVsActual = GlobalKey(debugLabel: 'tour_bva');
}

TutorialCoachMark buildDashboardTour({
  required BuildContext context,
  required GlobalKey fabKey,
  required GlobalKey navBarKey,
  required VoidCallback onFinish,
  required VoidCallback onSkip,
}) {
  final l10n = S.of(context);
  final targets = <TargetFocus>[
    if (DashboardTourKeys.heroCard.currentContext != null)
      TargetFocus(
        identify: 'hero',
        keyTarget: DashboardTourKeys.heroCard,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: pickAlign(DashboardTourKeys.heroCard),
            child: TourStepContent(
              title: l10n.onbTourDash1Title,
              body: l10n.onbTourDash1Body,
            ),
          ),
        ],
      ),
    if (DashboardTourKeys.stressIndex.currentContext != null)
      TargetFocus(
        identify: 'stress',
        keyTarget: DashboardTourKeys.stressIndex,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: pickAlign(DashboardTourKeys.stressIndex),
            child: TourStepContent(
              title: l10n.onbTourDash2Title,
              body: l10n.onbTourDash2Body,
            ),
          ),
        ],
      ),
    if (DashboardTourKeys.budgetVsActual.currentContext != null)
      TargetFocus(
        identify: 'bva',
        keyTarget: DashboardTourKeys.budgetVsActual,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: 14,
        contents: [
          TargetContent(
            align: pickAlign(DashboardTourKeys.budgetVsActual),
            child: TourStepContent(
              title: l10n.onbTourDash3Title,
              body: l10n.onbTourDash3Body,
            ),
          ),
        ],
      ),
    if (fabKey.currentContext != null)
      TargetFocus(
        identify: 'fab',
        keyTarget: fabKey,
        enableOverlayTab: true,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: pickAlign(fabKey),
            child: TourStepContent(
              title: l10n.onbTourDash4Title,
              body: l10n.onbTourDash4Body,
            ),
          ),
        ],
      ),
    if (navBarKey.currentContext != null)
      TargetFocus(
        identify: 'nav',
        keyTarget: navBarKey,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: 0,
        contents: [
          TargetContent(
            align: pickAlign(navBarKey),
            child: TourStepContent(
              title: l10n.onbTourDash5Title,
              body: l10n.onbTourDash5Body,
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
    onClickTarget: (target) {},
    beforeFocus: (target) async {
      final ctx = target.keyTarget?.currentContext;
      if (ctx != null) await safeEnsureVisible(ctx);
    },
  );
}
