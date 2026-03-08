part of 'main.dart';

/// Shopping list methods for [_AppHomeState].
extension _AppHomeShopping on _AppHomeState {
  void _addToShoppingList(ShoppingItem item) async {
    final exists = _shoppingList.any(
      (e) => e.productName == item.productName,
    );
    if (exists) return;
    await _shoppingListService.add(item, widget.householdId);
  }

  void _toggleShoppingItem(ShoppingItem item) async {
    if (item.id.isEmpty) return;
    // Optimistic: update local state immediately, don't wait for Realtime
    setState(() {
      _shoppingList = _shoppingList.map((i) {
        if (i.id != item.id) return i;
        return ShoppingItem(
          id: i.id,
          productName: i.productName,
          store: i.store,
          price: i.price,
          unitPrice: i.unitPrice,
          checked: !i.checked,
        );
      }).toList();
    });
    try {
      await _shoppingListService.toggle(item.id, !item.checked);
    } catch (_) {
      // Revert on failure — Realtime will correct on next emission anyway
      setState(() {
        _shoppingList = _shoppingList.map((i) {
          if (i.id != item.id) return i;
          return ShoppingItem(
            id: i.id,
            productName: i.productName,
            store: i.store,
            price: i.price,
            unitPrice: i.unitPrice,
            checked: item.checked,
          );
        }).toList();
      });
    }
  }

  void _removeShoppingItem(ShoppingItem item) async {
    if (item.id.isEmpty) return;
    // Dismissible already removes it from view; fire-and-forget
    _shoppingListService.remove(item.id);
  }

  void _clearCheckedItems() async {
    // Optimistic: remove checked items locally immediately
    setState(() {
      _shoppingList = _shoppingList.where((i) => !i.checked).toList();
    });
    await _shoppingListService.clearChecked(widget.householdId);
  }

  Future<void> _finalizeShopping(
      double? amount, List<ShoppingItem> checkedItems, {bool isMealPurchase = false}) async {
    if (checkedItems.isEmpty) return;
    try {
      final estimated = checkedItems.fold(0.0, (s, i) => s + i.price);
      final totalAmount =
          (amount != null && amount > 0) ? amount : estimated;
      final record = PurchaseRecord(
        id: 'purchase_${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now(),
        amount: totalAmount,
        itemCount: checkedItems.length,
        items: checkedItems.map((i) => i.productName).toList(),
        isMealPurchase: isMealPurchase,
      );
      await _purchaseHistoryService.saveRecord(record, widget.householdId);
      await _shoppingListService.clearChecked(widget.householdId);
      final updated =
          PurchaseHistory(records: [record, ..._purchaseHistory.records]);
      if (mounted) {
        setState(() {
          _purchaseHistory = updated;
          _shoppingList = _shoppingList.where((i) => !i.checked).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao guardar compra: $e'),
            backgroundColor: AppColors.error(context),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
