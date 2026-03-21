import 'product.dart';

// Models for grocery price comparison data loaded from scraped JSON.

class GroceryData {
  final GroceryMetadata metadata;
  final DecoIndex decoIndex;
  final List<GroceryProduct> products;
  final List<ProductComparison> comparisons;
  final List<CategorySummary> categorySummary;
  final String countryCode;
  final String currencyCode;
  final String generatedAt;
  final List<GroceryStoreSummary> storeSummaries;

  /// Raw listings retained for re-derivation during filtering.
  final List<GroceryBundleListing> _listings;

  /// Catalog product index retained for re-derivation during filtering.
  final Map<String, GroceryCatalogProduct> _catalogProducts;

  const GroceryData({
    this.metadata = const GroceryMetadata(),
    this.decoIndex = const DecoIndex(),
    this.products = const [],
    this.comparisons = const [],
    this.categorySummary = const [],
    this.countryCode = '',
    this.currencyCode = '',
    this.generatedAt = '',
    this.storeSummaries = const [],
    List<GroceryBundleListing> listings = const [],
    Map<String, GroceryCatalogProduct> catalogProducts = const {},
  })  : _listings = listings,
        _catalogProducts = catalogProducts;

  factory GroceryData.fromJson(Map<String, dynamic> json) {
    if (_looksLikeCountryBundle(json)) {
      return _fromCountryBundle(json);
    }

    return GroceryData(
      metadata: GroceryMetadata.fromJson(
        json['metadata'] as Map<String, dynamic>? ?? {},
      ),
      decoIndex: DecoIndex.fromJson(
        json['deco_index'] as Map<String, dynamic>? ?? {},
      ),
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

  static bool _looksLikeCountryBundle(Map<String, dynamic> json) {
    return json.containsKey('listings') ||
        json.containsKey('stores') ||
        json.containsKey('store_statuses');
  }

  static GroceryData _fromCountryBundle(Map<String, dynamic> json) {
    final countryCode = (json['country_code'] as String? ?? '').toUpperCase();
    final currencyCode = json['currency_code'] as String? ?? '';
    final generatedAt = json['generated_at'] as String? ?? '';

    final statuses = (json['store_statuses'] as List<dynamic>? ?? [])
        .map((entry) => GroceryStoreSummary.fromJson(
              entry as Map<String, dynamic>,
            ))
        .toList();
    final storeIndex = {
      for (final store in (json['stores'] as List<dynamic>? ?? [])
          .map((entry) => GroceryBundleStore.fromJson(entry as Map<String, dynamic>)))
        store.storeId: store,
    };
    final listings = (json['listings'] as List<dynamic>? ?? [])
        .map((entry) => GroceryBundleListing.fromJson(
              entry as Map<String, dynamic>,
              countryCode: countryCode,
              storeIndex: storeIndex,
            ))
        .toList();
    final catalogProducts = {
      for (final product in (json['products'] as List<dynamic>? ?? [])
          .map((entry) => GroceryCatalogProduct.fromJson(entry as Map<String, dynamic>)))
        product.id: product,
    };

    final products = _deriveProducts(listings, catalogProducts);
    final comparisons = _deriveComparisons(listings, catalogProducts);
    final categorySummary = _deriveCategorySummary(listings, catalogProducts);
    final metadata = GroceryMetadata(
      scrapedAt: generatedAt,
      totalProducts: products.length,
      totalComparisons: comparisons.length,
    );

    return GroceryData(
      metadata: metadata,
      products: products,
      comparisons: comparisons,
      categorySummary: categorySummary,
      countryCode: countryCode,
      currencyCode: currencyCode,
      generatedAt: generatedAt,
      storeSummaries: statuses,
      listings: listings,
      catalogProducts: catalogProducts,
    );
  }

  static List<GroceryProduct> _deriveProducts(
    List<GroceryBundleListing> listings,
    Map<String, GroceryCatalogProduct> catalogProducts,
  ) {
    final byProduct = <String, List<GroceryBundleListing>>{};
    for (final listing in listings) {
      final key = listing.productId;
      if (key.isEmpty || listing.price <= 0) continue;
      byProduct.putIfAbsent(key, () => []).add(listing);
    }

    final result = <GroceryProduct>[];
    for (final entry in byProduct.entries) {
      final listingGroup = entry.value;
      if (listingGroup.isEmpty) continue;
      final catalog = catalogProducts[entry.key];
      final avgPrice = listingGroup
              .map((item) => item.price)
              .fold<double>(0, (sum, value) => sum + value) /
          listingGroup.length;
      final seed = listingGroup.first;
      result.add(
        GroceryProduct(
          name: catalog?.displayName ?? seed.productName,
          price: avgPrice,
          unitPrice: _formatUnitPrice(seed.pricePerBaseUnit, seed.baseUnit),
          category: catalog?.category ?? seed.category,
          store: listingGroup.length == 1 ? seed.storeName : '',
          brand: catalog?.brand ?? seed.brand,
        ),
      );
    }

    result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return result;
  }

  static List<ProductComparison> _deriveComparisons(
    List<GroceryBundleListing> listings,
    Map<String, GroceryCatalogProduct> catalogProducts,
  ) {
    final byProduct = <String, List<GroceryBundleListing>>{};
    for (final listing in listings) {
      final key = listing.productId;
      if (key.isEmpty || listing.price <= 0) continue;
      byProduct.putIfAbsent(key, () => []).add(listing);
    }

    final result = <ProductComparison>[];
    for (final entry in byProduct.entries) {
      final listingGroup = entry.value;
      if (listingGroup.length < 2) continue;
      final prices = listingGroup
          .map(
            (listing) => StorePrice(
              store: listing.storeName,
              price: listing.price,
              unitPrice: _formatUnitPrice(
                listing.pricePerBaseUnit,
                listing.baseUnit,
              ),
            ),
          )
          .toList()
        ..sort((a, b) => a.price.compareTo(b.price));
      final cheapest = prices.first;
      final mostExpensive = prices.last;
      final potentialSavings = mostExpensive.price - cheapest.price;
      final savingsPercent = mostExpensive.price > 0
          ? (potentialSavings / mostExpensive.price) * 100
          : 0.0;
      result.add(
        ProductComparison(
          productName:
              catalogProducts[entry.key]?.displayName ?? listingGroup.first.productName,
          prices: prices,
          cheapestStore: cheapest.store,
          cheapestPrice: cheapest.price,
          potentialSavings: potentialSavings,
          savingsPercent: savingsPercent,
        ),
      );
    }

    result.sort(
      (a, b) => b.potentialSavings.compareTo(a.potentialSavings),
    );
    return result;
  }

  static List<CategorySummary> _deriveCategorySummary(
    List<GroceryBundleListing> listings,
    Map<String, GroceryCatalogProduct> catalogProducts,
  ) {
    final byCategory = <String, List<GroceryBundleListing>>{};
    for (final listing in listings) {
      if (listing.price <= 0) continue;
      final category = catalogProducts[listing.productId]?.category ?? listing.category;
      if (category.isEmpty) continue;
      byCategory.putIfAbsent(category, () => []).add(listing);
    }

    final result = <CategorySummary>[];
    for (final entry in byCategory.entries) {
      final byStore = <String, List<GroceryBundleListing>>{};
      for (final listing in entry.value) {
        byStore.putIfAbsent(listing.storeName, () => []).add(listing);
      }
      final stores = <String, StoreCategoryStats>{};
      for (final storeEntry in byStore.entries) {
        final prices = storeEntry.value.map((item) => item.price).toList();
        final avgPrice =
            prices.fold<double>(0, (sum, value) => sum + value) / prices.length;
        prices.sort();
        stores[storeEntry.key] = StoreCategoryStats(
          avgPrice: avgPrice,
          productCount: prices.length,
          minPrice: prices.first,
          maxPrice: prices.last,
        );
      }

      var cheapestStore = '';
      var cheapestAvg = double.infinity;
      for (final storeEntry in stores.entries) {
        if (storeEntry.value.avgPrice < cheapestAvg) {
          cheapestAvg = storeEntry.value.avgPrice;
          cheapestStore = storeEntry.key;
        }
      }

      result.add(
        CategorySummary(
          category: entry.key,
          stores: stores,
          cheapestStore: cheapestStore,
        ),
      );
    }

    result.sort((a, b) => a.category.toLowerCase().compareTo(b.category.toLowerCase()));
    return result;
  }

  static String? _formatUnitPrice(double? pricePerBaseUnit, String? baseUnit) {
    if (pricePerBaseUnit == null || pricePerBaseUnit <= 0) return null;
    if (baseUnit == null || baseUnit.isEmpty) {
      return pricePerBaseUnit.toStringAsFixed(2);
    }
    return '${pricePerBaseUnit.toStringAsFixed(2)}/$baseUnit';
  }

  bool get hasProducts => products.isNotEmpty;
  bool get hasComparisons => comparisons.isNotEmpty;
  bool get hasStoreSummaries => storeSummaries.isNotEmpty;
  bool get hasCountryBundle =>
      countryCode.isNotEmpty || currencyCode.isNotEmpty || hasStoreSummaries;

  List<GroceryStoreSummary> get degradedStoreSummaries =>
      storeSummaries.where((summary) => summary.isDegraded).toList();

  List<GroceryStoreSummary> get availableStoreSummaries =>
      storeSummaries.where((summary) => summary.status != GroceryStoreStatus.failed).toList();

  bool get hasDegradedStores => degradedStoreSummaries.isNotEmpty;
  int get freshStoreCount =>
      storeSummaries.where((summary) => summary.status == GroceryStoreStatus.fresh).length;
  int get staleStoreCount =>
      storeSummaries.where((summary) => summary.status == GroceryStoreStatus.stale).length;
  int get partialStoreCount =>
      storeSummaries.where((summary) => summary.status == GroceryStoreStatus.partial).length;
  int get failedStoreCount =>
      storeSummaries.where((summary) => summary.status == GroceryStoreStatus.failed).length;

  /// Returns the worst status across all stores, using severity ordering:
  /// failed > partial > stale > fresh. Defaults to [GroceryStoreStatus.fresh]
  /// when there are no stores.
  GroceryStoreStatus get overallFreshness {
    if (storeSummaries.isEmpty) return GroceryStoreStatus.fresh;
    var worst = GroceryStoreStatus.fresh;
    for (final summary in storeSummaries) {
      if (summary.status.index > worst.index) {
        worst = summary.status;
      }
    }
    return worst;
  }

  /// Store names with [GroceryStoreStatus.fresh] status.
  Set<String> get freshStoreNames => {
        for (final summary in storeSummaries)
          if (summary.status == GroceryStoreStatus.fresh) summary.storeName,
      };

  /// Returns a new [GroceryData] containing only listings from fresh stores.
  GroceryData filterByFreshStores() {
    if (!hasStoreSummaries || !hasDegradedStores) return this;

    final freshIds = {
      for (final summary in storeSummaries)
        if (summary.status == GroceryStoreStatus.fresh) summary.storeId,
    };

    final filteredListings =
        _listings.where((l) => freshIds.contains(l.storeId)).toList();

    final filteredProducts =
        _deriveProducts(filteredListings, _catalogProducts);
    final filteredComparisons =
        _deriveComparisons(filteredListings, _catalogProducts);
    final filteredCategorySummary =
        _deriveCategorySummary(filteredListings, _catalogProducts);
    final filteredMetadata = GroceryMetadata(
      scrapedAt: metadata.scrapedAt,
      totalProducts: filteredProducts.length,
      totalComparisons: filteredComparisons.length,
    );

    return GroceryData(
      metadata: filteredMetadata,
      decoIndex: decoIndex,
      products: filteredProducts,
      comparisons: filteredComparisons,
      categorySummary: filteredCategorySummary,
      countryCode: countryCode,
      currencyCode: currencyCode,
      generatedAt: generatedAt,
      storeSummaries: storeSummaries,
      listings: _listings,
      catalogProducts: _catalogProducts,
    );
  }

  List<Product> toCatalogProducts() {
    return products
        .map(
          (product) => Product(
            id: '${countryCode.isEmpty ? 'grocery' : countryCode}_${product.name}',
            name: product.name,
            category: product.category,
            avgPrice: product.price,
            unit: _unitFromUnitPrice(product.unitPrice),
          ),
        )
        .toList();
  }

  static String _unitFromUnitPrice(String? unitPrice) {
    if (unitPrice == null || unitPrice.isEmpty) return 'un';
    final index = unitPrice.lastIndexOf('/');
    if (index == -1 || index == unitPrice.length - 1) return 'un';
    return unitPrice.substring(index + 1);
  }
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
      (key, value) => MapEntry(
        key,
        StoreCategoryStats.fromJson(value as Map<String, dynamic>),
      ),
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

enum GroceryStoreStatus { fresh, stale, partial, failed }

class GroceryStoreSummary {
  final String countryCode;
  final String storeId;
  final String storeName;
  final GroceryStoreStatus status;
  final String lastUpdatedAt;
  final int listingCount;
  final int matchedCount;
  final int unmatchedCount;
  final int validationWarningCount;
  final String? sourceVersion;
  final String? error;

  const GroceryStoreSummary({
    this.countryCode = '',
    this.storeId = '',
    this.storeName = '',
    this.status = GroceryStoreStatus.fresh,
    this.lastUpdatedAt = '',
    this.listingCount = 0,
    this.matchedCount = 0,
    this.unmatchedCount = 0,
    this.validationWarningCount = 0,
    this.sourceVersion,
    this.error,
  });

  factory GroceryStoreSummary.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['status'] as String? ?? 'fresh';
    return GroceryStoreSummary(
      countryCode: (json['country_code'] as String? ?? '').toUpperCase(),
      storeId: json['store_id'] as String? ?? '',
      storeName: json['store_name'] as String? ?? '',
      status: switch (rawStatus) {
        'stale' => GroceryStoreStatus.stale,
        'partial' => GroceryStoreStatus.partial,
        'failed' => GroceryStoreStatus.failed,
        _ => GroceryStoreStatus.fresh,
      },
      lastUpdatedAt: json['last_updated_at'] as String? ??
          json['scraped_at'] as String? ??
          '',
      listingCount: json['listing_count'] as int? ?? 0,
      matchedCount: json['matched_count'] as int? ?? 0,
      unmatchedCount: json['unmatched_count'] as int? ?? 0,
      validationWarningCount:
          (json['validation_warnings'] as List<dynamic>?)?.length ??
              (json['validation_warning_count'] as int? ?? 0),
      sourceVersion: json['source_version'] as String?,
      error: json['error'] as String?,
    );
  }

  bool get isFresh => status == GroceryStoreStatus.fresh;
  bool get isStale => status == GroceryStoreStatus.stale;
  bool get isPartial => status == GroceryStoreStatus.partial;
  bool get isFailed => status == GroceryStoreStatus.failed;
  bool get isDegraded => status != GroceryStoreStatus.fresh;

  /// Parses [lastUpdatedAt] as a [DateTime]. Returns null when the field is
  /// empty or cannot be parsed (safe degradation).
  DateTime? get lastUpdatedDateTime {
    if (lastUpdatedAt.isEmpty) return null;
    return DateTime.tryParse(lastUpdatedAt);
  }

  /// How long ago the store data was last updated. Returns null when
  /// [lastUpdatedAt] is missing or malformed.
  Duration? get freshnessAge {
    final dt = lastUpdatedDateTime;
    if (dt == null) return null;
    return DateTime.now().toUtc().difference(dt);
  }
}

class GroceryBundleStore {
  final String storeId;
  final String storeName;

  const GroceryBundleStore({
    this.storeId = '',
    this.storeName = '',
  });

  factory GroceryBundleStore.fromJson(Map<String, dynamic> json) {
    return GroceryBundleStore(
      storeId: json['store_id'] as String? ?? '',
      storeName: json['store_name'] as String? ?? '',
    );
  }
}

class GroceryCatalogProduct {
  final String id;
  final String displayName;
  final String category;
  final String? brand;
  final String? unit;

  const GroceryCatalogProduct({
    this.id = '',
    this.displayName = '',
    this.category = '',
    this.brand,
    this.unit,
  });

  factory GroceryCatalogProduct.fromJson(Map<String, dynamic> json) {
    return GroceryCatalogProduct(
      id: json['id'] as String? ?? '',
      displayName: json['display_name'] as String? ??
          json['name'] as String? ??
          json['normalized_name'] as String? ??
          '',
      category: json['category'] as String? ?? '',
      brand: json['brand'] as String?,
      unit: json['size_unit'] as String? ?? json['base_unit'] as String?,
    );
  }
}

class GroceryBundleListing {
  final String productId;
  final String productName;
  final String storeId;
  final String storeName;
  final String category;
  final String? brand;
  final double price;
  final double? pricePerBaseUnit;
  final String? baseUnit;

  const GroceryBundleListing({
    this.productId = '',
    this.productName = '',
    this.storeId = '',
    this.storeName = '',
    this.category = '',
    this.brand,
    this.price = 0,
    this.pricePerBaseUnit,
    this.baseUnit,
  });

  factory GroceryBundleListing.fromJson(
    Map<String, dynamic> json, {
    required String countryCode,
    required Map<String, GroceryBundleStore> storeIndex,
  }) {
    final storeId = json['store_id'] as String? ?? '';
    final store = storeIndex[storeId];
    return GroceryBundleListing(
      productId: json['canonical_product_id'] as String? ??
          json['product_id'] as String? ??
          '',
      productName: json['product_name'] as String? ??
          json['display_name'] as String? ??
          json['normalized_name'] as String? ??
          '',
      storeId: storeId,
      storeName: json['store_name'] as String? ?? store?.storeName ?? storeId,
      category: json['category'] as String? ?? '',
      brand: json['brand'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      pricePerBaseUnit: (json['price_per_base_unit'] as num?)?.toDouble() ??
          (json['price_per_unit'] as num?)?.toDouble(),
      baseUnit: json['base_unit'] as String? ?? json['size_unit'] as String?,
    );
  }
}
