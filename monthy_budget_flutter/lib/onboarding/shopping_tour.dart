import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../l10n/generated/app_localizations.dart';
import 'tour_step_content.dart';

class ShoppingTourKeys {
  static final shoppingItem = GlobalKey(debugLabel: 'tour_shopping_item');
  static final finalizeButton = GlobalKey(debugLabel: 'tour_shopping_finalize');
  static final historyButton = GlobalKey(debugLabel: 'tour_shopping_history');
}

TutorialCoachMark buildShoppingTour({
  required BuildContext context,
  required VoidCallback onFinish,
  required VoidCallback onSkip,
}) {
  final l10n = S.of(context);
  final targets = <TargetFocus>[
    if (ShoppingTourKeys.shoppingItem.currentContext != null)
      TargetFocus(
        identify: 'item',
        keyTarget: ShoppingTourKeys.shoppingItem,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: TourStepContent(
              title: l10n.onbTourShopping1Title,
              body: l10n.onbTourShopping1Body,
            ),
          ),
        ],
      ),
    if (ShoppingTourKeys.finalizeButton.currentContext != null)
      TargetFocus(
        identify: 'finalize',
        keyTarget: ShoppingTourKeys.finalizeButton,
        shape: ShapeLightFocus.RRect,
        radius: 28,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            child: TourStepContent(
              title: l10n.onbTourShopping2Title,
              body: l10n.onbTourShopping2Body,
            ),
          ),
        ],
      ),
    if (ShoppingTourKeys.historyButton.currentContext != null)
      TargetFocus(
        identify: 'history',
        keyTarget: ShoppingTourKeys.historyButton,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: TourStepContent(
              title: l10n.onbTourShopping3Title,
              body: l10n.onbTourShopping3Body,
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
