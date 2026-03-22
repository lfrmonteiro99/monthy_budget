import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/widgets/expense_detail_sheet.dart';

import '../helpers/test_app.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('ExpenseDetailSheet', () {
    testWidgets('renders embedded map when expense has location', (
      tester,
    ) async {
      final expense = makeActualExpense(description: 'January rent').copyWith(
        locationLat: 38.7223,
        locationLng: -9.1393,
        locationAddress: 'Lisbon, Portugal',
      );

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: ExpenseDetailSheet(
              expense: expense,
              categoryLabel: 'Housing',
              categoryIcon: Icons.home_outlined,
              categoryColor: Colors.blue,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.text('Lisbon, Portugal'), findsOneWidget);
      expect(find.text('January rent'), findsOneWidget);
    });

    testWidgets('omits embedded map when expense has no location', (
      tester,
    ) async {
      final expense = makeActualExpense(description: 'Coffee');

      await tester.pumpWidget(
        wrapWithTestApp(
          Scaffold(
            body: ExpenseDetailSheet(
              expense: expense,
              categoryLabel: 'Housing',
              categoryIcon: Icons.home_outlined,
              categoryColor: Colors.blue,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(FlutterMap), findsNothing);
      expect(find.text('Coffee'), findsOneWidget);
    });

    testWidgets(
      'shows receipt thumbnails when expense has attachmentUrls',
      (tester) async {
        final expense = makeActualExpense(description: 'Groceries').copyWith(
          attachmentUrls: [
            'https://example.com/receipt1.jpg',
            'https://example.com/receipt2.jpg',
          ],
        );

        await tester.pumpWidget(
          wrapWithTestApp(
            Scaffold(
              body: ExpenseDetailSheet(
                expense: expense,
                categoryLabel: 'Food',
                categoryIcon: Icons.restaurant,
                categoryColor: Colors.orange,
              ),
            ),
          ),
        );
        await tester.pump();

        // Receipts label should appear
        expect(find.text('Receipts'), findsOneWidget);
      },
    );

    testWidgets(
      'hides receipts section when expense has no attachments',
      (tester) async {
        final expense = makeActualExpense(description: 'Bus ticket');

        await tester.pumpWidget(
          wrapWithTestApp(
            Scaffold(
              body: ExpenseDetailSheet(
                expense: expense,
                categoryLabel: 'Transport',
                categoryIcon: Icons.directions_bus,
                categoryColor: Colors.green,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Receipts'), findsNothing);
      },
    );

    testWidgets(
      'hides receipts section when attachmentUrls is empty list',
      (tester) async {
        final expense = makeActualExpense(description: 'Taxi').copyWith(
          attachmentUrls: [],
        );

        await tester.pumpWidget(
          wrapWithTestApp(
            Scaffold(
              body: ExpenseDetailSheet(
                expense: expense,
                categoryLabel: 'Transport',
                categoryIcon: Icons.directions_bus,
                categoryColor: Colors.green,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Receipts'), findsNothing);
      },
    );
  });
}
