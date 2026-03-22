import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/widgets/add_expense_sheet.dart';

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
}
