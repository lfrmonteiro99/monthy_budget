import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/screens/expense_tracker_screen.dart';
import 'package:monthly_management/models/actual_expense.dart';

import '../helpers/test_app.dart';
import '../helpers/test_helpers.dart';

void main() {
  // Build a minimal set of expenses spanning two months.
  List<ActualExpense> janExpenses() => [
        makeActualExpense(
          id: 'j1',
          category: 'habitacao',
          amount: 500,
          description: 'January rent',
          date: DateTime(2026, 1, 5),
        ),
        makeActualExpense(
          id: 'j2',
          category: 'alimentacao',
          amount: 42.50,
          description: 'Supermarket groceries',
          date: DateTime(2026, 1, 10),
        ),
      ];

  List<ActualExpense> febExpenses() => [
        makeActualExpense(
          id: 'f1',
          category: 'alimentacao',
          amount: 18.75,
          description: 'Lunch restaurant',
          date: DateTime(2026, 2, 3),
        ),
      ];

  Map<String, List<ActualExpense>> fullHistory() => {
        '2026-01': janExpenses(),
        '2026-02': febExpenses(),
      };

  Widget buildScreen({
    List<ActualExpense>? expenses,
    Future<Map<String, List<ActualExpense>>> Function()? onLoadHistory,
    bool disableHistory = false,
  }) {
    return wrapWithTestApp(
      ExpenseTrackerScreen(
        settings: makeSettings(
          expenses: [
            makeExpense(category: 'habitacao', label: 'Housing'),
            makeExpense(
              id: 'exp_2',
              category: 'alimentacao',
              label: 'Food',
              amount: 300,
            ),
          ],
        ),
        expenses: expenses ?? janExpenses(),
        householdId: 'house-1',
        onAdd: (_) async {},
        onUpdate: (_) async {},
        onDelete: (_) async {},
        onLoadMonth: (_) async => janExpenses(),
        onLoadHistory:
            disableHistory ? null : (onLoadHistory ?? () async => fullHistory()),
      ),
    );
  }

  group('search activation', () {
    testWidgets('search icon is visible and opens search view', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      // Search icon should exist
      expect(find.byIcon(Icons.search), findsOneWidget);

      // Tap search icon
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Search view should show a text field and back arrow
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      // All 3 expenses from history should be listed (no filter)
      expect(find.text('3 results'), findsOneWidget);
    });

    testWidgets('back arrow deactivates search and returns to normal view', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Tap back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Should be back to normal view with month label visible
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });

  group('text search filtering', () {
    testWidgets('typing query filters results by description', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Type in search field
      await tester.enterText(find.byType(TextField), 'rent');
      await tester.pumpAndSettle();

      // Should show only 'January rent'
      expect(find.text('1 results'), findsOneWidget);
      expect(find.text('January rent'), findsOneWidget);
    });

    testWidgets('clear button resets search query', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'rent');
      await tester.pumpAndSettle();

      expect(find.text('1 results'), findsOneWidget);

      // Tap clear
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Back to all results
      expect(find.text('3 results'), findsOneWidget);
    });
  });

  group('category chip filtering', () {
    testWidgets('tapping a category chip filters to that category', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Find and tap the 'alimentacao' chip (displayed as localized label)
      // The chip uses FilterChip with text from _localizedCategory
      // In English locale, the ExpenseCategory enum localizedLabel is used
      // Let's find the chip by looking for FilterChip widgets
      final chips = find.byType(FilterChip);
      expect(chips, findsWidgets);

      // Tap the first alimentacao chip - let's look for it in the rendered text
      // Categories from history: habitacao, alimentacao, transporte
      // But we need to find them by their localized names
      // In test locale (en), habitacao -> Housing, alimentacao -> Food
      // Actually let's check how the enum labels work
      // For now, just tap the second chip (alimentacao comes after habitacao alphabetically)
      // Actually in sorted order: alimentacao, habitacao, transporte
      // So first chip should be alimentacao / "Food"
      await tester.tap(chips.first);
      await tester.pumpAndSettle();

      // Should filter to only alimentacao expenses (j2, f1)
      expect(find.text('2 results'), findsOneWidget);
    });
  });

  group('search not available without onLoadHistory', () {
    testWidgets('search icon hidden when onLoadHistory is null', (
      tester,
    ) async {
      await tester.pumpWidget(buildScreen(disableHistory: true));
      await tester.pumpAndSettle();

      // The conditional `if (widget.onLoadHistory != null)` should hide it
      final searchButtons = find.byIcon(Icons.search);
      expect(searchButtons, findsNothing);
    });
  });
}
