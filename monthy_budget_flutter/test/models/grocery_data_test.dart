import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/grocery_data.dart';

void main() {
  group('GroceryData.fromJson', () {
    test('keeps legacy grocery payload support', () {
      final data = GroceryData.fromJson({
        'metadata': {
          'scraped_at': '2026-03-09T10:00:00Z',
          'total_products': 1,
          'total_comparisons': 0,
        },
        'products': [
          {
            'name': 'Milk',
            'price': 1.49,
            'unit_price': '1.49/L',
            'category': 'Dairy',
            'store': 'Continente',
          },
        ],
      });

      expect(data.countryCode, isEmpty);
      expect(data.products, hasLength(1));
      expect(data.products.first.name, 'Milk');
      expect(data.hasCountryBundle, isFalse);
    });

    test('parses country bundle payload and derives UI models', () {
      final data = GroceryData.fromJson({
        'country_code': 'PT',
        'currency_code': 'EUR',
        'generated_at': '2026-03-09T10:00:00Z',
        'products': [
          {
            'id': 'milk_1l',
            'display_name': 'Whole Milk 1L',
            'category': 'Dairy',
            'brand': 'Mimosa',
            'size_unit': 'L',
          },
        ],
        'stores': [
          {'store_id': 'continente', 'store_name': 'Continente'},
          {'store_id': 'pingo_doce', 'store_name': 'Pingo Doce'},
          {'store_id': 'auchan', 'store_name': 'Auchan'},
        ],
        'store_statuses': [
          {
            'country_code': 'PT',
            'store_id': 'continente',
            'store_name': 'Continente',
            'status': 'fresh',
            'listing_count': 20,
            'matched_count': 18,
            'unmatched_count': 2,
          },
          {
            'country_code': 'PT',
            'store_id': 'pingo_doce',
            'store_name': 'Pingo Doce',
            'status': 'partial',
            'listing_count': 12,
            'matched_count': 9,
            'unmatched_count': 3,
            'validation_warning_count': 1,
          },
          {
            'country_code': 'PT',
            'store_id': 'auchan',
            'store_name': 'Auchan',
            'status': 'failed',
            'listing_count': 0,
            'matched_count': 0,
            'unmatched_count': 0,
          },
        ],
        'listings': [
          {
            'canonical_product_id': 'milk_1l',
            'product_name': 'Whole Milk 1L',
            'store_id': 'continente',
            'category': 'Dairy',
            'price': 1.29,
            'price_per_base_unit': 1.29,
            'base_unit': 'L',
          },
          {
            'canonical_product_id': 'milk_1l',
            'product_name': 'Whole Milk 1L',
            'store_id': 'pingo_doce',
            'category': 'Dairy',
            'price': 1.39,
            'price_per_base_unit': 1.39,
            'base_unit': 'L',
          },
        ],
      });

      expect(data.countryCode, 'PT');
      expect(data.currencyCode, 'EUR');
      expect(data.generatedAt, '2026-03-09T10:00:00Z');
      expect(data.hasCountryBundle, isTrue);
      expect(data.storeSummaries, hasLength(3));
      expect(data.freshStoreCount, 1);
      expect(data.partialStoreCount, 1);
      expect(data.failedStoreCount, 1);
      expect(data.hasDegradedStores, isTrue);
      expect(data.products, hasLength(1));
      expect(data.products.first.name, 'Whole Milk 1L');
      expect(data.products.first.price, closeTo(1.34, 0.001));
      expect(data.comparisons, hasLength(1));
      expect(data.comparisons.first.cheapestStore, 'Continente');
      expect(data.categorySummary, hasLength(1));

      final catalogProducts = data.toCatalogProducts();
      expect(catalogProducts, hasLength(1));
      expect(catalogProducts.first.category, 'Dairy');
      expect(catalogProducts.first.unit, 'L');
    });
  });

  group('GroceryStoreStatus enum', () {
    test('includes stale status value', () {
      expect(GroceryStoreStatus.values, contains(GroceryStoreStatus.stale));
    });
  });

  group('GroceryStoreSummary freshness metadata', () {
    test('isFresh returns true only for fresh status', () {
      const store = GroceryStoreSummary(status: GroceryStoreStatus.fresh);
      expect(store.isFresh, isTrue);
      expect(store.isStale, isFalse);
      expect(store.isPartial, isFalse);
      expect(store.isFailed, isFalse);
    });

    test('isStale returns true only for stale status', () {
      const store = GroceryStoreSummary(status: GroceryStoreStatus.stale);
      expect(store.isFresh, isFalse);
      expect(store.isStale, isTrue);
      expect(store.isPartial, isFalse);
      expect(store.isFailed, isFalse);
    });

    test('isPartial returns true only for partial status', () {
      const store = GroceryStoreSummary(status: GroceryStoreStatus.partial);
      expect(store.isFresh, isFalse);
      expect(store.isStale, isFalse);
      expect(store.isPartial, isTrue);
      expect(store.isFailed, isFalse);
    });

    test('isFailed returns true only for failed status', () {
      const store = GroceryStoreSummary(status: GroceryStoreStatus.failed);
      expect(store.isFresh, isFalse);
      expect(store.isStale, isFalse);
      expect(store.isPartial, isFalse);
      expect(store.isFailed, isTrue);
    });

    test('isDegraded is true for stale, partial, and failed', () {
      const fresh = GroceryStoreSummary(status: GroceryStoreStatus.fresh);
      const stale = GroceryStoreSummary(status: GroceryStoreStatus.stale);
      const partial = GroceryStoreSummary(status: GroceryStoreStatus.partial);
      const failed = GroceryStoreSummary(status: GroceryStoreStatus.failed);

      expect(fresh.isDegraded, isFalse);
      expect(stale.isDegraded, isTrue);
      expect(partial.isDegraded, isTrue);
      expect(failed.isDegraded, isTrue);
    });

    test('lastUpdatedDateTime parses valid ISO 8601 timestamp', () {
      const store = GroceryStoreSummary(
        lastUpdatedAt: '2026-03-20T12:00:00Z',
      );
      expect(store.lastUpdatedDateTime, isNotNull);
      expect(store.lastUpdatedDateTime, DateTime.utc(2026, 3, 20, 12));
    });

    test('lastUpdatedDateTime returns null for empty timestamp', () {
      const store = GroceryStoreSummary(lastUpdatedAt: '');
      expect(store.lastUpdatedDateTime, isNull);
    });

    test('lastUpdatedDateTime returns null for malformed timestamp', () {
      const store = GroceryStoreSummary(lastUpdatedAt: 'not-a-date');
      expect(store.lastUpdatedDateTime, isNull);
    });

    test('freshnessAge returns non-negative duration for valid timestamp', () {
      // Use a timestamp in the past to guarantee positive duration
      const store = GroceryStoreSummary(
        lastUpdatedAt: '2020-01-01T00:00:00Z',
      );
      final age = store.freshnessAge;
      expect(age, isNotNull);
      expect(age!.inDays, greaterThan(0));
    });

    test('freshnessAge returns null for empty timestamp', () {
      const store = GroceryStoreSummary(lastUpdatedAt: '');
      expect(store.freshnessAge, isNull);
    });

    test('freshnessAge returns null for malformed timestamp', () {
      const store = GroceryStoreSummary(lastUpdatedAt: 'garbage');
      expect(store.freshnessAge, isNull);
    });

    test('fromJson parses stale status string', () {
      final store = GroceryStoreSummary.fromJson({
        'store_id': 'lidl',
        'store_name': 'Lidl',
        'status': 'stale',
      });
      expect(store.status, GroceryStoreStatus.stale);
      expect(store.isStale, isTrue);
      expect(store.isDegraded, isTrue);
    });

    test('fromJson defaults unknown status to fresh', () {
      final store = GroceryStoreSummary.fromJson({
        'store_id': 'x',
        'store_name': 'X',
        'status': 'unknown_value',
      });
      expect(store.status, GroceryStoreStatus.fresh);
    });
  });

  group('GroceryData freshness aggregates', () {
    test('staleStoreCount counts stale stores', () {
      const data = GroceryData(
        storeSummaries: [
          GroceryStoreSummary(
            storeId: 'a',
            status: GroceryStoreStatus.fresh,
          ),
          GroceryStoreSummary(
            storeId: 'b',
            status: GroceryStoreStatus.stale,
          ),
          GroceryStoreSummary(
            storeId: 'c',
            status: GroceryStoreStatus.stale,
          ),
          GroceryStoreSummary(
            storeId: 'd',
            status: GroceryStoreStatus.failed,
          ),
        ],
      );
      expect(data.staleStoreCount, 2);
    });

    test('overallFreshness returns fresh when all stores are fresh', () {
      const data = GroceryData(
        storeSummaries: [
          GroceryStoreSummary(status: GroceryStoreStatus.fresh),
          GroceryStoreSummary(status: GroceryStoreStatus.fresh),
        ],
      );
      expect(data.overallFreshness, GroceryStoreStatus.fresh);
    });

    test('overallFreshness returns failed when any store has failed', () {
      const data = GroceryData(
        storeSummaries: [
          GroceryStoreSummary(status: GroceryStoreStatus.fresh),
          GroceryStoreSummary(status: GroceryStoreStatus.failed),
        ],
      );
      expect(data.overallFreshness, GroceryStoreStatus.failed);
    });

    test('overallFreshness returns partial when worst is partial', () {
      const data = GroceryData(
        storeSummaries: [
          GroceryStoreSummary(status: GroceryStoreStatus.fresh),
          GroceryStoreSummary(status: GroceryStoreStatus.partial),
        ],
      );
      expect(data.overallFreshness, GroceryStoreStatus.partial);
    });

    test('overallFreshness returns stale when worst is stale', () {
      const data = GroceryData(
        storeSummaries: [
          GroceryStoreSummary(status: GroceryStoreStatus.fresh),
          GroceryStoreSummary(status: GroceryStoreStatus.stale),
        ],
      );
      expect(data.overallFreshness, GroceryStoreStatus.stale);
    });

    test('overallFreshness returns fresh when no stores exist', () {
      const data = GroceryData(storeSummaries: []);
      expect(data.overallFreshness, GroceryStoreStatus.fresh);
    });

    test('degradedStoreSummaries includes stale stores', () {
      const data = GroceryData(
        storeSummaries: [
          GroceryStoreSummary(
            storeId: 'a',
            status: GroceryStoreStatus.fresh,
          ),
          GroceryStoreSummary(
            storeId: 'b',
            status: GroceryStoreStatus.stale,
          ),
        ],
      );
      expect(data.degradedStoreSummaries, hasLength(1));
      expect(data.degradedStoreSummaries.first.storeId, 'b');
    });

    test('availableStoreSummaries excludes only failed stores', () {
      const data = GroceryData(
        storeSummaries: [
          GroceryStoreSummary(
            storeId: 'a',
            status: GroceryStoreStatus.fresh,
          ),
          GroceryStoreSummary(
            storeId: 'b',
            status: GroceryStoreStatus.stale,
          ),
          GroceryStoreSummary(
            storeId: 'c',
            status: GroceryStoreStatus.partial,
          ),
          GroceryStoreSummary(
            storeId: 'd',
            status: GroceryStoreStatus.failed,
          ),
        ],
      );
      expect(data.availableStoreSummaries, hasLength(3));
      expect(
        data.availableStoreSummaries.map((s) => s.storeId).toList(),
        ['a', 'b', 'c'],
      );
    });
  });
}
