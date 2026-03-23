import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:monthly_management/services/command_pattern_cache.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CommandPatternCache', () {
    test('returns null for unknown input', () async {
      final cache = CommandPatternCache();
      await cache.load();

      expect(cache.match('something unknown'), isNull);
    });

    test('stores and retrieves exact pattern', () async {
      final cache = CommandPatternCache();
      await cache.load();

      await cache.store(
        input: 'go to settings',
        action: 'navigate_to',
        params: {'screen': 'settings'},
      );

      final result = cache.match('go to settings');
      expect(result, isNotNull);
      expect(result!.action, 'navigate_to');
      expect(result.params, {'screen': 'settings'});
    });

    test('fuzzy matches with different numbers and substitutes amount', () async {
      final cache = CommandPatternCache();
      await cache.load();

      await cache.store(
        input: 'mete 20 euros em comida',
        action: 'add_expense',
        params: {'category': 'alimentacao', 'amount': 20.0},
      );

      final result = cache.match('mete 50 euros em comida');
      expect(result, isNotNull);
      expect(result!.action, 'add_expense');
      expect(result.params['category'], 'alimentacao');
      expect(result.params['amount'], 50.0);
    });

    test('fuzzy matches decimal numbers with dot', () async {
      final cache = CommandPatternCache();
      await cache.load();

      await cache.store(
        input: 'add 12.50 to food',
        action: 'add_expense',
        params: {'category': 'alimentacao', 'amount': 12.50},
      );

      final result = cache.match('add 99.99 to food');
      expect(result, isNotNull);
      expect(result!.params['amount'], 99.99);
    });

    test('fuzzy matches decimal numbers with comma', () async {
      final cache = CommandPatternCache();
      await cache.load();

      await cache.store(
        input: 'add 12,50 to food',
        action: 'add_expense',
        params: {'category': 'alimentacao', 'amount': 12.50},
      );

      final result = cache.match('add 99,99 to food');
      expect(result, isNotNull);
      expect(result!.params['amount'], 99.99);
    });

    test('does not substitute amount when input has no numbers', () async {
      final cache = CommandPatternCache();
      await cache.load();

      await cache.store(
        input: 'go to settings',
        action: 'navigate_to',
        params: {'screen': 'settings'},
      );

      final result = cache.match('go to settings');
      expect(result, isNotNull);
      expect(result!.params, {'screen': 'settings'});
    });

    test('LRU eviction removes oldest entry at max capacity', () async {
      final cache = CommandPatternCache(maxEntries: 2);
      await cache.load();

      await cache.store(
        input: 'first command',
        action: 'action_a',
        params: {'key': 'a'},
      );
      await cache.store(
        input: 'second command',
        action: 'action_b',
        params: {'key': 'b'},
      );
      await cache.store(
        input: 'third command',
        action: 'action_c',
        params: {'key': 'c'},
      );

      // first should be evicted
      expect(cache.match('first command'), isNull);
      // second and third should remain
      expect(cache.match('second command'), isNotNull);
      expect(cache.match('third command'), isNotNull);
    });

    test('LRU access moves entry to end, preventing eviction', () async {
      final cache = CommandPatternCache(maxEntries: 2);
      await cache.load();

      await cache.store(
        input: 'first command',
        action: 'action_a',
        params: {'key': 'a'},
      );
      await cache.store(
        input: 'second command',
        action: 'action_b',
        params: {'key': 'b'},
      );

      // Access first, moving it to end
      cache.match('first command');

      // Insert third — should evict second (now oldest)
      await cache.store(
        input: 'third command',
        action: 'action_c',
        params: {'key': 'c'},
      );

      expect(cache.match('first command'), isNotNull);
      expect(cache.match('second command'), isNull);
      expect(cache.match('third command'), isNotNull);
    });

    test('persists to SharedPreferences and loads in new instance', () async {
      final cache1 = CommandPatternCache();
      await cache1.load();

      await cache1.store(
        input: 'mete 30 euros em comida',
        action: 'add_expense',
        params: {'category': 'alimentacao', 'amount': 30.0},
      );

      // Create new instance and load — should find the same data
      final cache2 = CommandPatternCache();
      await cache2.load();

      final result = cache2.match('mete 30 euros em comida');
      expect(result, isNotNull);
      expect(result!.action, 'add_expense');
      expect(result.params['category'], 'alimentacao');
      expect(result.params['amount'], 30.0);
    });

    test('clear removes all entries and SharedPreferences key', () async {
      final cache = CommandPatternCache();
      await cache.load();

      await cache.store(
        input: 'go to settings',
        action: 'navigate_to',
        params: {'screen': 'settings'},
      );

      await cache.clear();

      expect(cache.match('go to settings'), isNull);

      // Verify SharedPreferences is also cleared
      final cache2 = CommandPatternCache();
      await cache2.load();
      expect(cache2.match('go to settings'), isNull);
    });

    test('load gracefully handles corrupted JSON (#757)', () async {
      SharedPreferences.setMockInitialValues({
        'command_pattern_cache': 'this is not json {{{',
      });
      final cache = CommandPatternCache();
      await cache.load();
      expect(cache.match('anything'), isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('command_pattern_cache'), isNull);
    });

    test('load gracefully handles invalid structure (#757)', () async {
      SharedPreferences.setMockInitialValues({
        'command_pattern_cache': '["array","not","map"]',
      });
      final cache = CommandPatternCache();
      await cache.load();
      expect(cache.match('anything'), isNull);
    });
  });
}
