import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../l10n/generated/app_localizations.dart';
import 'tour_helpers.dart';
import 'tour_step_content.dart';

class CommandAssistantTourKeys {
  static final fab = GlobalKey(debugLabel: 'tour_cmd_fab');
}

TutorialCoachMark buildCommandAssistantTour({
  required BuildContext context,
  required VoidCallback onFinish,
  required VoidCallback onSkip,
}) {
  final l10n = S.of(context);
  final targets = <TargetFocus>[
    if (CommandAssistantTourKeys.fab.currentContext != null)
      TargetFocus(
        identify: 'cmd_fab',
        keyTarget: CommandAssistantTourKeys.fab,
        enableOverlayTab: true,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: pickAlign(CommandAssistantTourKeys.fab),
            child: TourStepContent(
              title: l10n.onbTourAssistant1Title,
              body: l10n.onbTourAssistant1Body,
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
