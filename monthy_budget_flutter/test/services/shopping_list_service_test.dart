import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/exceptions/app_exceptions.dart';
import 'package:monthly_management/models/shopping_item.dart';
import 'package:monthly_management/repositories/shopping_repository.dart';
import 'package:monthly_management/services/shopping_list_service.dart';

// ---------------------------------------------------------------------------
// Fake repository that lets each test control add() behaviour
// ---------------------------------------------------------------------------

class FakeShoppingRepository implements ShoppingRepository {
  /// When non-null, [add] returns this item.
  ShoppingItem? addResult;

  /// When non-null, [add] throws this error.
  Object? addError;

  @override
  Future<ShoppingItem> add(ShoppingItem item, String householdId) async {
    if (addError != null) throw addError!;
    return addResult ?? item;
  }

  // --- stubs for the remaining interface members (not under test) ---

  @override
  Stream<List<ShoppingItem>> stream(String householdId) =>
      const Stream.empty();

  @override
  Future<List<ShoppingItem>> load(String householdId) async => [];

  @override
  Future<void> updateItem(String id,
          {required double price, double? quantity, String? unit}) async {}

  @override
  Future<void> toggle(String id, bool checked) async {}

  @override
  Future<void> remove(String id) async {}

  @override
  Future<void> clearChecked(String householdId) async {}
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late FakeShoppingRepository fakeRepo;
  late ShoppingListService service;

  final sampleItem = ShoppingItem(
    productName: 'Milk',
    store: 'Lidl',
    price: 1.29,
  );

  final persistedItem = ShoppingItem(
    id: 'uuid-123',
    productName: 'Milk',
    store: 'Lidl',
    price: 1.29,
  );

  setUp(() {
    fakeRepo = FakeShoppingRepository();
    service = ShoppingListService(repository: fakeRepo);
  });

  group('ShoppingListService.add', () {
    test('returns item when repository returns exactly one result', () async {
      fakeRepo.addResult = persistedItem;

      final result = await service.add(sampleItem, 'hh-1');

      expect(result.id, 'uuid-123');
      expect(result.productName, 'Milk');
    });

    test('throws DataException when repository returns null (0 results)',
        () async {
      // After the .maybeSingle() fix the repository throws DataException
      // when the insert returns no row. The service re-wraps it.
      fakeRepo.addError =
          const DataException('Insert returned no row');

      expect(
        () => service.add(sampleItem, 'hh-1'),
        throwsA(isA<DataException>()),
      );
    });

    test(
        'throws DataException when repository throws due to >1 results',
        () async {
      // .maybeSingle() throws StateError for >1 rows; the service layer
      // wraps any repository error in DataException.
      fakeRepo.addError = StateError('multiple rows returned');

      expect(
        () => service.add(sampleItem, 'hh-1'),
        throwsA(isA<DataException>()),
      );
    });

    test('wraps arbitrary repository errors in DataException', () async {
      fakeRepo.addError = Exception('network timeout');

      expect(
        () => service.add(sampleItem, 'hh-1'),
        throwsA(isA<DataException>()),
      );
    });
  });
}
