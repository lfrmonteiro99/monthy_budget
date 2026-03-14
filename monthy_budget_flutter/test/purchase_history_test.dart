import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/purchase_record.dart';

void main() {
  group('PurchaseHistory', () {
    test('spentInMonth sums only matching month', () {
      final history = PurchaseHistory(
        records: [
          PurchaseRecord(
            id: '1',
            date: DateTime.utc(2026, 2, 2),
            amount: 10,
            itemCount: 1,
          ),
          PurchaseRecord(
            id: '2',
            date: DateTime.utc(2026, 2, 18),
            amount: 15.5,
            itemCount: 3,
          ),
          PurchaseRecord(
            id: '3',
            date: DateTime.utc(2026, 3, 1),
            amount: 99,
            itemCount: 8,
          ),
        ],
      );

      expect(history.spentInMonth(2026, 2), 25.5);
      expect(history.spentInMonth(2026, 3), 99);
      expect(history.spentInMonth(2026, 1), 0);
    });

    test('spentByMonth is sorted and excludes records older than cutoff', () {
      final now = DateTime.now();
      final twoMonthsAgo = DateTime(now.year, now.month - 2, 10);
      final oneMonthAgo = DateTime(now.year, now.month - 1, 10);
      final thisMonth = DateTime(now.year, now.month, 5);
      final veryOld = DateTime(now.year, now.month - 12, 1);

      final history = PurchaseHistory(
        records: [
          PurchaseRecord(
            id: 'old',
            date: veryOld,
            amount: 999,
            itemCount: 1,
          ),
          PurchaseRecord(
            id: 'a',
            date: twoMonthsAgo,
            amount: 10,
            itemCount: 1,
          ),
          PurchaseRecord(
            id: 'b',
            date: oneMonthAgo,
            amount: 20,
            itemCount: 1,
          ),
          PurchaseRecord(
            id: 'c',
            date: thisMonth,
            amount: 30,
            itemCount: 1,
          ),
        ],
      );

      final result = history.spentByMonth(months: 3);
      final keys = result.keys.toList();

      expect(keys.length, 3);
      expect(keys, orderedEquals([...keys]..sort()));
      expect(result.values.reduce((a, b) => a + b), 60);
    });

    test('serializes and deserializes JSON payload', () {
      final history = PurchaseHistory(
        records: [
          PurchaseRecord(
            id: '1',
            date: DateTime.utc(2026, 2, 2),
            amount: 12.5,
            itemCount: 2,
            items: ['Milk', 'Bread'],
            isMealPurchase: true,
          ),
        ],
      );

      final encoded = history.toJsonString();
      final decoded = PurchaseHistory.fromJsonString(encoded);

      expect(decoded.records.length, 1);
      expect(decoded.records.first.id, '1');
      expect(decoded.records.first.items, ['Milk', 'Bread']);
      expect(decoded.records.first.isMealPurchase, isTrue);
    });
  });
}
