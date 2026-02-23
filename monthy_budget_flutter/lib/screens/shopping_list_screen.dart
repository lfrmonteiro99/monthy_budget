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
