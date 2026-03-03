# Shopping List — Design

**Date:** 2026-02-23

## Summary

Add a shopping list that users fill from individual products inside the Categorias tab.
The list lives as a new bottom nav item ("Lista") and groups items by store.

---

## User Flow

1. User opens **Supermercados → Categorias**
2. Taps a category card chevron → card expands to show individual products
   (name, store, price from `GroceryData.products`)
3. Taps `+` on a product row → item added to shopping list (toast confirmation)
4. User navigates to **Lista** (bottom nav, 3rd item)
5. Lista screen shows items **grouped by store** with a running total
6. User taps a row to **check it off** (strikethrough, greyed out)
7. User can **swipe left** to delete an item
8. "Limpar lista" button clears all checked items

---

## Data Model

```dart
class ShoppingItem {
  final String productName;
  final String store;
  final double price;
  final String? unitPrice;
  bool checked;
}
```

Stored as JSON array in `SharedPreferences` under key `shopping_list`.

---

## New Files

| File | Purpose |
|------|---------|
| `lib/models/shopping_item.dart` | `ShoppingItem` model with `fromJson`/`toJson` |
| `lib/services/shopping_list_service.dart` | load/save via SharedPreferences |
| `lib/screens/shopping_list_screen.dart` | Lista screen |

---

## Modified Files

| File | Change |
|------|--------|
| `lib/main.dart` | Load shopping list at startup; add Lista nav item; wire `_saveShoppingList` |
| `lib/screens/grocery_screen.dart` | Expand category cards to show products; `+` button per product |

---

## Categorias Tab — Category Card Expansion

Each `_buildCategoryCard` gets:
- A chevron icon (collapsed by default, per-card state via `Set<String> _expandedCategories`)
- When expanded: `ListView` of `GroceryProduct` rows filtered by category
- Each product row: name, store badge, price, `+` IconButton

Tapping `+` calls `widget.onAddToShoppingList(ShoppingItem(...))`.

---

## Lista Screen

Layout:
```
┌─────────────────────────────┐
│ Lista de Compras            │
│ 5 itens · 12,45 €           │
├─────────────────────────────┤
│ AUCHAN (3)                  │
│ ☐ Leite Mimosa 1L   0,89 €  │  ← tap to check, swipe to delete
│ ☑ Ovos M (checked) 1,99 €  │  ← strikethrough, greyed
│ ☐ Frango peito     3,49 €  │
├─────────────────────────────┤
│ PINGO DOCE (2)              │
│ ☐ Iogurte natural  0,59 €  │
│ ☐ Queijo flamengo  2,49 €  │
├─────────────────────────────┤
│         Total: 9,45 €       │  ← sum of unchecked items
│   [Limpar comprados]        │
└─────────────────────────────┘
```

---

## State Management

- `_shoppingList` held in `_AppHomeState` (same pattern as `_favorites`)
- Passed down to `GroceryScreen` via `onAddToShoppingList` callback
- `ShoppingListScreen` receives the list + callbacks for check/delete/clear

---

## Persistence

`ShoppingListService` — identical pattern to `FavoritesService`:
- `load() → Future<List<ShoppingItem>>`
- `save(List<ShoppingItem>) → Future<void>`
- Key: `shopping_list`

---

## Bottom Nav

Add "Lista" as 3rd destination with `Icons.shopping_basket_outlined` / `Icons.shopping_basket`.
Badge showing count of unchecked items (hidden when 0).
