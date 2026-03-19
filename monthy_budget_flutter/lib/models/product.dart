import 'package:json_annotation/json_annotation.dart';

part 'product.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, includeIfNull: false)
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

  Map<String, dynamic> toJson() => _$ProductToJson(this);

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}
