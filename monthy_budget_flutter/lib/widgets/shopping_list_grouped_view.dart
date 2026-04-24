import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/shopping_item.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../utils/shopping_grouping.dart';
import 'package:monthly_management/widgets/calm/calm.dart';

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
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
      itemCount: widget.groups.length,
      itemBuilder: (_, i) {
        final group = widget.groups[i];
        final isCollapsed = _collapsed.contains(group.label);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CalmCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGroupHeader(context, group, isCollapsed, l10n),
                if (!isCollapsed) ...[
                  Divider(color: AppColors.line(context), height: 1),
                  ...group.items.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final item = entry.value;
                    return Column(
                      children: [
                        if (idx > 0)
                          Divider(color: AppColors.line(context), height: 1),
                        _buildItemTile(context, item, l10n),
                      ],
                    );
                  }),
                ],
              ],
            ),
          ),
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
      borderRadius: isCollapsed
          ? BorderRadius.circular(20)
          : const BorderRadius.vertical(top: Radius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.accent(context)),
            const SizedBox(width: 8),
            Expanded(
              child: CalmEyebrow(group.label),
            ),
            Text(
              l10n.shoppingGroupCount(group.items.length),
              style: TextStyle(
                fontSize: 11,
                color: AppColors.ink50(context),
              ),
            ),
            const SizedBox(width: 6),
            if (group.totalPrice > 0)
              Text(
                formatCurrency(group.totalPrice),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ok(context),
                ),
              ),
            const SizedBox(width: 6),
            Icon(
              isCollapsed ? Icons.expand_more : Icons.expand_less,
              size: 18,
              color: AppColors.ink50(context),
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
        decoration: BoxDecoration(
          color: AppColors.bad(context).withValues(alpha: 0.12),
        ),
        child: Icon(Icons.delete_outline,
            color: AppColors.bad(context), size: 22),
      ),
      onDismissed: (_) => widget.onRemove(item),
      child: InkWell(
        onTap: () => widget.onToggleChecked(item),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                item.checked
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                size: 20,
                color: item.checked
                    ? AppColors.ok(context)
                    : AppColors.ink20(context),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: item.checked
                            ? AppColors.ink50(context)
                            : AppColors.ink(context),
                        decoration: item.checked
                            ? TextDecoration.lineThrough
                            : null,
                        decorationColor: AppColors.ink50(context),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.quantity != null && item.unit != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '${_formatQuantity(item.quantity!)} ${item.unit!}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.ink50(context),
                          ),
                        ),
                      ),
                    if (item.pendingSync)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Icon(Icons.sync,
                                size: 12, color: AppColors.warn(context)),
                            const SizedBox(width: 4),
                            Text(
                              l10n.shoppingPendingSync,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warn(context),
                              ),
                            ),
                          ],
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
                            color: AppColors.ink70(context),
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
                        ? AppColors.ink50(context)
                        : AppColors.ok(context),
                    decoration:
                        item.checked ? TextDecoration.lineThrough : null,
                    decorationColor: AppColors.ink50(context),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatQuantity(double q) {
    return q == q.roundToDouble() ? q.toInt().toString() : q.toStringAsFixed(2);
  }
}
