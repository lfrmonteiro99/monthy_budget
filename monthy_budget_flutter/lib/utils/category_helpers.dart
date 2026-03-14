import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/app_settings.dart';
import '../theme/app_colors.dart';
import 'category_icons.dart';

/// Returns the localized label for a category name string.
///
/// If [categoryName] matches a predefined [ExpenseCategory] by `.name`,
/// returns its localized label. Otherwise returns the string as-is
/// (custom category).
String localizedCategoryLabel(String categoryName, S l10n) {
  for (final cat in ExpenseCategory.values) {
    if (cat.name == categoryName) {
      return cat.localizedLabel(l10n);
    }
  }
  return categoryName;
}

/// Returns the non-localized display label for a category name string.
///
/// If [categoryName] matches a predefined [ExpenseCategory] by `.name`,
/// returns its `.label`. Otherwise returns the string as-is.
String categoryLabel(String categoryName) {
  for (final cat in ExpenseCategory.values) {
    if (cat.name == categoryName) {
      return cat.label;
    }
  }
  return categoryName;
}

/// Returns the icon for a category name.
///
/// For predefined categories, returns the standard icon.
/// For custom categories, uses [getCategoryIcon] with the optional [iconName].
IconData categoryIconByName(String categoryName, {String? iconName}) {
  final predefined = <String, IconData>{
    'telecomunicacoes': Icons.phone,
    'energia': Icons.bolt,
    'agua': Icons.water_drop,
    'alimentacao': Icons.shopping_cart,
    'educacao': Icons.school,
    'habitacao': Icons.home,
    'transportes': Icons.directions_car,
    'saude': Icons.local_hospital,
    'lazer': Icons.sports_esports,
    'outros': Icons.category,
  };
  return predefined[categoryName] ?? getCategoryIcon(iconName);
}

/// Returns the color for a category name.
///
/// For predefined categories, uses [AppColors.categoryColorByName].
/// For custom categories, parses [colorHex] or falls back to a default.
Color categoryColorByNameFull(String categoryName, {String? colorHex}) {
  // Check if it's a predefined category
  for (final cat in ExpenseCategory.values) {
    if (cat.name == categoryName) {
      return AppColors.categoryColorByName(categoryName);
    }
  }
  // Custom category — parse colorHex or use default
  if (colorHex != null && colorHex.isNotEmpty) {
    final hex = colorHex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
  return AppColors.categoryColorByName(categoryName);
}
