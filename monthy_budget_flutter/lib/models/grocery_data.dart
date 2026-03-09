// Models for grocery price comparison data loaded from scraped JSON.

enum GroceryStoreDatasetStatus {
  fresh,
  partial,
  failed;

  bool get isFresh => this == GroceryStoreDatasetStatus.fresh;
  bool get isDegraded => this != GroceryStoreDatasetStatus.fresh;

  static GroceryStoreDatasetStatus fromJson(String? value) {
    switch (value) {
      case 'partial':
        return GroceryStoreDatasetStatus.partial;
      case 'failed':
        return GroceryStoreDatasetStatus.failed;
      default:
        return GroceryStoreDatasetStatus.fresh;
    }
  }
}

class GroceryData {
  final GroceryMetadata metadata;
  final DecoIndex decoIndex;
  final List<GroceryProduct> products;
  final List<ProductComparison> comparisons;
  final List<CategorySummary> categorySummary;
  final List<GroceryStoreStatus> storeStatuses;

  const GroceryData({
    this.metadata = const GroceryMetadata(),
    this.decoIndex = const DecoIndex(),
    this.products = const [],
    this.comparisons = const [],
    this.categorySummary = const [],
    this.storeStatuses = const [],
  });

  factory GroceryData.fromJson(Map<String, dynamic> json) {
    return GroceryData(
      metadata: GroceryMetadata.fromJson(json['metadata'] as Map<String, dynamic>? ?? {}),
      decoIndex: DecoIndex.fromJson(json['deco_index'] as Map<String, dynamic>? ?? {}),
      products: (json['products'] as List<dynamic>? ?? [])
          .map((p) => GroceryProduct.fromJson(p as Map<String, dynamic>))
          .toList(),
      comparisons: (json['comparisons'] as List<dynamic>? ?? [])
          .map((c) => ProductComparison.fromJson(c as Map<String, dynamic>))
          .toList(),
      categorySummary: (json['category_summary'] as List<dynamic>? ?? [])
          .map((s) => CategorySummary.fromJson(s as Map<String, dynamic>))
          .toList(),
      storeStatuses: (json['store_statuses'] as List<dynamic>? ?? [])
          .map((s) => GroceryStoreStatus.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }

  bool get hasProducts => products.isNotEmpty;
  bool get hasComparisons => comparisons.isNotEmpty;
  bool get hasStoreStatuses => storeStatuses.isNotEmpty;
  int get freshStoreCount => storeStatuses.where((s) => s.status.isFresh).length;
  int get partialStoreCount => storeStatuses.where((s) => s.status == GroceryStoreDatasetStatus.partial).length;
  int get failedStoreCount => storeStatuses.where((s) => s.status == GroceryStoreDatasetStatus.failed).length;
  bool get hasDegradedStores => partialStoreCount > 0 || failedStoreCount > 0;

  List<GroceryStoreStatus> visibleStoreStatuses({bool hideStaleStores = false}) {
    if (!hideStaleStores) return storeStatuses;
    return storeStatuses.where((status) => status.status.isFresh).toList();
  }

  List<ProductComparison> filterComparisons({bool hideStaleStores = false}) {
    if (!hideStaleStores || storeStatuses.isEmpty) return comparisons;

    final freshStores = {
      for (final status in storeStatuses.where((s) => s.status.isFresh)) ...[
        _normalizeStoreKey(status.storeId),
        _normalizeStoreKey(status.storeName),
      ]
    };

    return comparisons
        .map((comparison) {
          final filteredPrices = comparison.prices
              .where((price) => freshStores.contains(_normalizeStoreKey(price.store)))
              .toList();
          if (filteredPrices.isEmpty) return null;
          return ProductComparison.fromPrices(
            productName: comparison.productName,
            prices: filteredPrices,
          );
        })
        .whereType<ProductComparison>()
        .toList();
  }
}

String _normalizeStoreKey(String value) => value.trim().toLowerCase().replaceAll(' ', '_');

class GroceryMetadata {
  final String scrapedAt;
  final int totalProducts;
  final int totalComparisons;
  final String countryCode;
  final String currencyCode;
  final String generatedAt;

  const GroceryMetadata({
    this.scrapedAt = '',
    this.totalProducts = 0,
    this.totalComparisons = 0,
    this.countryCode = 'PT',
    this.currencyCode = 'EUR',
    this.generatedAt = '',
  });

  factory GroceryMetadata.fromJson(Map<String, dynamic> json) {
    final generatedAt = json['generated_at'] as String? ?? '';
    final scrapedAt = json['scraped_at'] as String? ?? generatedAt;
    return GroceryMetadata(
      scrapedAt: scrapedAt,
      totalProducts: json['total_products'] as int? ?? 0,
      totalComparisons: json['total_comparisons'] as int? ?? 0,
      countryCode: (json['country_code'] as String? ?? 'PT').toUpperCase(),
      currencyCode: (json['currency_code'] as String? ?? 'EUR').toUpperCase(),
      generatedAt: generatedAt.isEmpty ? scrapedAt : generatedAt,
    );
  }
}

class DecoIndex {
  final String period;
  final String source;
  final int basketSize;
  final List<StoreRanking> rankings;

  const DecoIndex({
    this.period = '',
    this.source = '',
    this.basketSize = 0,
    this.rankings = const [],
  });

  factory DecoIndex.fromJson(Map<String, dynamic> json) {
    return DecoIndex(
      period: json['period'] as String? ?? '',
      source: json['source'] as String? ?? '',
      basketSize: json['basket_size'] as int? ?? 0,
      rankings: (json['rankings'] as List<dynamic>? ?? [])
          .map((r) => StoreRanking.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StoreRanking {
  final String store;
  final int index;
  final int rank;

  const StoreRanking({this.store = '', this.index = 100, this.rank = 1});

  factory StoreRanking.fromJson(Map<String, dynamic> json) {
    return StoreRanking(
      store: json['store'] as String? ?? '',
      index: json['index'] as int? ?? 100,
      rank: json['rank'] as int? ?? 1,
    );
  }
}

class GroceryProduct {
  final String name;
  final double price;
  final String? unitPrice;
  final String category;
  final String store;
  final String? brand;
  final String? promotion;

  const GroceryProduct({
    this.name = '',
    this.price = 0,
    this.unitPrice,
    this.category = '',
    this.store = '',
    this.brand,
    this.promotion,
  });

  factory GroceryProduct.fromJson(Map<String, dynamic> json) {
    return GroceryProduct(
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      unitPrice: json['unit_price'] as String?,
      category: json['category'] as String? ?? '',
      store: json['store'] as String? ?? '',
      brand: json['brand'] as String?,
      promotion: json['promotion'] as String?,
    );
  }
}

class ProductComparison {
  final String productName;
  final List<StorePrice> prices;
  final String cheapestStore;
  final double cheapestPrice;
  final double potentialSavings;
  final double savingsPercent;

  const ProductComparison({
    this.productName = '',
    this.prices = const [],
    this.cheapestStore = '',
    this.cheapestPrice = 0,
    this.potentialSavings = 0,
    this.savingsPercent = 0,
  });

  factory ProductComparison.fromJson(Map<String, dynamic> json) {
    return ProductComparison(
      productName: json['product_name'] as String? ?? '',
      prices: (json['prices'] as List<dynamic>? ?? [])
          .map((p) => StorePrice.fromJson(p as Map<String, dynamic>))
          .toList(),
      cheapestStore: json['cheapest_store'] as String? ?? '',
      cheapestPrice: (json['cheapest_price'] as num?)?.toDouble() ?? 0,
      potentialSavings: (json['potential_savings'] as num?)?.toDouble() ?? 0,
      savingsPercent: (json['savings_percent'] as num?)?.toDouble() ?? 0,
    );
  }

  factory ProductComparison.fromPrices({
    required String productName,
    required List<StorePrice> prices,
  }) {
    final sorted = [...prices]..sort((a, b) => a.price.compareTo(b.price));
    final cheapest = sorted.first;
    final mostExpensive = sorted.last;
    final savings = mostExpensive.price - cheapest.price;
    final savingsPercent = mostExpensive.price <= 0
        ? 0.0
        : (savings / mostExpensive.price) * 100;
    return ProductComparison(
      productName: productName,
      prices: sorted,
      cheapestStore: cheapest.store,
      cheapestPrice: cheapest.price,
      potentialSavings: savings,
      savingsPercent: savingsPercent,
    );
  }
}

class StorePrice {
  final String store;
  final double price;
  final String? unitPrice;

  const StorePrice({this.store = '', this.price = 0, this.unitPrice});

  factory StorePrice.fromJson(Map<String, dynamic> json) {
    return StorePrice(
      store: json['store'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      unitPrice: json['unit_price'] as String?,
    );
  }
}

class CategorySummary {
  final String category;
  final Map<String, StoreCategoryStats> stores;
  final String cheapestStore;

  const CategorySummary({
    this.category = '',
    this.stores = const {},
    this.cheapestStore = '',
  });

  factory CategorySummary.fromJson(Map<String, dynamic> json) {
    final storesJson = json['stores'] as Map<String, dynamic>? ?? {};
    final stores = storesJson.map(
      (key, value) => MapEntry(key, StoreCategoryStats.fromJson(value as Map<String, dynamic>)),
    );
    return CategorySummary(
      category: json['category'] as String? ?? '',
      stores: stores,
      cheapestStore: json['cheapest_store'] as String? ?? '',
    );
  }
}

class StoreCategoryStats {
  final double avgPrice;
  final int productCount;
  final double minPrice;
  final double maxPrice;

  const StoreCategoryStats({
    this.avgPrice = 0,
    this.productCount = 0,
    this.minPrice = 0,
    this.maxPrice = 0,
  });

  factory StoreCategoryStats.fromJson(Map<String, dynamic> json) {
    return StoreCategoryStats(
      avgPrice: (json['avg_price'] as num?)?.toDouble() ?? 0,
      productCount: json['product_count'] as int? ?? 0,
      minPrice: (json['min_price'] as num?)?.toDouble() ?? 0,
      maxPrice: (json['max_price'] as num?)?.toDouble() ?? 0,
    );
  }
}

class GroceryStoreStatus {
  final String storeId;
  final String storeName;
  final GroceryStoreDatasetStatus status;
  final String scrapedAt;
  final int listingCount;
  final int matchedCount;
  final int unmatchedCount;
  final List<String> validationWarnings;

  const GroceryStoreStatus({
    this.storeId = '',
    this.storeName = '',
    this.status = GroceryStoreDatasetStatus.fresh,
    this.scrapedAt = '',
    this.listingCount = 0,
    this.matchedCount = 0,
    this.unmatchedCount = 0,
    this.validationWarnings = const [],
  });

  factory GroceryStoreStatus.fromJson(Map<String, dynamic> json) {
    return GroceryStoreStatus(
      storeId: json['store_id'] as String? ?? '',
      storeName: json['store_name'] as String? ?? '',
      status: GroceryStoreDatasetStatus.fromJson(json['status'] as String?),
      scrapedAt: json['scraped_at'] as String? ?? '',
      listingCount: json['listing_count'] as int? ?? 0,
      matchedCount: json['matched_count'] as int? ?? 0,
      unmatchedCount: json['unmatched_count'] as int? ?? 0,
      validationWarnings: (json['validation_warnings'] as List<dynamic>? ?? [])
          .map((warning) => warning.toString())
          .toList(),
    );
  }
}
