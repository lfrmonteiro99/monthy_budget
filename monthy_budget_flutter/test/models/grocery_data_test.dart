import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/grocery_data.dart';

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
}
