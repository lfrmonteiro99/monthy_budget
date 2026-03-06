import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/widgets/meal_feedback_button.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('shows visible label and tooltip for feedback action', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapWithTestApp(
        Scaffold(
          body: MealFeedbackButton(
            icon: Icons.thumb_up_outlined,
            activeIcon: Icons.thumb_up,
            isActive: false,
            color: const Color(0xFF16A34A),
            label: 'Liked',
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('Liked'), findsOneWidget);
    expect(find.byTooltip('Liked'), findsOneWidget);
  });
}
