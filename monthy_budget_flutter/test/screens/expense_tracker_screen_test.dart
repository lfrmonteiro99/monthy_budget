import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/onboarding/expense_tracker_tour.dart';
import 'package:monthly_management/screens/expense_tracker_screen.dart';
import 'package:monthly_management/widgets/expense_detail_sheet.dart';

import '../helpers/test_app.dart';
import '../helpers/test_helpers.dart';

/// Reproduces the AppHome wiring for `onAdd` (#1233): the parent updates its
/// own state list *before* the persistence await resolves — mirroring
/// `_addActualExpense`'s `actualExpensesProvider.set([...])` followed by
/// `await _actualExpenseService.add(...)`. That optimistic-then-await shape
/// is what lets the tracker's `didUpdateWidget` sync race with its own local
/// append in `_addExpense`.
class _OptimisticParent extends StatefulWidget {
  final List<ActualExpense> initialExpenses;
  const _OptimisticParent({required this.initialExpenses});

  @override
  State<_OptimisticParent> createState() => _OptimisticParentState();
}

class _OptimisticParentState extends State<_OptimisticParent> {
  late List<ActualExpense> _expenses;

  @override
  void initState() {
    super.initState();
    _expenses = List.of(widget.initialExpenses);
  }

  @override
  Widget build(BuildContext context) {
    return ExpenseTrackerScreen(
      settings: makeSettings(
        expenses: [makeExpense(category: 'habitacao', label: 'Rent')],
      ),
      expenses: _expenses,
      householdId: 'house-1',
      onAdd: (expense) async {
        setState(() => _expenses = [expense, ..._expenses]);
        await Future<void>.delayed(const Duration(milliseconds: 5));
      },
      onUpdate: (_) async {},
      onDelete: (_) async {},
      onLoadMonth: (_) async => _expenses,
    );
  }
}

Future<void> _openSheetAndFillAmount(WidgetTester tester, String amount) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextFormField).first, amount);
  // 'habitacao' is the 6th ExpenseCategory value, matching the single
  // budgeted expense in makeSettings above.
  await tester.tap(find.byType(ChoiceChip).at(5));
  await tester.pump();
}

Future<void> _tapSave(WidgetTester tester) async {
  await tester.dragUntilVisible(
    find.text('Save'),
    find.byType(ListView),
    const Offset(0, -200),
  );
  await tester.tap(find.text('Save'));
  // First pump: flushes the microtask that resumes `_addExpense` after the
  // sheet pops, which runs `onAdd`'s synchronous optimistic `setState` — the
  // parent rebuild reaches the tracker's `didUpdateWidget` sync in this same
  // pump, before `onAdd`'s persistence await resolves.
  await tester.pump();
  // Second pump: advances the fake clock past onAdd's simulated I/O delay,
  // letting `_addExpense`'s post-await local append run.
  await tester.pump(const Duration(milliseconds: 10));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('tapping an expense opens detail sheet with location map', (
    tester,
  ) async {
    final expense =
        makeActualExpense(
          category: 'habitacao',
          description: 'January rent',
        ).copyWith(
          locationLat: 38.7223,
          locationLng: -9.1393,
          locationAddress: 'Lisbon, Portugal',
        );

    await tester.pumpWidget(
      wrapWithTestApp(
        ExpenseTrackerScreen(
          settings: makeSettings(
            expenses: [makeExpense(category: 'habitacao', label: 'Rent')],
          ),
          expenses: [expense],
          householdId: 'house-1',
          onAdd: (_) async {},
          onUpdate: (_) async {},
          onDelete: (_) async {},
          onLoadMonth: (_) async => [expense],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ExpansionTile));
    await tester.pumpAndSettle();
    // 'January rent' appears in both the recent card and the expanded category
    // section; tap the first visible occurrence.
    await tester.tap(find.text('January rent').first);
    await tester.pumpAndSettle();

    expect(find.byType(ExpenseDetailSheet), findsOneWidget);
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.text('Lisbon, Portugal'), findsOneWidget);
  });

  group('#1233 — adding an expense while the parent rebuilds optimistically', () {
    testWidgets(
        'bills count rises by exactly 1 and the total is not doubled',
        (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(const _OptimisticParent(initialExpenses: [])),
      );
      await tester.pumpAndSettle();

      final summary = find.byKey(ExpenseTrackerTourKeys.summary);
      expect(find.descendant(of: summary, matching: find.text('0')),
          findsOneWidget);

      await _openSheetAndFillAmount(tester, '77.77');
      await _tapSave(tester);

      expect(
        find.descendant(of: summary, matching: find.text('1')),
        findsOneWidget,
        reason: 'Contas deve subir exactamente 1, não 2',
      );
      expect(find.descendant(of: summary, matching: find.text('2')),
          findsNothing);
      // "Este mês" total must be the entered value, not double it. Scoped
      // to the summary row: the same value legitimately also appears once
      // in the recent-expenses card and once in the category section.
      // NB: formatCurrency (pt-PT / intl) joins the amount and symbol with a
      // NON-BREAKING SPACE (U+00A0), not a regular space.
      expect(
          find.descendant(of: summary, matching: find.text('77,77 €')),
          findsOneWidget);
      expect(find.text('155,54 €'), findsNothing);
    });

    testWidgets(
        'two consecutive adds without reload increase the count by exactly N, no drift',
        (tester) async {
      await tester.pumpWidget(
        wrapWithTestApp(const _OptimisticParent(initialExpenses: [])),
      );
      await tester.pumpAndSettle();

      await _openSheetAndFillAmount(tester, '10.00');
      await _tapSave(tester);
      await _openSheetAndFillAmount(tester, '20.00');
      await _tapSave(tester);

      final summary = find.byKey(ExpenseTrackerTourKeys.summary);
      expect(
        find.descendant(of: summary, matching: find.text('2')),
        findsOneWidget,
        reason: '2 adições consecutivas devem somar +2, não +4',
      );
      expect(find.text('30,00 €'), findsOneWidget);
    });
  });
}
