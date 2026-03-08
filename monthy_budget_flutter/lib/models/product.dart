class Product {
  final String id;
  final String name;
  final String category;
  final double avgPrice;
  final String unit;
  final String? barcode;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.avgPrice,
    required this.unit,
    this.barcode,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product &&
          id == other.id &&
          name == other.name &&
          category == other.category &&
          avgPrice == other.avgPrice &&
          unit == other.unit &&
          barcode == other.barcode;

  @override
  int get hashCode => Object.hash(id, name, category, avgPrice, unit, barcode);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'avg_price': avgPrice,
        'unit': unit,
        if (barcode != null) 'barcode': barcode,
      };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        avgPrice: (json['avg_price'] as num).toDouble(),
        unit: json['unit'] as String,
        barcode: json['barcode'] as String?,
      );
}
