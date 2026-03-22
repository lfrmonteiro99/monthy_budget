import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/actual_expense.dart';
import 'package:monthly_management/utils/expense_filter.dart';

import '../helpers/test_helpers.dart';

void main() {
  // Shared fixture: a small corpus of expenses to search/filter over.
  late List<ActualExpense> corpus;

  setUp(() {
    corpus = [
      makeActualExpense(
        id: 'e1',
        category: 'habitacao',
        amount: 500,
        description: 'Monthly rent',
        date: DateTime(2026, 1, 5),
      ),
      makeActualExpense(
        id: 'e2',
        category: 'alimentacao',
        amount: 42.50,
        description: 'Supermarket groceries',
        date: DateTime(2026, 1, 10),
      ),
      makeActualExpense(
        id: 'e3',
        category: 'transporte',
        amount: 30,
        description: 'Bus pass',
        date: DateTime(2026, 1, 15),
      ),
      makeActualExpense(
        id: 'e4',
        category: 'alimentacao',
        amount: 18.75,
        description: 'Lunch restaurant',
        date: DateTime(2026, 2, 3),
      ),
      makeActualExpense(
        id: 'e5',
        category: 'habitacao',
        amount: 500,
        description: null, // no description
        date: DateTime(2026, 2, 5),
      ),
    ];
  });

  group('filterExpenses', () {
    test('returns all expenses when no filters applied', () {
      final result = filterExpenses(corpus);
      expect(result, hasLength(5));
    });

    test('results are sorted by date descending', () {
      final result = filterExpenses(corpus);
      for (int i = 0; i < result.length - 1; i++) {
        expect(
          result[i].date.isAfter(result[i + 1].date) ||
              result[i].date == result[i + 1].date,
          isTrue,
        );
      }
    });

    // ── Text search ──────────────────────────────────────────

    test('filters by description (case-insensitive)', () {
      final result = filterExpenses(corpus, query: 'rent');
      expect(result.map((e) => e.id), ['e1']);
    });

    test('filters by category name in query', () {
      final result = filterExpenses(corpus, query: 'transporte');
      expect(result.map((e) => e.id), ['e3']);
    });

    test('filters by amount in query', () {
      final result = filterExpenses(corpus, query: '42.5');
      expect(result.map((e) => e.id), ['e2']);
    });

    test('query matches partial description', () {
      final result = filterExpenses(corpus, query: 'super');
      expect(result.map((e) => e.id), ['e2']);
    });

    test('empty query returns all', () {
      final result = filterExpenses(corpus, query: '');
      expect(result, hasLength(5));
    });

    test('expense without description still matchable by category', () {
      // e5 has no description but category is 'habitacao'
      final result = filterExpenses(corpus, query: 'habitacao');
      expect(result.map((e) => e.id).toList(), containsAll(['e1', 'e5']));
    });

    // ── Category filter ──────────────────────────────────────

    test('filters by single selected category', () {
      final result = filterExpenses(
        corpus,
        selectedCategories: {'alimentacao'},
      );
      expect(result.map((e) => e.id).toList(), containsAll(['e2', 'e4']));
      expect(result, hasLength(2));
    });

    test('filters by multiple selected categories', () {
      final result = filterExpenses(
        corpus,
        selectedCategories: {'alimentacao', 'transporte'},
      );
      expect(result, hasLength(3));
    });

    test('empty selectedCategories returns all', () {
      final result = filterExpenses(corpus, selectedCategories: {});
      expect(result, hasLength(5));
    });

    // ── Date range filter ────────────────────────────────────

    test('filters by dateFrom only', () {
      final result = filterExpenses(
        corpus,
        dateFrom: DateTime(2026, 1, 12),
      );
      // Should include e3 (Jan 15), e4 (Feb 3), e5 (Feb 5)
      expect(result.map((e) => e.id).toList(), containsAll(['e3', 'e4', 'e5']));
      expect(result, hasLength(3));
    });

    test('filters by dateTo only', () {
      final result = filterExpenses(
        corpus,
        dateTo: DateTime(2026, 1, 10),
      );
      // Should include e1 (Jan 5), e2 (Jan 10)
      expect(result.map((e) => e.id).toList(), containsAll(['e1', 'e2']));
      expect(result, hasLength(2));
    });

    test('filters by date range (from and to)', () {
      final result = filterExpenses(
        corpus,
        dateFrom: DateTime(2026, 1, 8),
        dateTo: DateTime(2026, 1, 15),
      );
      // e2 (Jan 10) and e3 (Jan 15)
      expect(result.map((e) => e.id).toList(), containsAll(['e2', 'e3']));
      expect(result, hasLength(2));
    });

    test('dateTo is inclusive of the end day', () {
      final result = filterExpenses(
        corpus,
        dateTo: DateTime(2026, 1, 15),
      );
      // e3 is on Jan 15, should be included
      expect(result.map((e) => e.id).toList(), contains('e3'));
    });

    // ── Combined filters ─────────────────────────────────────

    test('combines query and category filter', () {
      final result = filterExpenses(
        corpus,
        query: 'lunch',
        selectedCategories: {'alimentacao'},
      );
      expect(result.map((e) => e.id), ['e4']);
    });

    test('combines query and date range', () {
      final result = filterExpenses(
        corpus,
        query: 'rent',
        dateFrom: DateTime(2026, 2, 1),
      );
      // 'rent' matches e1 description, but e1 is Jan 5 which is before Feb 1
      expect(result, isEmpty);
    });

    test('combines all three filters', () {
      final result = filterExpenses(
        corpus,
        query: 'grocer',
        selectedCategories: {'alimentacao'},
        dateFrom: DateTime(2026, 1, 1),
        dateTo: DateTime(2026, 1, 31),
      );
      expect(result.map((e) => e.id), ['e2']);
    });

    test('returns empty list when no matches', () {
      final result = filterExpenses(corpus, query: 'nonexistent');
      expect(result, isEmpty);
    });

    test('returns empty when given empty input list', () {
      final result = filterExpenses([], query: 'anything');
      expect(result, isEmpty);
    });
  });

  group('extractCategories', () {
    test('extracts unique categories from history map', () {
      final history = <String, List<ActualExpense>>{
        '2026-01': corpus.where((e) => e.monthKey == '2026-01').toList(),
        '2026-02': corpus.where((e) => e.monthKey == '2026-02').toList(),
      };
      final cats = extractCategories(history);
      expect(cats, containsAll({'habitacao', 'alimentacao', 'transporte'}));
      expect(cats, hasLength(3));
    });

    test('returns empty set for empty history', () {
      expect(extractCategories({}), isEmpty);
    });
  });
}
