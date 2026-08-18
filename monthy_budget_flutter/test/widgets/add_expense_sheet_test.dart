import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/l10n/generated/app_localizations.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/widgets/add_expense_sheet.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      S.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: S.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: child),
  );
}

void main() {
  group('ExpenseFormResult', () {
    test('carries expense and empty attachment files by default', () {
      final expense = ActualExpense(
        id: 'exp_1',
        category: 'alimentacao',
        amount: 50.0,
        date: DateTime(2026, 3, 15),
        monthKey: '2026-03',
      );

      final result = ExpenseFormResult(expense: expense);

      expect(result.expense, expense);
      expect(result.newAttachmentFiles, isEmpty);
    });

    test('carries expense with attachment files', () {
      final expense = ActualExpense(
        id: 'exp_2',
        category: 'outros',
        amount: 25.0,
        date: DateTime(2026, 3, 10),
        monthKey: '2026-03',
        attachmentUrls: ['https://storage/old.jpg'],
      );
      final files = [File('/tmp/receipt.jpg'), File('/tmp/receipt2.jpg')];

      final result = ExpenseFormResult(
        expense: expense,
        newAttachmentFiles: files,
      );

      expect(result.expense.attachmentUrls, ['https://storage/old.jpg']);
      expect(result.newAttachmentFiles, hasLength(2));
      expect(result.newAttachmentFiles.first.path, '/tmp/receipt.jpg');
    });
  });

  group('_AddExpenseSheet category validation', () {
    Future<void> openSheet(WidgetTester tester) async {
      await tester.pumpWidget(_wrap(Builder(builder: (context) {
        return ElevatedButton(
          onPressed: () async {
            await showAddExpenseSheet(
              context: context,
              budgetExpenses: const [],
              currentExpenses: const [],
            );
          },
          child: const Text('open'),
        );
      })));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    // The sheet's Save button sits below the fold of the (0.65-height)
    // DraggableScrollableSheet, so it must be scrolled into view before it
    // can be tapped.
    Future<void> tapSave(WidgetTester tester) async {
      await tester.dragUntilVisible(
        find.text('Save'),
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
    }

    testWidgets(
        'tapping Save without a category keeps the sheet open and shows an inline error',
        (tester) async {
      await openSheet(tester);

      await tester.enterText(find.byType(TextFormField).first, '25');
      await tapSave(tester);

      // The sheet is still mounted (no pop happened) and the error is
      // visible inline, not hidden behind the sheet as a SnackBar.
      expect(find.text('Select a category'), findsOneWidget);
      expect(find.byType(ChoiceChip), findsWidgets);
    });

    testWidgets('error persists across repeated Save taps', (tester) async {
      await openSheet(tester);

      await tester.enterText(find.byType(TextFormField).first, '25');
      await tapSave(tester);
      expect(find.text('Select a category'), findsOneWidget);

      await tapSave(tester);
      expect(find.text('Select a category'), findsOneWidget);
    });

    testWidgets(
        'selecting a category chip clears the error and Save then closes the sheet',
        (tester) async {
      await openSheet(tester);

      await tester.enterText(find.byType(TextFormField).first, '25');
      await tapSave(tester);
      expect(find.text('Select a category'), findsOneWidget);

      await tester.tap(find.byType(ChoiceChip).first);
      await tester.pumpAndSettle();
      expect(find.text('Select a category'), findsNothing);

      await tapSave(tester);

      // Sheet closed: its content is no longer in the tree.
      expect(find.byType(ChoiceChip), findsNothing);
      expect(find.text('Save'), findsNothing);
    });

    testWidgets(
        'selecting the custom category chip also clears a previously shown error',
        (tester) async {
      await openSheet(tester);

      await tester.enterText(find.byType(TextFormField).first, '25');
      await tapSave(tester);
      expect(find.text('Select a category'), findsOneWidget);

      await tester.tap(find.text('Custom category'));
      await tester.pumpAndSettle();
      expect(find.text('Select a category'), findsNothing);
    });
  });
}
