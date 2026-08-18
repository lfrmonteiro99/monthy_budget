// Regression test for issue #1211: the month-navigation chevrons ('<' / '>')
// on the Expenses screen are icon-only IconButtons with no `tooltip:`, so
// they expose no accessible name at all to screen readers/keyboard nav.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/screens/expense_tracker_screen.dart';

import '../helpers/test_app.dart';
import '../helpers/test_helpers.dart';

void main() {
  Widget buildScreen() {
    return wrapWithTestApp(
      ExpenseTrackerScreen(
        settings: makeSettings(),
        expenses: const [],
        householdId: 'house-1',
        onAdd: (_) async {},
        onUpdate: (_) async {},
        onDelete: (_) async {},
        onLoadMonth: (_) async => [],
      ),
    );
  }

  group('#1211 expense tracker month-nav chevrons accessible name', () {
    testWidgets(
      'previous/next month IconButtons expose distinct, non-empty labels',
      (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(buildScreen());
        await tester.pumpAndSettle();

        final prevButtonFinder = find.ancestor(
          of: find.byIcon(Icons.chevron_left),
          matching: find.byType(IconButton),
        );
        final nextButtonFinder = find.ancestor(
          of: find.byIcon(Icons.chevron_right),
          matching: find.byType(IconButton),
        );
        expect(prevButtonFinder, findsOneWidget);
        expect(nextButtonFinder, findsOneWidget);

        final prevSemantics = tester.getSemantics(prevButtonFinder);
        final nextSemantics = tester.getSemantics(nextButtonFinder);

        // IconButton exposes `tooltip:` via SemanticsData.tooltip (merged
        // into the DOM node's aria-label by the web engine) — not `label`.
        // A missing `tooltip:` param leaves both label and tooltip empty.
        expect(prevSemantics.tooltip, isNotEmpty,
            reason: 'previous-month chevron must have an accessible name');
        expect(nextSemantics.tooltip, isNotEmpty,
            reason: 'next-month chevron must have an accessible name');
        expect(prevSemantics.tooltip, isNot(equals(nextSemantics.tooltip)),
            reason:
                'previous and next must be distinguishable, not the same label');

        handle.dispose();
      },
    );
  });
}
