import 'package:flutter_test/flutter_test.dart';
import 'package:orcamento_mensal/models/grocery_data.dart';

void main() {
  test('GroceryData parses store statuses from country bundle payloads', () {
    final data = GroceryData.fromJson({
      'metadata': {
        'generated_at': '2026-03-09T10:00:00Z',
        'country_code': 'ES',
        'currency_code': 'EUR',
      },
      'store_statuses': [
        {
          'store_id': 'mercadona',
          'store_name': 'Mercadona',
          'status': 'fresh',
          'scraped_at': '2026-03-09T09:00:00Z',
          'listing_count': 120,
          'matched_count': 118,
          'unmatched_count': 2,
          'validation_warnings': [],
        },
        {
          'store_id': 'carrefour_es',
          'store_name': 'Carrefour',
          'status': 'failed',
          'scraped_at': '2026-03-08T09:00:00Z',
          'listing_count': 0,
          'matched_count': 0,
          'unmatched_count': 0,
          'validation_warnings': ['timeout'],
        },
      ],
    });

    expect(data.metadata.countryCode, 'ES');
    expect(data.metadata.currencyCode, 'EUR');
    expect(data.storeStatuses, hasLength(2));
    expect(data.freshStoreCount, 1);
    expect(data.failedStoreCount, 1);
    expect(data.hasDegradedStores, isTrue);
  });

  test('GroceryData filterComparisons removes non-fresh stores and recomputes cheapest result', () {
    final data = GroceryData.fromJson({
      'comparisons': [
        {
          'product_name': 'Milk',
          'prices': [
            {'store': 'Mercadona', 'price': 1.15, 'unit_price': '1.15/L'},
            {'store': 'Carrefour', 'price': 1.05, 'unit_price': '1.05/L'},
            {'store': 'Dia', 'price': 1.09, 'unit_price': '1.09/L'},
          ],
          'cheapest_store': 'Carrefour',
          'cheapest_price': 1.05,
          'potential_savings': 0.10,
          'savings_percent': 8.7,
        },
      ],
      'store_statuses': [
        {
          'store_id': 'mercadona',
          'store_name': 'Mercadona',
          'status': 'fresh',
          'scraped_at': '2026-03-09T09:00:00Z',
          'listing_count': 100,
          'matched_count': 100,
          'unmatched_count': 0,
          'validation_warnings': [],
        },
        {
          'store_id': 'carrefour_es',
          'store_name': 'Carrefour',
          'status': 'failed',
          'scraped_at': '2026-03-08T09:00:00Z',
          'listing_count': 0,
          'matched_count': 0,
          'unmatched_count': 0,
          'validation_warnings': [],
        },
        {
          'store_id': 'dia',
          'store_name': 'Dia',
          'status': 'partial',
          'scraped_at': '2026-03-08T21:00:00Z',
          'listing_count': 95,
          'matched_count': 80,
          'unmatched_count': 15,
          'validation_warnings': ['high unmatched'],
        },
      ],
    });

    final filtered = data.filterComparisons(hideStaleStores: true);

    expect(filtered, hasLength(1));
    expect(filtered.first.prices, hasLength(1));
    expect(filtered.first.prices.first.store, 'Mercadona');
    expect(filtered.first.cheapestStore, 'Mercadona');
    expect(filtered.first.cheapestPrice, 1.15);
  });

  test('GroceryData keeps legacy payloads compatible', () {
    final data = GroceryData.fromJson({
      'metadata': {
        'scraped_at': '2026-03-09T10:00:00Z',
        'total_products': 1,
      },
      'products': [
        {
          'name': 'Milk',
          'price': 1.5,
          'category': 'Dairy',
          'store': 'Continente',
        },
      ],
    });

    expect(data.products, hasLength(1));
    expect(data.storeStatuses, isEmpty);
    expect(data.hasDegradedStores, isFalse);
  });
}
