import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/screens/expense_tracker_screen.dart';
import 'package:monthly_management/widgets/expense_detail_sheet.dart';

import '../helpers/test_app.dart';
import '../helpers/test_helpers.dart';

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
    await tester.tap(find.text('January rent'));
    await tester.pumpAndSettle();

    expect(find.byType(ExpenseDetailSheet), findsOneWidget);
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.text('Lisbon, Portugal'), findsOneWidget);
  });
}
