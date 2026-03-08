import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/meal_planner.dart';
import '../models/meal_settings.dart';
import '../theme/app_colors.dart';

/// Bottom sheet for creating / editing a freeform meal.
///
/// Returns the completed [MealDay] via [Navigator.pop] or null on cancel.
class FreeformMealSheet extends StatefulWidget {
  final int dayIndex;
  final MealType mealType;
  final MealDay? existing; // non-null when editing

  const FreeformMealSheet({
    super.key,
    required this.dayIndex,
    required this.mealType,
    this.existing,
  });

  @override
  State<FreeformMealSheet> createState() => _FreeformMealSheetState();
}

class _FreeformMealSheetState extends State<FreeformMealSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _noteCtrl;
  late final TextEditingController _costCtrl;
  final Set<String> _selectedTags = {};
  final List<FreeformMealItem> _shoppingItems = [];

  static const _availableTags = ['leftovers', 'pantry_meal', 'takeout', 'quick_meal'];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.freeformTitle ?? '');
    _noteCtrl = TextEditingController(text: e?.freeformNote ?? '');
    _costCtrl = TextEditingController(
      text: e?.freeformEstimatedCost != null
          ? e!.freeformEstimatedCost!.toStringAsFixed(2)
          : '',
    );
    _titleCtrl.addListener(_onTitleChanged);
    if (e != null) {
      _selectedTags.addAll(e.freeformTags);
      _shoppingItems.addAll(e.freeformShoppingItems);
    }
  }

  void _onTitleChanged() => setState(() {});

  @override
  void dispose() {
    _titleCtrl.removeListener(_onTitleChanged);
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    _costCtrl.dispose();
    super.dispose();
  }

  void _addShoppingItem() {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final unitCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final storeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        final l10n = S.of(ctx);
        return AlertDialog(
          title: Text(l10n.freeformAddItem),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(labelText: l10n.freeformItemName),
                  autofocus: true,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: qtyCtrl,
                        decoration: InputDecoration(labelText: l10n.freeformItemQuantity),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: unitCtrl,
                        decoration: InputDecoration(labelText: l10n.freeformItemUnit),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        decoration: InputDecoration(labelText: l10n.freeformItemPrice),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: storeCtrl,
                        decoration: InputDecoration(labelText: l10n.freeformItemStore),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(ctx);
                setState(() {
                  _shoppingItems.add(FreeformMealItem(
                    name: name,
                    quantity: double.tryParse(qtyCtrl.text.trim()),
                    unit: unitCtrl.text.trim().isEmpty ? null : unitCtrl.text.trim(),
                    estimatedPrice: double.tryParse(priceCtrl.text.trim()),
                    store: storeCtrl.text.trim().isEmpty ? null : storeCtrl.text.trim(),
                  ));
                });
              },
              child: Text(l10n.save),
            ),
          ],
        );
      },
    );
  }

  void _submit() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    final cost = double.tryParse(_costCtrl.text.trim()) ?? 0.0;
    final meal = MealDay(
      dayIndex: widget.dayIndex,
      mealKind: MealKind.freeform,
      costEstimate: cost,
      mealType: widget.mealType,
      feedback: widget.existing?.feedback ?? MealFeedback.none,
      freeformTitle: title,
      freeformNote: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      freeformEstimatedCost: cost == 0.0 ? null : cost,
      freeformTags: _selectedTags.toList(),
      freeformShoppingItems: _shoppingItems,
    );
    Navigator.pop(context, meal);
  }

  String _tagLabel(String tag, S l10n) {
    switch (tag) {
      case 'leftovers':
        return l10n.freeformTagLeftovers;
      case 'pantry_meal':
        return l10n.freeformTagPantryMeal;
      case 'takeout':
        return l10n.freeformTagTakeout;
      case 'quick_meal':
        return l10n.freeformTagQuickMeal;
      default:
        return tag;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final isEditing = widget.existing != null;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.borderMuted(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    isEditing ? l10n.freeformEditTitle : l10n.freeformCreateTitle,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
                if (isEditing)
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: AppColors.error(context)),
                    onPressed: () => Navigator.pop(context, 'delete'),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                TextField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.freeformTitleLabel,
                    hintText: l10n.freeformTitleHint,
                  ),
                  autofocus: !isEditing,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _noteCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.freeformNoteLabel,
                    hintText: l10n.freeformNoteHint,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _costCtrl,
                  decoration: InputDecoration(
                    labelText: l10n.freeformCostLabel,
                    prefixText: '\u20AC ',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.freeformTagsLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: _availableTags.map((tag) {
                    final selected = _selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(_tagLabel(tag, l10n)),
                      selected: selected,
                      onSelected: (v) => setState(() {
                        if (v) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      }),
                      selectedColor: AppColors.primary(context).withValues(alpha: 0.15),
                      checkmarkColor: AppColors.primary(context),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.freeformShoppingItemsLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _addShoppingItem,
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(l10n.freeformAddItem),
                    ),
                  ],
                ),
                ..._shoppingItems.asMap().entries.map((e) {
                  final item = e.value;
                  final idx = e.key;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    title: Text(item.name, style: const TextStyle(fontSize: 13)),
                    subtitle: item.quantity != null || item.estimatedPrice != null
                        ? Text(
                            [
                              if (item.quantity != null) '${item.quantity}${item.unit != null ? ' ${item.unit}' : ''}',
                              if (item.estimatedPrice != null) '${item.estimatedPrice!.toStringAsFixed(2)}\u20AC',
                              if (item.store != null) item.store,
                            ].join(' - '),
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted(context)),
                          )
                        : null,
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () => setState(() => _shoppingItems.removeAt(idx)),
                    ),
                  );
                }),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _titleCtrl.text.trim().isNotEmpty ? _submit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary(context),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(isEditing ? l10n.save : l10n.freeformCreateTitle),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
