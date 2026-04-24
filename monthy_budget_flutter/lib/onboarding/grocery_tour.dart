import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../constants/app_constants.dart';
import '../l10n/generated/app_localizations.dart';
import 'tour_step_content.dart';

class GroceryTourKeys {
  static final searchBar = GlobalKey(debugLabel: 'tour_grocery_search');
  static final productCard = GlobalKey(debugLabel: 'tour_grocery_product');
  static final categoryFilter = GlobalKey(debugLabel: 'tour_grocery_category');
}

TutorialCoachMark buildGroceryTour({
  required BuildContext context,
  required VoidCallback onFinish,
  required VoidCallback onSkip,
}) {
  final l10n = S.of(context);
  final targets = <TargetFocus>[
    if (GroceryTourKeys.searchBar.currentContext != null)
      TargetFocus(
        identify: 'search',
        keyTarget: GroceryTourKeys.searchBar,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: TourStepContent(
              title: l10n.onbTourGrocery1Title,
              body: l10n.onbTourGrocery1Body,
            ),
          ),
        ],
      ),
    if (GroceryTourKeys.productCard.currentContext != null)
      TargetFocus(
        identify: 'product',
        keyTarget: GroceryTourKeys.productCard,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: 12,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: TourStepContent(
              title: l10n.onbTourGrocery2Title,
              body: l10n.onbTourGrocery2Body,
            ),
          ),
        ],
      ),
    if (GroceryTourKeys.categoryFilter.currentContext != null)
      TargetFocus(
        identify: 'category',
        keyTarget: GroceryTourKeys.categoryFilter,
        enableOverlayTab: true,
        shape: ShapeLightFocus.RRect,
        radius: 20,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            child: TourStepContent(
              title: l10n.onbTourGrocery3Title,
              body: l10n.onbTourGrocery3Body,
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
