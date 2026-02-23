/// Models for grocery price comparison data loaded from scraped JSON.

class GroceryData {
  final GroceryMetadata metadata;
  final DecoIndex decoIndex;
  final List<GroceryProduct> products;
  final List<ProductComparison> comparisons;
  final List<CategorySummary> categorySummary;

  const GroceryData({
    this.metadata = const GroceryMetadata(),
    this.decoIndex = const DecoIndex(),
    this.products = const [],
    this.comparisons = const [],
    this.categorySummary = const [],
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
    );
  }

  bool get hasProducts => products.isNotEmpty;
  bool get hasComparisons => comparisons.isNotEmpty;
}

class GroceryMetadata {
  final String scrapedAt;
  final int totalProducts;
  final int totalComparisons;

  const GroceryMetadata({
    this.scrapedAt = '',
    this.totalProducts = 0,
    this.totalComparisons = 0,
  });

  factory GroceryMetadata.fromJson(Map<String, dynamic> json) {
    return GroceryMetadata(
      scrapedAt: json['scraped_at'] as String? ?? '',
      totalProducts: json['total_products'] as int? ?? 0,
      totalComparisons: json['total_comparisons'] as int? ?? 0,
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
