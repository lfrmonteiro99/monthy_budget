import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/meal_planner.dart';
import 'package:monthly_management/widgets/meal_feedback_button.dart';

import '../helpers/test_app.dart';

void main() {
  group('MealFeedbackButton labels and accessibility', () {
    testWidgets('shows visible text label for liked feedback', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: MealFeedbackButton(
              icon: Icons.thumb_up_outlined,
              activeIcon: Icons.thumb_up,
              isActive: false,
              color: Colors.green,
              label: 'Liked',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Liked'), findsOneWidget);
      expect(find.byTooltip('Liked'), findsOneWidget);
    });

    testWidgets('shows visible text label for dislike feedback', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: MealFeedbackButton(
              icon: Icons.thumb_down_outlined,
              activeIcon: Icons.thumb_down,
              isActive: false,
              color: Colors.red,
              label: 'Dislike',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Dislike'), findsOneWidget);
      expect(find.byTooltip('Dislike'), findsOneWidget);
    });

    testWidgets('shows visible text label for skip feedback', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: MealFeedbackButton(
              icon: Icons.skip_next_outlined,
              activeIcon: Icons.skip_next,
              isActive: false,
              color: Colors.grey,
              label: 'Skip',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Skip'), findsOneWidget);
      expect(find.byTooltip('Skip'), findsOneWidget);
    });

    testWidgets('active state changes icon and background', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: MealFeedbackButton(
              icon: Icons.thumb_up_outlined,
              activeIcon: Icons.thumb_up,
              isActive: true,
              color: Colors.green,
              label: 'Liked',
              onTap: () {},
            ),
          ),
        ),
      );

      // Active icon should be filled
      expect(find.byIcon(Icons.thumb_up), findsOneWidget);
      expect(find.byIcon(Icons.thumb_up_outlined), findsNothing);
    });

    testWidgets('all three feedback buttons trigger correct callbacks', (tester) async {
      MealFeedback? lastFeedback;

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: Row(
              children: [
                MealFeedbackButton(
                  icon: Icons.thumb_up_outlined,
                  activeIcon: Icons.thumb_up,
                  isActive: false,
                  color: Colors.green,
                  label: 'Liked',
                  onTap: () => lastFeedback = MealFeedback.liked,
                ),
                MealFeedbackButton(
                  icon: Icons.thumb_down_outlined,
                  activeIcon: Icons.thumb_down,
                  isActive: false,
                  color: Colors.red,
                  label: 'Dislike',
                  onTap: () => lastFeedback = MealFeedback.disliked,
                ),
                MealFeedbackButton(
                  icon: Icons.skip_next_outlined,
                  activeIcon: Icons.skip_next,
                  isActive: false,
                  color: Colors.grey,
                  label: 'Skip',
                  onTap: () => lastFeedback = MealFeedback.skipped,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Liked'));
      expect(lastFeedback, MealFeedback.liked);

      await tester.tap(find.text('Dislike'));
      expect(lastFeedback, MealFeedback.disliked);

      await tester.tap(find.text('Skip'));
      expect(lastFeedback, MealFeedback.skipped);
    });
  });
}
