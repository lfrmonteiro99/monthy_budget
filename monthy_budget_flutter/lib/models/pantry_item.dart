import 'package:json_annotation/json_annotation.dart';

part 'pantry_item.g.dart';

@JsonSerializable(includeIfNull: false)
class PantryItem {
  final String ingredientId;
  final double quantity;
  final String unit;
  final DateTime? lastRestocked;
  final double? lowThreshold;

  const PantryItem({
    required this.ingredientId,
    required this.quantity,
    required this.unit,
    this.lastRestocked,
    this.lowThreshold,
  });

  bool get isLow => lowThreshold != null && quantity <= lowThreshold!;
  bool get isDepleted => quantity <= 0;

  PantryItem copyWith({
    double? quantity,
    String? unit,
    DateTime? lastRestocked,
    double? lowThreshold,
  }) =>
      PantryItem(
        ingredientId: ingredientId,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        lastRestocked: lastRestocked ?? this.lastRestocked,
        lowThreshold: lowThreshold ?? this.lowThreshold,
      );

  factory PantryItem.fromJson(Map<String, dynamic> json) =>
      _$PantryItemFromJson(json);

  Map<String, dynamic> toJson() => _$PantryItemToJson(this);
}
