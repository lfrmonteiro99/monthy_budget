class CustomCategory {
  final String id;
  final String name;
  final String? iconName;
  final String? colorHex;
  final int sortOrder;

  const CustomCategory({
    required this.id,
    required this.name,
    this.iconName,
    this.colorHex,
    this.sortOrder = 0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomCategory &&
          id == other.id &&
          name == other.name &&
          iconName == other.iconName &&
          colorHex == other.colorHex &&
          sortOrder == other.sortOrder;

  @override
  int get hashCode => Object.hash(id, name, iconName, colorHex, sortOrder);

  CustomCategory copyWith({
    String? id,
    String? name,
    String? iconName,
    String? colorHex,
    int? sortOrder,
  }) {
    return CustomCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  factory CustomCategory.fromSupabase(Map<String, dynamic> map) {
    return CustomCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      iconName: map['icon_name'] as String?,
      colorHex: map['color_hex'] as String?,
      sortOrder: (map['sort_order'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toSupabase(String householdId) => {
        'id': id,
        'household_id': householdId,
        'name': name,
        'icon_name': iconName,
        'color_hex': colorHex,
        'sort_order': sortOrder,
      };
}
