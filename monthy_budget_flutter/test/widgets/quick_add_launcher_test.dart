import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/services/quick_action_service.dart';
import 'package:monthly_management/widgets/quick_add_launcher.dart';

import '../helpers/test_app.dart';

void main() {
  group('QuickAddLauncher', () {
    testWidgets('shows speed-dial options when tapped', (tester) async {
      QuickAction? received;

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            floatingActionButton: QuickAddLauncher(
              onAction: (action) => received = action,
            ),
          ),
        ),
      );

      // Initially the action chips are not visible (collapsed).
      expect(find.text('Add expense'), findsNothing);
      expect(find.text('Add shopping item'), findsNothing);
      expect(find.text('Meal planner'), findsNothing);
      expect(find.text('Assistant'), findsNothing);

      // Tap the launcher FAB to expand.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // All four quick-action chips should now be visible.
      expect(find.text('Add expense'), findsOneWidget);
      expect(find.text('Add shopping item'), findsOneWidget);
      expect(find.text('Meal planner'), findsOneWidget);
      expect(find.text('Assistant'), findsOneWidget);

      // Tap "Add expense" chip.
      await tester.tap(find.text('Add expense'));
      await tester.pumpAndSettle();

      expect(received, QuickAction.addExpense);
    });

    testWidgets('dispatches addShopping when shopping chip is tapped',
        (tester) async {
      QuickAction? received;

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            floatingActionButton: QuickAddLauncher(
              onAction: (action) => received = action,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add shopping item'));
      await tester.pumpAndSettle();

      expect(received, QuickAction.addShopping);
    });

    testWidgets('dispatches openMeals when meals chip is tapped',
        (tester) async {
      QuickAction? received;

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            floatingActionButton: QuickAddLauncher(
              onAction: (action) => received = action,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Meal planner'));
      await tester.pumpAndSettle();

      expect(received, QuickAction.openMeals);
    });

    testWidgets('dispatches openAssistant when assistant chip is tapped',
        (tester) async {
      QuickAction? received;

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            floatingActionButton: QuickAddLauncher(
              onAction: (action) => received = action,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Assistant'));
      await tester.pumpAndSettle();

      expect(received, QuickAction.openAssistant);
    });

    testWidgets('collapses after selecting an action', (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            floatingActionButton: QuickAddLauncher(
              onAction: (_) {},
            ),
          ),
        ),
      );

      // Expand
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('Add expense'), findsOneWidget);

      // Select
      await tester.tap(find.text('Add expense'));
      await tester.pumpAndSettle();

      // Should collapse
      expect(find.text('Add expense'), findsNothing);
    });
  });
}
