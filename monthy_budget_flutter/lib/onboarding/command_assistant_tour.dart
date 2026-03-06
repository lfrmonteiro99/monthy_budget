import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../l10n/generated/app_localizations.dart';
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
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
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
    hideSkip: true,
    onFinish: onFinish,
    onSkip: () {
      onSkip();
      return true;
    },
  );
}
