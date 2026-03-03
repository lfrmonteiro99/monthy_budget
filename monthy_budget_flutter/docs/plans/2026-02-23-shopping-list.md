# Shopping List Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a shopping list that users fill by expanding category cards in the Categorias tab and tapping `+` on individual products; the list lives as a new bottom nav item, groups items by store, and persists across app restarts.

**Architecture:** `ShoppingItem` model → `ShoppingListService` (SharedPreferences, same pattern as `FavoritesService`) → `ShoppingListScreen` (grouped by store, swipe-to-delete, tap-to-check) wired through `_AppHomeState` like favorites. Category cards in `GroceryScreen` gain expand/collapse to reveal individual `GroceryProduct` rows.

**Tech Stack:** Flutter/Dart, SharedPreferences (already in pubspec), Material 3 (existing theme).

---

## Task 1: ShoppingItem model

**Files:**
- Create: `lib/models/shopping_item.dart`

**Step 1: Create the file with this exact content**

```dart
import 'dart:convert';

class ShoppingItem {
  final String productName;
  final String store;
  final double price;
  final String? unitPrice;
  bool checked;

  ShoppingItem({
    required this.productName,
    required this.store,
    required this.price,
    this.unitPrice,
    this.checked = false,
  });

  factory ShoppingItem.fromJson(Map<String, dynamic> json) => ShoppingItem(
        productName: json['productName'] as String? ?? '',
        store: json['store'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        unitPrice: json['unitPrice'] as String?,
        checked: json['checked'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'productName': productName,
        'store': store,
        'price': price,
        if (unitPrice != null) 'unitPrice': unitPrice,
        'checked': checked,
      };
}
```

**Step 2: Verify**

Run `flutter analyze lib/models/shopping_item.dart` — expect zero issues.

---

## Task 2: ShoppingListService

**Files:**
- Create: `lib/services/shopping_list_service.dart`

**Step 1: Create the file**

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/shopping_item.dart';

class ShoppingListService {
  static const _key = 'shopping_list';

  Future<List<ShoppingItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list.map((e) => ShoppingItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<ShoppingItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, json.encode(items.map((e) => e.toJson()).toList()));
  }
}
```

**Step 2: Verify**

Run `flutter analyze lib/services/shopping_list_service.dart` — expect zero issues.

---

## Task 3: ShoppingListScreen

**Files:**
- Create: `lib/screens/shopping_list_screen.dart`

**Step 1: Create the file**

```dart
import 'package:flutter/material.dart';
import '../models/shopping_item.dart';
import '../utils/formatters.dart';

class ShoppingListScreen extends StatelessWidget {
  final List<ShoppingItem> items;
  final ValueChanged<ShoppingItem> onToggleChecked;
  final ValueChanged<ShoppingItem> onRemove;
  final VoidCallback onClearChecked;

