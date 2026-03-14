import 'package:flutter/material.dart';

/// Map of icon name keys to their Material icon data.
/// Used by the custom category editor for icon selection.
const Map<String, IconData> categoryIconMap = {
  'home': Icons.home,
  'restaurant': Icons.restaurant,
  'directions_car': Icons.directions_car,
  'school': Icons.school,
  'local_hospital': Icons.local_hospital,
  'phone': Icons.phone,
  'bolt': Icons.bolt,
  'water_drop': Icons.water_drop,
  'sports_esports': Icons.sports_esports,
  'shopping_cart': Icons.shopping_cart,
  'pets': Icons.pets,
  'fitness_center': Icons.fitness_center,
  'flight': Icons.flight,
  'child_care': Icons.child_care,
  'build': Icons.build,
  'attach_money': Icons.attach_money,
  'credit_card': Icons.credit_card,
  'local_gas_station': Icons.local_gas_station,
  'wifi': Icons.wifi,
  'tv': Icons.tv,
  'local_laundry_service': Icons.local_laundry_service,
  'checkroom': Icons.checkroom,
  'more_horiz': Icons.more_horiz,
  'label': Icons.label,
};

/// Returns the [IconData] for a given icon name, or a default icon
/// if the name is null or not found in [categoryIconMap].
IconData getCategoryIcon(String? iconName) {
  if (iconName == null) return Icons.category;
  return categoryIconMap[iconName] ?? Icons.category;
}
