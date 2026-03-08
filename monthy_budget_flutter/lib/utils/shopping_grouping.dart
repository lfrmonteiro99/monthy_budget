import '../models/shopping_item.dart';

/// How the shopping list is organized.
enum ShoppingGroupMode { items, meals, stores }

/// A named group of shopping items (e.g. a meal name or a store name).
class ShoppingGroup {
  final String label;
  final List<ShoppingItem> items;

  const ShoppingGroup({required this.label, required this.items});

  /// Total price for all items in this group.
  double get totalPrice => items.fold(0.0, (sum, i) => sum + i.price);

  /// Count of unchecked items.
  int get uncheckedCount => items.where((i) => !i.checked).length;
}

/// Summary of a store's items and estimated cost.
class StoreSummary {
  final String storeName;
  final int itemCount;
  final double totalPrice;

  const StoreSummary({
    required this.storeName,
    required this.itemCount,
    required this.totalPrice,
  });
}

/// Groups items by their [sourceMealLabel].
/// Items without a source meal are placed under [ungroupedLabel].
List<ShoppingGroup> groupByMeal(
  List<ShoppingItem> items, {
  String ungroupedLabel = 'Other',
}) {
  final map = <String, List<ShoppingItem>>{};
  for (final item in items) {
    final key = item.sourceMealLabel ?? ungroupedLabel;
    (map[key] ??= []).add(item);
  }
  return map.entries
      .map((e) => ShoppingGroup(label: e.key, items: e.value))
      .toList();
}

/// Groups items by their preferred store (falling back to [store]).
/// Items without any store are placed under [ungroupedLabel].
List<ShoppingGroup> groupByStore(
  List<ShoppingItem> items, {
  String ungroupedLabel = 'Other',
}) {
  final map = <String, List<ShoppingItem>>{};
  for (final item in items) {
    final key = item.preferredStore ?? (item.store.isNotEmpty ? item.store : ungroupedLabel);
    (map[key] ??= []).add(item);
  }
  return map.entries
      .map((e) => ShoppingGroup(label: e.key, items: e.value))
      .toList();
}

/// Computes per-store summaries across all items.
List<StoreSummary> computeStoreSummaries(List<ShoppingItem> items) {
  final map = <String, List<ShoppingItem>>{};
  for (final item in items) {
    final key = item.preferredStore ?? (item.store.isNotEmpty ? item.store : 'Unknown');
    (map[key] ??= []).add(item);
  }
  return map.entries
      .map((e) => StoreSummary(
            storeName: e.key,
            itemCount: e.value.length,
            totalPrice: e.value.fold(0.0, (s, i) => s + i.price),
          ))
      .toList()
    ..sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
}
