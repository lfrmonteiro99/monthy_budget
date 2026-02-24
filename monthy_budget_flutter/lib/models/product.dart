class Product {
  final String id;
  final String name;
  final String category;
  final double avgPrice;
  final String unit;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.avgPrice,
    required this.unit,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        avgPrice: (json['avg_price'] as num).toDouble(),
        unit: json['unit'] as String,
      );
}
