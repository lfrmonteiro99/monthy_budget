import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_management/models/grocery_data.dart';

void main() {
  group('GroceryData stale store filtering', () {
    late GroceryData data;

    setUp(() {
      data = GroceryData.fromJson({
        'country_code': 'PT',
        'currency_code': 'EUR',
        'generated_at': '2026-03-21T10:00:00Z',
        'products': [
          {
            'id': 'milk_1l',
            'display_name': 'Whole Milk 1L',
            'category': 'Dairy',
            'brand': 'Mimosa',
            'size_unit': 'L',
          },
          {
            'id': 'bread_500g',
            'display_name': 'Bread 500g',
            'category': 'Bakery',
            'size_unit': 'kg',
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
          {
            'canonical_product_id': 'bread_500g',
            'product_name': 'Bread 500g',
            'store_id': 'continente',
            'category': 'Bakery',
            'price': 0.99,
            'price_per_base_unit': 1.98,
            'base_unit': 'kg',
          },
          {
            'canonical_product_id': 'bread_500g',
            'product_name': 'Bread 500g',
            'store_id': 'pingo_doce',
            'category': 'Bakery',
            'price': 1.09,
            'price_per_base_unit': 2.18,
            'base_unit': 'kg',
          },
          {
            'canonical_product_id': 'bread_500g',
            'product_name': 'Bread 500g',
            'store_id': 'auchan',
            'category': 'Bakery',
            'price': 0.89,
            'price_per_base_unit': 1.78,
            'base_unit': 'kg',
          },
        ],
      });
    });

    test('unfiltered data includes all stores', () {
      // Milk has 2 stores (continente + pingo_doce), Bread has 3
      expect(data.products.length, 2);
      expect(data.comparisons.length, 2);
      // Bread comparison includes all 3 stores
      final breadComparison = data.comparisons.firstWhere(
        (c) => c.productName == 'Bread 500g',
      );
      expect(breadComparison.prices.length, 3);
    });

    test('filterByFreshStores removes stale and failed store data', () {
      final filtered = data.filterByFreshStores();

      // Only Continente is fresh, so each product has exactly 1 store listing
      // With only 1 listing per product, comparisons need at least 2 stores
      expect(filtered.products.length, 2);
      expect(filtered.comparisons.length, 0);

      // Products should only reflect fresh store prices
      final milk = filtered.products.firstWhere((p) => p.name == 'Whole Milk 1L');
      expect(milk.price, closeTo(1.29, 0.001)); // Only Continente price

      final bread = filtered.products.firstWhere((p) => p.name == 'Bread 500g');
      expect(bread.price, closeTo(0.99, 0.001)); // Only Continente price
    });

    test('filterByFreshStores preserves metadata and country info', () {
      final filtered = data.filterByFreshStores();

      expect(filtered.countryCode, 'PT');
      expect(filtered.currencyCode, 'EUR');
      expect(filtered.generatedAt, data.generatedAt);
      expect(filtered.storeSummaries, data.storeSummaries);
    });

    test('filterByFreshStores returns same data when all stores are fresh', () {
      final allFreshData = GroceryData.fromJson({
        'country_code': 'PT',
        'currency_code': 'EUR',
        'generated_at': '2026-03-21T10:00:00Z',
        'products': [
          {
            'id': 'milk_1l',
            'display_name': 'Whole Milk 1L',
            'category': 'Dairy',
          },
        ],
        'stores': [
          {'store_id': 'continente', 'store_name': 'Continente'},
          {'store_id': 'pingo_doce', 'store_name': 'Pingo Doce'},
        ],
        'store_statuses': [
          {
            'store_id': 'continente',
            'store_name': 'Continente',
            'status': 'fresh',
            'listing_count': 10,
          },
          {
            'store_id': 'pingo_doce',
            'store_name': 'Pingo Doce',
            'status': 'fresh',
            'listing_count': 8,
          },
        ],
        'listings': [
          {
            'canonical_product_id': 'milk_1l',
            'product_name': 'Whole Milk 1L',
            'store_id': 'continente',
            'category': 'Dairy',
            'price': 1.29,
          },
          {
            'canonical_product_id': 'milk_1l',
            'product_name': 'Whole Milk 1L',
            'store_id': 'pingo_doce',
            'category': 'Dairy',
            'price': 1.39,
          },
        ],
      });

      final filtered = allFreshData.filterByFreshStores();
      expect(filtered.products.length, allFreshData.products.length);
      expect(filtered.comparisons.length, allFreshData.comparisons.length);
    });

    test('filterByFreshStores on legacy (non-bundle) data returns same instance', () {
      final legacyData = GroceryData.fromJson({
        'metadata': {
          'scraped_at': '2026-03-21T10:00:00Z',
          'total_products': 1,
        },
        'products': [
          {
            'name': 'Milk',
            'price': 1.49,
            'category': 'Dairy',
            'store': 'Continente',
          },
        ],
      });

      final filtered = legacyData.filterByFreshStores();
      // No store summaries means no filtering possible; returns same data
      expect(filtered.products.length, legacyData.products.length);
    });

    test('freshStoreNames returns only fresh store names', () {
      final freshNames = data.freshStoreNames;
      expect(freshNames, contains('Continente'));
      expect(freshNames, isNot(contains('Pingo Doce')));
      expect(freshNames, isNot(contains('Auchan')));
    });

    test('toCatalogProducts on filtered data reflects fresh-only prices', () {
      final filtered = data.filterByFreshStores();
      final catalogProducts = filtered.toCatalogProducts();

      expect(catalogProducts.length, 2);
      final milk = catalogProducts.firstWhere((p) => p.name == 'Whole Milk 1L');
      expect(milk.avgPrice, closeTo(1.29, 0.001));
    });
  });
}
