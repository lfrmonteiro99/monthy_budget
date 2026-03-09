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

/// Result of attempting to merge a new item into an existing list.
class MergeResult {
  /// The updated item if a duplicate was found, null if new.
  final ShoppingItem? merged;

  const MergeResult({this.merged});

  bool get isNew => merged == null;
}

/// Finds a duplicate by productName (case-insensitive) and aggregates
/// quantity + price. Returns [MergeResult] with merged item or null if new.
MergeResult mergeIntoList(List<ShoppingItem> existing, ShoppingItem newItem) {
  final match = existing.cast<ShoppingItem?>().firstWhere(
    (e) => e!.productName.toLowerCase() == newItem.productName.toLowerCase(),
    orElse: () => null,
  );
  if (match == null) return const MergeResult();

  final mergedQuantity = match.quantity != null && newItem.quantity != null
      ? match.quantity! + newItem.quantity!
      : match.quantity ?? newItem.quantity;

  return MergeResult(
    merged: ShoppingItem(
      id: match.id,
      productName: match.productName,
      store: match.store,
      price: match.price + newItem.price,
      unitPrice: match.unitPrice,
      checked: match.checked,
      sourceMealId: match.sourceMealId,
      sourceMealLabel: match.sourceMealLabel,
      preferredStore: match.preferredStore,
      cheapestKnownStore: match.cheapestKnownStore,
      cheapestKnownPrice: match.cheapestKnownPrice,
      quantity: mergedQuantity,
      unit: match.unit ?? newItem.unit,
    ),
  );
}

/// Returns which group modes have meaningful data for the given items.
/// Always includes [ShoppingGroupMode.items].
List<ShoppingGroupMode> availableGroupModes(List<ShoppingItem> items) {
  final modes = [ShoppingGroupMode.items];
  if (items.any((i) => i.sourceMealLabel != null)) {
    modes.add(ShoppingGroupMode.meals);
  }
  if (items.any((i) => i.preferredStore != null || i.store.isNotEmpty)) {
    modes.add(ShoppingGroupMode.stores);
  }
  return modes;
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
