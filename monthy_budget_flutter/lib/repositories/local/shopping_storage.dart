import 'package:drift/drift.dart';

import '../../models/shopping_item.dart';
import 'app_database.dart';

class ShoppingStorage {
  ShoppingStorage._();

  static LocalShoppingItemsCompanion companionOf(
    String householdId,
    ShoppingItem item, {
    bool pendingSync = true,
  }) {
    return LocalShoppingItemsCompanion.insert(
      id: item.id,
      householdId: householdId,
      productName: item.productName,
      store: Value(item.store),
      price: Value(item.price),
      unitPrice: Value(item.unitPrice),
      checked: Value(item.checked),
      sourceMealLabels: Value(item.sourceMealLabels),
      preferredStore: Value(item.preferredStore),
      cheapestKnownStore: Value(item.cheapestKnownStore),
      cheapestKnownPrice: Value(item.cheapestKnownPrice),
      quantity: Value(item.quantity),
      unit: Value(item.unit),
      pendingSync: Value(pendingSync),
      updatedAt: Value(DateTime.now()),
    );
  }

  static ShoppingItem fromRow(LocalShoppingItem row) => ShoppingItem(
    id: row.id,
    productName: row.productName,
    store: row.store,
    price: row.price,
    unitPrice: row.unitPrice,
    checked: row.checked,
    sourceMealLabels: row.sourceMealLabels,
    preferredStore: row.preferredStore,
    cheapestKnownStore: row.cheapestKnownStore,
    cheapestKnownPrice: row.cheapestKnownPrice,
    quantity: row.quantity,
    unit: row.unit,
    pendingSync: row.pendingSync,
  );
}
