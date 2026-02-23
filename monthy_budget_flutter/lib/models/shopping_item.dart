class ShoppingItem {
  final String productName;
  final String store;
  final double price;
  final String? unitPrice;
  bool checked;

  ShoppingItem({
    required this.productName,
    required this.store,
    required this.price,
    this.unitPrice,
    this.checked = false,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        productName: json['productName'] as String? ?? '',
        store: json['store'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        unitPrice: json['unitPrice'] as String?,
        checked: json['checked'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'productName': productName,
        'store': store,
        'price': price,
        if (unitPrice != null) 'unitPrice': unitPrice,
        'checked': checked,
      };
}
