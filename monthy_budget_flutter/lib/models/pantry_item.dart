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

  factory PantryItem.fromJson(Map<String, dynamic> json) => PantryItem(
        ingredientId: json['ingredientId'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        unit: json['unit'] as String,
        lastRestocked: json['lastRestocked'] != null
            ? DateTime.parse(json['lastRestocked'] as String)
            : null,
        lowThreshold: (json['lowThreshold'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'ingredientId': ingredientId,
        'quantity': quantity,
        'unit': unit,
        if (lastRestocked != null)
          'lastRestocked': lastRestocked!.toIso8601String(),
        if (lowThreshold != null) 'lowThreshold': lowThreshold,
      };
}
