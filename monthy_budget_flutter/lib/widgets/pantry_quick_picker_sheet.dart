import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/meal_planner.dart';
import '../theme/app_colors.dart';

/// Bottom sheet for quickly adding/removing ingredients to the weekly pantry
/// or staple list.
class PantryQuickPickerSheet extends StatefulWidget {
  final List<Ingredient> availableIngredients;
  final Set<String> stapleIds;
  final Set<String> weeklyIds;
  final ValueChanged<Set<String>> onStaplesChanged;
  final ValueChanged<Set<String>> onWeeklyChanged;

  const PantryQuickPickerSheet({
    super.key,
    required this.availableIngredients,
    required this.stapleIds,
    required this.weeklyIds,
    required this.onStaplesChanged,
    required this.onWeeklyChanged,
  });

  @override
  State<PantryQuickPickerSheet> createState() => _PantryQuickPickerSheetState();
}

class _PantryQuickPickerSheetState extends State<PantryQuickPickerSheet>
    with SingleTickerProviderStateMixin {
  late Set<String> _staples;
  late Set<String> _weekly;
  String _search = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _staples = Set<String>.from(widget.stapleIds);
    _weekly = Set<String>.from(widget.weeklyIds);
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Ingredient> get _filtered {
    if (_search.isEmpty) return widget.availableIngredients;
    final q = _search.toLowerCase();
    return widget.availableIngredients
        .where((i) => i.name.toLowerCase().contains(q))
        .toList();
  }

  void _toggleStaple(String id) {
    setState(() {
      if (_staples.contains(id)) {
        _staples.remove(id);
      } else {
        _staples.add(id);
      }
    });
    widget.onStaplesChanged(_staples);
  }

  void _toggleWeekly(String id) {
    setState(() {
      if (_weekly.contains(id)) {
        _weekly.remove(id);
      } else {
        _weekly.add(id);
      }
    });
    widget.onWeeklyChanged(_weekly);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final filtered = _filtered;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) => Column(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.borderMuted(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              l10n.pantryPickerTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: l10n.pantrySearchHint,
                hintStyle: TextStyle(
                    color: AppColors.textMuted(context), fontSize: 14),
                prefixIcon: Icon(Icons.search,
                    color: AppColors.textMuted(context), size: 20),
                filled: true,
                fillColor: AppColors.background(context),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border(context)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border(context)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColors.primary(context), width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TabBar(
            controller: _tabController,
            labelColor: AppColors.primary(context),
            unselectedLabelColor: AppColors.textMuted(context),
            indicatorColor: AppColors.primary(context),
            tabs: [
              Tab(text: l10n.pantryTabAlwaysHave),
              Tab(text: l10n.pantryTabThisWeek),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(filtered, _staples, _toggleStaple, scrollController),
                _buildList(filtered, _weekly, _toggleWeekly, scrollController),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(
    List<Ingredient> items,
    Set<String> selected,
    ValueChanged<String> onToggle,
    ScrollController controller,
  ) {
    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        final isSelected = selected.contains(item.id);
        return Material(
          color: isSelected
              ? AppColors.successBackground(context)
              : AppColors.surface(context),
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: () => onToggle(item.id),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? AppColors.success(context)
                      : AppColors.border(context),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isSelected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: isSelected
                        ? AppColors.success(context)
                        : AppColors.borderMuted(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
