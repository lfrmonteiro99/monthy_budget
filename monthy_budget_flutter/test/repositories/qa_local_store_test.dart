import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/repositories/local/app_database.dart';
import 'package:monthly_management/repositories/local/qa_local_store.dart';

void main() {
  group('QaLocalStore', () {
    late AppDatabase database;
    late QaLocalStore store;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      store = QaLocalStore(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('round-trips a document through put/get', () async {
      final payload = {
        'id': 'doc-1',
        'household_id': 'hh-1',
        'amount': 12.5,
        'nested': {'a': 1, 'b': [1, 2, 3]},
        'nullable': null,
      };

      await store.put('things', 'hh-1', 'doc-1', payload);
      final read = await store.get('things', 'hh-1', 'doc-1');

      expect(read, equals(payload));
    });

    test('get returns null for an unknown document', () async {
      expect(await store.get('things', 'hh-1', 'nope'), isNull);
    });

    test('put replaces an existing document rather than duplicating it',
        () async {
      await store.put('things', 'hh-1', 'doc-1', {'v': 1});
      await store.put('things', 'hh-1', 'doc-1', {'v': 2});

      final rows = await store.query('things', 'hh-1');
      expect(rows, hasLength(1));
      expect(rows.single['v'], 2);
    });

    test('query is scoped to collection and household', () async {
      await store.putAll('things', 'hh-1', {
        'a': {'v': 'a'},
        'b': {'v': 'b'},
      });
      await store.put('things', 'hh-2', 'c', {'v': 'c'});
      await store.put('others', 'hh-1', 'd', {'v': 'd'});

      final rows = await store.query('things', 'hh-1');
      expect(rows.map((r) => r['v']), ['a', 'b']);
    });

    test('queryAll spans households for globally-scoped collections', () async {
      await store.put('products', 'scope-1', 'p1', {'v': 1});
      await store.put('products', 'scope-2', 'p2', {'v': 2});

      expect(await store.queryAll('products'), hasLength(2));
    });

    test('delete removes only the targeted document', () async {
      await store.putAll('things', 'hh-1', {
        'a': {'v': 'a'},
        'b': {'v': 'b'},
      });

      await store.delete('things', 'hh-1', 'a');

      final rows = await store.query('things', 'hh-1');
      expect(rows.map((r) => r['v']), ['b']);
    });

    test('deleteWhere removes documents matching the predicate', () async {
      await store.putAll('things', 'hh-1', {
        'a': {'checked': true},
        'b': {'checked': false},
        'c': {'checked': true},
      });

      await store.deleteWhere(
        'things',
        'hh-1',
        (payload) => payload['checked'] == true,
      );

      final rows = await store.query('things', 'hh-1');
      expect(rows, hasLength(1));
      expect(rows.single['checked'], false);
    });

    test('clearCollection empties one collection but leaves others', () async {
      await store.put('things', 'hh-1', 'a', {'v': 1});
      await store.put('others', 'hh-1', 'b', {'v': 2});

      await store.clearCollection('things', 'hh-1');

      expect(await store.query('things', 'hh-1'), isEmpty);
      expect(await store.query('others', 'hh-1'), hasLength(1));
    });

    test('putAll with an empty map is a no-op', () async {
      await store.putAll('things', 'hh-1', const {});
      expect(await store.query('things', 'hh-1'), isEmpty);
    });
  });
}
