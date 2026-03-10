import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/shopping_item.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../utils/shopping_grouping.dart';

/// Displays shopping items organized in collapsible groups.
class ShoppingListGroupedView extends StatefulWidget {
  final List<ShoppingGroup> groups;
  final ShoppingGroupMode mode;
  final ValueChanged<ShoppingItem> onToggleChecked;
  final ValueChanged<ShoppingItem> onRemove;

  const ShoppingListGroupedView({
    super.key,
    required this.groups,
    required this.mode,
    required this.onToggleChecked,
    required this.onRemove,
  });

  @override
  State<ShoppingListGroupedView> createState() =>
      _ShoppingListGroupedViewState();
}

class _ShoppingListGroupedViewState extends State<ShoppingListGroupedView> {
  final Set<String> _collapsed = {};

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: widget.groups.length,
      itemBuilder: (_, i) {
        final group = widget.groups[i];
        final isCollapsed = _collapsed.contains(group.label);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGroupHeader(context, group, isCollapsed, l10n),
            if (!isCollapsed)
              ...group.items.map((item) => _buildItemTile(context, item, l10n)),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildGroupHeader(
    BuildContext context,
    ShoppingGroup group,
    bool isCollapsed,
    S l10n,
  ) {
    final icon = widget.mode == ShoppingGroupMode.meals
        ? Icons.restaurant_outlined
        : Icons.store_outlined;

    return InkWell(
      onTap: () {
        setState(() {
          if (isCollapsed) {
            _collapsed.remove(group.label);
          } else {
            _collapsed.add(group.label);
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primary(context)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                group.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            Text(
              l10n.shoppingGroupCount(group.items.length),
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted(context),
              ),
            ),
            const SizedBox(width: 4),
            if (group.totalPrice > 0)
              Text(
                formatCurrency(group.totalPrice),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success(context),
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              isCollapsed ? Icons.expand_more : Icons.expand_less,
              size: 18,
              color: AppColors.textMuted(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemTile(BuildContext context, ShoppingItem item, S l10n) {
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
          color: AppColors.errorBackground(context),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete_outline,
            color: AppColors.error(context), size: 22),
      ),
      onDismissed: (_) => widget.onRemove(item),
      child: Material(
        color: item.checked
            ? AppColors.background(context)
            : AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => widget.onToggleChecked(item),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: item.checked
                    ? AppColors.surfaceVariant(context)
                    : AppColors.border(context),
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
                      ? AppColors.success(context)
                      : AppColors.borderMuted(context),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: item.checked
                              ? AppColors.textMuted(context)
                              : AppColors.textPrimary(context),
                          decoration: item.checked
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: AppColors.textMuted(context),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.quantity != null && item.unit != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            '${_formatQuantity(item.quantity!)} ${item.unit!}',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textMuted(context),
                            ),
                          ),
                        ),
                      if (item.cheapestKnownStore != null &&
                          item.cheapestKnownPrice != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            l10n.shoppingCheapestAt(
                              item.cheapestKnownStore!,
                              formatCurrency(item.cheapestKnownPrice!),
                            ),
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.textMuted(context),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
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
                          ? AppColors.borderMuted(context)
                          : AppColors.success(context),
                      decoration:
                          item.checked ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.borderMuted(context),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatQuantity(double q) {
    return q == q.roundToDouble() ? q.toInt().toString() : q.toStringAsFixed(2);
  }
}
