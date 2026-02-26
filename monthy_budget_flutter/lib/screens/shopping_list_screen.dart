import 'package:flutter/material.dart';
import '../models/shopping_item.dart';
import '../models/purchase_record.dart';
import '../utils/formatters.dart';

class ShoppingListScreen extends StatefulWidget {
  final List<ShoppingItem> items;
  final ValueChanged<ShoppingItem> onToggleChecked;
  final ValueChanged<ShoppingItem> onRemove;
  final VoidCallback onClearChecked;
  final void Function(double? amount, List<ShoppingItem> checkedItems)
      onFinalize;
  final PurchaseHistory purchaseHistory;

  const ShoppingListScreen({
    super.key,
    required this.items,
    required this.onToggleChecked,
    required this.onRemove,
    required this.onClearChecked,
    required this.onFinalize,
    required this.purchaseHistory,
  });

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  void _showFinalizeSheet() {
    final checkedItems = widget.items.where((i) => i.checked).toList();
    final controller = TextEditingController();
    final estimatedTotal = checkedItems.fold(0.0, (s, i) => s + i.price);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                'Finalizar Compra',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: checkedItems.length,
                itemBuilder: (_, i) {
                  final item = checkedItems[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            size: 16, color: Color(0xFF10B981)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(item.productName,
                              style: const TextStyle(fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (item.price > 0)
                          Text(
                            formatCurrency(item.price),
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF10B981)),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 24, indent: 20, endIndent: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (estimatedTotal > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total estimado',
                              style: TextStyle(
                                  fontSize: 13, color: Color(0xFF64748B))),
                          Text(formatCurrency(estimatedTotal),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B))),
                        ],
                      ),
                    ),
                  const Text(
                    'QUANTO GASTEI NO TOTAL? (opcional)',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      suffixText: 'EUR',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(
                            color: Color(0xFF3B82F6), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final raw = controller.text.trim();
                        final amount = raw.isNotEmpty
                            ? double.tryParse(raw.replaceAll(',', '.'))
                            : null;
                        Navigator.pop(ctx);
                        widget.onFinalize(amount, checkedItems);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Confirmar'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasChecked = widget.items.any((i) => i.checked);
    final uncheckedTotal =
        widget.items.where((i) => !i.checked).fold(0.0, (s, i) => s + i.price);

    if (widget.items.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: _buildAppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_basket_outlined,
                    size: 56, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                const Text(
                  'Lista vazia',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Adiciona produtos a partir do\necrã Supermercado.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.shopping_basket,
                    size: 16, color: Colors.green.shade400),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.items.where((i) => !i.checked).length} por comprar · ${formatCurrency(uncheckedTotal)}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B)),
                  ),
                ),
                if (hasChecked)
                  TextButton.icon(
                    onPressed: widget.onClearChecked,
                    icon: const Icon(Icons.delete_sweep, size: 16),
                    label: const Text('Limpar'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF94A3B8),
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: widget.items.length,
              itemBuilder: (_, i) => _buildItemRow(widget.items[i]),
            ),
          ),
        ],
      ),
      floatingActionButton: hasChecked
          ? FloatingActionButton.extended(
              onPressed: _showFinalizeSheet,
              backgroundColor: const Color(0xFF10B981),
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: const Text(
                'Finalizar Compra',
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            )
          : null,
    );
  }

  AppBar _buildAppBar() => AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Lista de Compras',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B)),
        ),
        actions: [
          if (widget.purchaseHistory.records.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.receipt_long_outlined,
                  color: Color(0xFF64748B)),
              tooltip: 'Histórico de compras',
              onPressed: _showHistory,
            ),
        ],
      );

  void _showHistory() {
    final expandedMap = <int, bool>{};
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => StatefulBuilder(
          builder: (ctx, setLocalState) => Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Histórico de Compras',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  itemCount: widget.purchaseHistory.records.length,
                  itemBuilder: (_, i) {
                    final r = widget.purchaseHistory.records[i];
                    final isExpanded = expandedMap[i] ?? false;
                    return Material(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                      onTap: () =>
                          setLocalState(() => expandedMap[i] = !isExpanded),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${r.date.day}/${r.date.month}/${r.date.year}',
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF475569)),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      formatCurrency(r.amount),
                                      style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1E293B)),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      isExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      size: 18,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (!isExpanded)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${r.itemCount} produto${r.itemCount != 1 ? 's' : ''}',
                                  style: const TextStyle(
                                      fontSize: 12, color: Color(0xFF94A3B8)),
                                ),
                              ),
                            if (isExpanded && r.items.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              ...r.items.map((name) => Padding(
                                    padding: const EdgeInsets.only(bottom: 3),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.circle,
                                            size: 4, color: Color(0xFF94A3B8)),
                                        const SizedBox(width: 8),
                                        Text(name,
                                            style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFF475569))),
                                      ],
                                    ),
                                  )),
                            ],
                          ],
                        ),
                      ),
                    ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemRow(ShoppingItem item) {
    return Dismissible(
      key: Key(item.id.isNotEmpty
          ? item.id
          : '${item.productName}_${item.store}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(12),
        ),
        child:
            const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 22),
      ),
      onDismissed: (_) => widget.onRemove(item),
      child: Semantics(
        button: true,
        label: '${item.productName}${item.checked ? ", comprado" : ""}, deslizar para remover',
        child: Material(
        color: item.checked ? const Color(0xFFF8FAFC) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
        onTap: () => widget.onToggleChecked(item),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: item.checked
                  ? const Color(0xFFF1F5F9)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Icon(
                item.checked
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                size: 20,
                color: item.checked
                    ? const Color(0xFF10B981)
                    : const Color(0xFFCBD5E1),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: item.checked
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF1E293B),
                    decoration:
                        item.checked ? TextDecoration.lineThrough : null,
                    decorationColor: const Color(0xFF94A3B8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (item.price > 0)
                Text(
                  formatCurrency(item.price),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: item.checked
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF10B981),
                    decoration:
                        item.checked ? TextDecoration.lineThrough : null,
                    decorationColor: const Color(0xFFCBD5E1),
                  ),
                ),
            ],
          ),
        ),
      ),
      ),
      ),
    );
  }
}
