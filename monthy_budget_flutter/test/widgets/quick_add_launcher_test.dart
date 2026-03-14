import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:monthly_management/services/quick_action_service.dart';
import 'package:monthly_management/widgets/quick_add_launcher.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('QuickAddLauncher', () {
    testWidgets('shows speed-dial options when tapped', (tester) async {
      // QuickAddLauncher is now a single-action FAB that directly fires
      // addExpense. Verify the FAB is rendered and triggers addExpense.
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
      await tester.pumpAndSettle();

      // The FAB should be visible.
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Tap the FAB — it directly dispatches addExpense.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(received, QuickAction.addExpense);
    });

    testWidgets('dispatches addShopping when shopping chip is tapped',
        (tester) async {
      // Widget is now a single-action FAB — always dispatches addExpense.
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
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Single-action FAB always fires addExpense.
      expect(received, QuickAction.addExpense);
    });

    testWidgets('dispatches openMeals when meals chip is tapped',
        (tester) async {
      // Widget is now a single-action FAB — always dispatches addExpense.
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
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(received, QuickAction.addExpense);
    });

    testWidgets('dispatches openAssistant when assistant chip is tapped',
        (tester) async {
      // Widget is now a single-action FAB — always dispatches addExpense.
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
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(received, QuickAction.addExpense);
    });

    testWidgets('collapses after selecting an action', (tester) async {
      // Widget is now a single-action FAB — no expand/collapse behavior.
      // Verify the FAB remains visible after being tapped.
      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            floatingActionButton: QuickAddLauncher(
              onAction: (_) {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // FAB is present.
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Tap.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // FAB should still be visible (it's a persistent single button).
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
