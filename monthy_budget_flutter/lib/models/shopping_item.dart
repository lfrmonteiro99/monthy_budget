class ShoppingItem {
  final String id; // UUID from Supabase; '' for items not yet persisted
  final String productName;
  final String store;
  final double price;
  final String? unitPrice;
  bool checked;

  ShoppingItem({
    this.id = '',
    required this.productName,
    required this.store,
    required this.price,
    this.unitPrice,
    this.checked = false,
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
          checked == other.checked;

  @override
  int get hashCode =>
      Object.hash(id, productName, store, price, unitPrice, checked);

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        id: json['id'] as String? ?? '',
        productName: json['productName'] as String? ?? '',
        store: json['store'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        unitPrice: json['unitPrice'] as String?,
        checked: json['checked'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'productName': productName,
        'store': store,
        'price': price,
        if (unitPrice != null) 'unitPrice': unitPrice,
        'checked': checked,
      };

  factory ShoppingItem.fromSupabase(Map<String, dynamic> row) => ShoppingItem(
        id: row['id'] as String,
        productName: row['product_name'] as String,
        store: row['store'] as String? ?? '',
        price: (row['price'] as num?)?.toDouble() ?? 0,
        unitPrice: row['unit_price'] as String?,
        checked: row['checked'] as bool? ?? false,
      );

  Map<String, dynamic> toSupabase(String householdId) => {
        'household_id': householdId,
        'product_name': productName,
        'store': store,
        'price': price,
        if (unitPrice != null) 'unit_price': unitPrice,
        'checked': checked,
      };
}
