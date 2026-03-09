class ShoppingItem {
  final String id; // UUID from Supabase; '' for items not yet persisted
  final String productName;
  final String store;
  final double price;
  final String? unitPrice;
  bool checked;

  /// Optional: ID of the meal that contributed this item.
  final String? sourceMealId;

  /// Optional: human-readable label of the source meal.
  final String? sourceMealLabel;

  /// Optional: user-selected preferred store for this item.
  final String? preferredStore;

  /// Optional: cheapest known store from price history.
  final String? cheapestKnownStore;

  /// Optional: cheapest known price from price history.
  final double? cheapestKnownPrice;

  /// Optional: quantity to buy (e.g. 0.7 for 700g).
  final double? quantity;

  /// Optional: unit of measurement (e.g. kg, g, un, L, mL).
  final String? unit;

  ShoppingItem({
    this.id = '',
    required this.productName,
    required this.store,
    required this.price,
    this.unitPrice,
    this.checked = false,
    this.sourceMealId,
    this.sourceMealLabel,
    this.preferredStore,
    this.cheapestKnownStore,
    this.cheapestKnownPrice,
    this.quantity,
    this.unit,
  }) : assert(price >= 0, 'price must be non-negative');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingItem &&
          id == other.id &&
          productName == other.productName &&
          store == other.store &&
          price == other.price &&
          unitPrice == other.unitPrice &&
          checked == other.checked &&
          sourceMealId == other.sourceMealId &&
          sourceMealLabel == other.sourceMealLabel &&
          preferredStore == other.preferredStore &&
          cheapestKnownStore == other.cheapestKnownStore &&
          cheapestKnownPrice == other.cheapestKnownPrice &&
          quantity == other.quantity &&
          unit == other.unit;

  @override
  int get hashCode => Object.hash(id, productName, store, price, unitPrice,
      checked, sourceMealId, sourceMealLabel, preferredStore,
      cheapestKnownStore, cheapestKnownPrice, quantity, unit);

  factory ShoppingItem.fromJson(Map<String, dynamic> json) {
    final rawPrice = (json['price'] as num?)?.toDouble() ?? 0;
    final rawCheapest = (json['cheapestKnownPrice'] as num?)?.toDouble();
    return ShoppingItem(
      id: json['id'] as String? ?? '',
      productName: json['productName'] as String? ?? '',
      store: json['store'] as String? ?? '',
      price: rawPrice < 0 ? 0 : rawPrice,
      unitPrice: json['unitPrice'] as String?,
      checked: json['checked'] as bool? ?? false,
      sourceMealId: json['sourceMealId'] as String?,
      sourceMealLabel: json['sourceMealLabel'] as String?,
      preferredStore: json['preferredStore'] as String?,
      cheapestKnownStore: json['cheapestKnownStore'] as String?,
      cheapestKnownPrice:
          rawCheapest != null && rawCheapest < 0 ? 0 : rawCheapest,
      quantity: (json['quantity'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productName': productName,
        'store': store,
        'price': price,
        if (unitPrice != null) 'unitPrice': unitPrice,
        'checked': checked,
        if (sourceMealId != null) 'sourceMealId': sourceMealId,
        if (sourceMealLabel != null) 'sourceMealLabel': sourceMealLabel,
        if (preferredStore != null) 'preferredStore': preferredStore,
        if (cheapestKnownStore != null)
          'cheapestKnownStore': cheapestKnownStore,
        if (cheapestKnownPrice != null)
          'cheapestKnownPrice': cheapestKnownPrice,
        if (quantity != null) 'quantity': quantity,
        if (unit != null) 'unit': unit,
      };

  factory ShoppingItem.fromSupabase(Map<String, dynamic> row) {
    final rawPrice = (row['price'] as num?)?.toDouble() ?? 0;
    final rawCheapest = (row['cheapest_known_price'] as num?)?.toDouble();
    return ShoppingItem(
      id: row['id'] as String,
      productName: row['product_name'] as String,
      store: row['store'] as String? ?? '',
      price: rawPrice < 0 ? 0 : rawPrice,
      unitPrice: row['unit_price'] as String?,
      checked: row['checked'] as bool? ?? false,
      sourceMealId: row['source_meal_id'] as String?,
      sourceMealLabel: row['source_meal_label'] as String?,
      preferredStore: row['preferred_store'] as String?,
      cheapestKnownStore: row['cheapest_known_store'] as String?,
      cheapestKnownPrice:
          rawCheapest != null && rawCheapest < 0 ? 0 : rawCheapest,
      quantity: (row['quantity'] as num?)?.toDouble(),
      unit: row['unit'] as String?,
    );
  }

  Map<String, dynamic> toSupabase(String householdId) => {
        'household_id': householdId,
        'product_name': productName,
        'store': store,
        'price': price,
        if (unitPrice != null) 'unit_price': unitPrice,
        'checked': checked,
        if (sourceMealId != null) 'source_meal_id': sourceMealId,
        if (sourceMealLabel != null) 'source_meal_label': sourceMealLabel,
        if (preferredStore != null) 'preferred_store': preferredStore,
        if (cheapestKnownStore != null)
          'cheapest_known_store': cheapestKnownStore,
        if (cheapestKnownPrice != null)
          'cheapest_known_price': cheapestKnownPrice,
        if (quantity != null) 'quantity': quantity,
        if (unit != null) 'unit': unit,
      };
}
