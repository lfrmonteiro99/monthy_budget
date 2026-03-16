import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/pantry_item.dart';
import '../models/meal_planner.dart';
import '../theme/app_colors.dart';

class PantryManagerSheet extends StatefulWidget {
  final List<PantryItem> pantryItems;
  final Map<String, Ingredient> ingredientMap;
  final ValueChanged<List<PantryItem>> onSave;

  const PantryManagerSheet({
    super.key,
    required this.pantryItems,
    required this.ingredientMap,
    required this.onSave,
  });

  @override
  State<PantryManagerSheet> createState() => _PantryManagerSheetState();
}

class _PantryManagerSheetState extends State<PantryManagerSheet> {
  late List<PantryItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.pantryItems);
  }

  Color _statusColor(PantryItem item) {
    if (item.isDepleted) return AppColors.error(context);
    if (item.isLow) return AppColors.warning(context);
    return AppColors.success(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.kitchen,
                      color: AppColors.textSecondary(context)),
                  const SizedBox(width: 8),
                  Text(
                    l10n.pantryManagerTitle,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      widget.onSave(_items);
                      Navigator.pop(context);
                    },
                    child: Text(l10n.pantryManagerSave),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  final ingredient =
                      widget.ingredientMap[item.ingredientId];
                  final name = ingredient?.name ?? item.ingredientId;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          _statusColor(item).withValues(alpha: 0.15),
                      radius: 16,
                      child: Icon(Icons.circle,
                          size: 12, color: _statusColor(item)),
                    ),
                    title:
                        Text(name, style: const TextStyle(fontSize: 14)),
                    subtitle: Text('${item.quantity} ${item.unit}',
                        style: const TextStyle(fontSize: 12)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              size: 20),
                          onPressed: () {
                            setState(() {
                              _items[index] = item.copyWith(
                                quantity: (item.quantity -
                                        (ingredient?.minPurchaseQty ??
                                            0.1))
                                    .clamp(0, double.infinity),
                              );
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline,
                              size: 20),
                          onPressed: () {
                            setState(() {
                              _items[index] = item.copyWith(
                                quantity: item.quantity +
                                    (ingredient?.minPurchaseQty ?? 0.1),
                                lastRestocked: DateTime.now(),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