  const ShoppingListScreen({
    super.key,
    required this.items,
    required this.onToggleChecked,
    required this.onRemove,
    required this.onClearChecked,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(context),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_basket_outlined, size: 48, color: Color(0xFFCBD5E1)),
                SizedBox(height: 16),
                Text(
                  'Lista vazia.\nAdiciona produtos nas Categorias.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Group by store, unchecked first within each group
    final Map<String, List<ShoppingItem>> byStore = {};
    for (final item in items) {
      byStore.putIfAbsent(item.store, () => []).add(item);
    }
    // Sort stores by number of unchecked items descending
    final stores = byStore.keys.toList()
      ..sort((a, b) {
        final aUnchecked = byStore[a]!.where((i) => !i.checked).length;
        final bUnchecked = byStore[b]!.where((i) => !i.checked).length;
        return bUnchecked.compareTo(aUnchecked);
      });

    final uncheckedTotal = items.where((i) => !i.checked).fold(0.0, (s, i) => s + i.price);
    final hasChecked = items.any((i) => i.checked);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // Summary bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.shopping_basket, size: 16, color: Colors.green.shade400),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${items.where((i) => !i.checked).length} por comprar · ${formatCurrency(uncheckedTotal)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  ),
                ),
                if (hasChecked)
                  TextButton.icon(
                    onPressed: onClearChecked,
                    icon: const Icon(Icons.delete_sweep, size: 16),
                    label: const Text('Limpar comprados'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF94A3B8),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          // List grouped by store
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: stores.length,
              itemBuilder: (_, i) => _buildStoreSection(stores[i], byStore[stores[i]]!),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) => AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lista de Compras',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
            ),
            Text(
              'SUPERMERCADOS',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8), letterSpacing: 1.2),
            ),
          ],
        ),
      );

  Widget _buildStoreSection(String store, List<ShoppingItem> storeItems) {
    final unchecked = storeItems.where((i) => !i.checked).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  store.toUpperCase(),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF3B82F6), letterSpacing: 1.1),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$unchecked por comprar',
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
        ),
        ...storeItems.map((item) => _buildItemRow(item)),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildItemRow(ShoppingItem item) {
    return Dismissible(
      key: Key('${item.productName}_${item.store}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 22),
      ),
      onDismissed: (_) => onRemove(item),
      child: GestureDetector(
        onTap: () => onToggleChecked(item),
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: item.checked ? const Color(0xFFF8FAFC) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: item.checked ? const Color(0xFFF1F5F9) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Icon(
                item.checked ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 20,
                color: item.checked ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: item.checked ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
                    decoration: item.checked ? TextDecoration.lineThrough : null,
                    decorationColor: const Color(0xFF94A3B8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatCurrency(item.price),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: item.checked ? const Color(0xFFCBD5E1) : const Color(0xFF10B981),
                  decoration: item.checked ? TextDecoration.lineThrough : null,
                  decorationColor: const Color(0xFFCBD5E1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Verify**

Run `flutter analyze lib/screens/shopping_list_screen.dart` — expect zero issues.

---

## Task 4: Wire shopping list into main.dart

**Files:**
- Modify: `lib/main.dart`

**Step 1: Add imports at the top (after existing imports)**

Add these two lines after the `favorites_service.dart` import:

```dart
import 'models/shopping_item.dart';
import 'services/shopping_list_service.dart';
import 'screens/shopping_list_screen.dart';
```

**Step 2: Add service + state fields to `_AppHomeState`**

After `final _favoritesService = FavoritesService();`, add:

```dart
final _shoppingListService = ShoppingListService();
```

After `List<String> _favorites = [];`, add:

```dart
List<ShoppingItem> _shoppingList = [];
```

**Step 3: Load shopping list in `_loadAll`**

Change the `Future.wait` call to also load the shopping list:

```dart
final results = await Future.wait([
  _settingsService.load(),
  _groceryService.load(),
  _favoritesService.load(),
  _shoppingListService.load(),
]);
setState(() {
  _settings = results[0] as AppSettings;
  _groceryData = results[1] as GroceryData;
  _favorites = results[2] as List<String>;
  _shoppingList = results[3] as List<ShoppingItem>;
  _loaded = true;
});
```

**Step 4: Add shopping list mutation methods**

After the `_saveFavorites` method, add:

```dart
void _addToShoppingList(ShoppingItem item) {
  // Prevent exact duplicates (same name + store)
  final exists = _shoppingList.any(
    (e) => e.productName == item.productName && e.store == item.store,
  );
  if (exists) return;
  final updated = [..._shoppingList, item];
  setState(() => _shoppingList = updated);
  _shoppingListService.save(updated);
}

void _toggleShoppingItem(ShoppingItem item) {
  final updated = _shoppingList.map((e) {
    if (e.productName == item.productName && e.store == item.store) {
      return ShoppingItem(
        productName: e.productName,
        store: e.store,
        price: e.price,
        unitPrice: e.unitPrice,
        checked: !e.checked,
      );
    }
    return e;
  }).toList();
  setState(() => _shoppingList = updated);
  _shoppingListService.save(updated);
}

void _removeShoppingItem(ShoppingItem item) {
  final updated = _shoppingList
      .where((e) => !(e.productName == item.productName && e.store == item.store))
      .toList();
  setState(() => _shoppingList = updated);
  _shoppingListService.save(updated);
}

void _clearCheckedItems() {
  final updated = _shoppingList.where((e) => !e.checked).toList();
  setState(() => _shoppingList = updated);
  _shoppingListService.save(updated);
}
```

**Step 5: Add ShoppingListScreen to the screens list**

Change the `screens` list from 2 items to 3:

```dart
final screens = [
  DashboardScreen(
    settings: _settings,
    summary: summary,
    onOpenSettings: () {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SettingsScreen(
            settings: _settings,
            onSave: _saveSettings,
            favorites: _favorites,
            onSaveFavorites: _saveFavorites,
          ),
        ),
      );
    },
  ),
  GroceryScreen(
    groceryData: _groceryData,
    favorites: _favorites,
    onFavoritesChanged: _saveFavorites,
    onAddToShoppingList: _addToShoppingList,
  ),
  ShoppingListScreen(
    items: _shoppingList,
    onToggleChecked: _toggleShoppingItem,
    onRemove: _removeShoppingItem,
    onClearChecked: _clearCheckedItems,
  ),
];
```

**Step 6: Add "Lista" navigation destination with badge**

Replace the `NavigationBar` destinations:

```dart
bottomNavigationBar: NavigationBar(
  selectedIndex: _currentIndex,
  onDestinationSelected: (i) => setState(() => _currentIndex = i),
  backgroundColor: Colors.white,
  indicatorColor: const Color(0xFFDBEAFE),
  height: 64,
  destinations: [
    const NavigationDestination(
      icon: Icon(Icons.dashboard_outlined),
      selectedIcon: Icon(Icons.dashboard, color: Color(0xFF3B82F6)),
      label: 'Orcamento',
    ),
    const NavigationDestination(
      icon: Icon(Icons.shopping_cart_outlined),
      selectedIcon: Icon(Icons.shopping_cart, color: Color(0xFF3B82F6)),
      label: 'Supermercados',
    ),
    NavigationDestination(
      icon: Badge(
        isLabelVisible: _shoppingList.any((i) => !i.checked),
        label: Text(
          '${_shoppingList.where((i) => !i.checked).length}',
          style: const TextStyle(fontSize: 10),
        ),
        child: const Icon(Icons.shopping_basket_outlined),
      ),
      selectedIcon: Badge(
        isLabelVisible: _shoppingList.any((i) => !i.checked),
        label: Text(
          '${_shoppingList.where((i) => !i.checked).length}',
          style: const TextStyle(fontSize: 10),
        ),
        child: const Icon(Icons.shopping_basket, color: Color(0xFF3B82F6)),
      ),
      label: 'Lista',
    ),
  ],
),
```

**Step 7: Verify**

Run `flutter analyze lib/main.dart` — expect zero issues.

---

## Task 5: Expand category cards with product rows + add button

**Files:**
- Modify: `lib/screens/grocery_screen.dart`

**Step 1: Add `onAddToShoppingList` param to `GroceryScreen`**

In the `GroceryScreen` widget class, add the field alongside `favorites`:

```dart
final ValueChanged<ShoppingItem>? onAddToShoppingList;
```

Add to the constructor:

```dart
this.onAddToShoppingList,
```

(optional — screens that don't use it don't need to pass it)

**Step 2: Add `ShoppingItem` import at the top of the file**

```dart
import '../models/shopping_item.dart';
```

**Step 3: Add `_expandedCategories` state**

In `_GroceryScreenState`, add after `_showFavoritesOnly`:

```dart
final Set<String> _expandedCategories = {};
```

**Step 4: Replace `_buildCategoryCard` with the expanded version**

Find the existing `_buildCategoryCard` method and replace it entirely:

```dart
Widget _buildCategoryCard(CategorySummary category) {
  final storeEntries = category.stores.entries.toList()
    ..sort((a, b) => a.value.avgPrice.compareTo(b.value.avgPrice));
  final isExpanded = _expandedCategories.contains(category.category);

  // Individual products for this category
  final categoryProducts = widget.groceryData.products
      .where((p) => p.category == category.category)
      .toList()
    ..sort((a, b) => a.price.compareTo(b.price));

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFF1F5F9)),
    ),
    child: Column(
      children: [
        // Header row (always visible)
        InkWell(
          onTap: () => setState(() {
            if (isExpanded) {
              _expandedCategories.remove(category.category);
            } else {
              _expandedCategories.add(category.category);
            }
          }),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_categoryIcon(category.category), size: 18, color: const Color(0xFF3B82F6)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.category,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                          ),
                          Text(
                            'Mais barato: ${category.cheapestStore}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: const Color(0xFF94A3B8),
                      size: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                ...storeEntries.map((entry) {
                  final isCheapest = entry.key == category.cheapestStore;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isCheapest ? FontWeight.w600 : FontWeight.w400,
                              color: isCheapest ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: storeEntries.isNotEmpty && storeEntries.last.value.avgPrice > 0
                                  ? entry.value.avgPrice / storeEntries.last.value.avgPrice
                                  : 0,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation(
                                isCheapest ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          formatCurrency(entry.value.avgPrice),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isCheapest ? const Color(0xFF10B981) : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${storeEntries.fold<int>(0, (sum, e) => sum + e.value.productCount)} produtos analisados',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Expanded product list
        if (isExpanded) ...[
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          if (categoryProducts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Sem produtos individuais disponíveis.',
                style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
              ),
            )
          else
            ...categoryProducts.map((product) => _buildProductRow(product)),
        ],
      ],
    ),
  );
}

Widget _buildProductRow(GroceryProduct product) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: Color(0xFFF8FAFC))),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            product.store,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            product.name,
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          formatCurrency(product.price),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
        ),
        const SizedBox(width: 4),
        if (widget.onAddToShoppingList != null)
          GestureDetector(
            onTap: () {
              widget.onAddToShoppingList!(ShoppingItem(
                productName: product.name,
                store: product.store,
                price: product.price,
                unitPrice: product.unitPrice,
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} adicionado à lista'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, size: 16, color: Color(0xFF3B82F6)),
            ),
          ),
      ],
    ),
  );
}
```

**Step 5: Verify**

Run `flutter analyze lib/screens/grocery_screen.dart` — expect zero issues.

---

## Task 6: Build, install, and smoke-test

**Step 1: Build debug APK**

```bash
cd monthy_budget_flutter
flutter build apk --debug
```

Expected: `✓ Built build\app\outputs\flutter-apk\app-debug.apk`

**Step 2: Install on device/emulator**

```bash
# via ADB
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

**Step 3: Smoke-test checklist**

- [ ] Bottom nav shows 3 items: Orcamento, Supermercados, Lista
- [ ] Lista tab opens with empty state message
- [ ] Supermercados → Categorias → tap a category card → expands to show individual products with `+` button
- [ ] Tap `+` → snackbar appears, badge on Lista nav updates
- [ ] Navigate to Lista → item shown under correct store section
- [ ] Tap item row → checked off (strikethrough)
- [ ] "Limpar comprados" removes checked items
- [ ] Swipe left on item → deleted
- [ ] Kill and reopen app → list persists

**Step 4: Commit**

```bash
git add lib/models/shopping_item.dart \
        lib/services/shopping_list_service.dart \
        lib/screens/shopping_list_screen.dart \
        lib/main.dart \
        lib/screens/grocery_screen.dart
git commit -m "claude/budget-calculator-app-TFWgZ: add shopping list with category product expansion"
```
