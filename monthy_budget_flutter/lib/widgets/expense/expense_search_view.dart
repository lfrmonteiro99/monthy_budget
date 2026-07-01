import 'package:flutter/material.dart';
import 'package:monthly_management/widgets/calm/calm.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/actual_expense.dart';
import '../../models/custom_category.dart';
import '../../theme/app_colors.dart';
import '../../utils/category_helpers.dart';
import '../../utils/expense_category_format.dart';
import '../../widgets/info_icon_button.dart';
import 'search_result_tile.dart';

/// Full-screen search/filter mode for the expense tracker. Stateless — all
/// state lives in the parent screen and is passed in; mutations come back via
/// callbacks so behaviour matches the previous inline implementation exactly.
class ExpenseSearchView extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final bool loadingHistory;
  final List<ActualExpense> searchResults;
  final Set<String> selectedCategories;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final List<String> allCategories;
  final List<CustomCategory> customCategories;
  final S l10n;

  final VoidCallback onBack;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final ValueChanged<String> onToggleCategory;
  final VoidCallback onPickDateRange;
  final VoidCallback onClearDates;
  final Future<void> Function(ActualExpense) onShowDetail;

  const ExpenseSearchView({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.loadingHistory,
    required this.searchResults,
    required this.selectedCategories,
    required this.dateFrom,
    required this.dateTo,
    required this.allCategories,
    required this.customCategories,
    required this.l10n,
    required this.onBack,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.onToggleCategory,
    required this.onPickDateRange,
    required this.onClearDates,
    required this.onShowDetail,
  });

  @override
  Widget build(BuildContext context) {
    return CalmScaffold(
      body: Column(
        children: [
          // Search bar row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.ink(context)),
                  onPressed: onBack,
                ),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: l10n.searchExpensesHint,
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: AppColors.ink50(context),
                        fontSize: 16,
                      ),
                    ),
                    style: TextStyle(
                      color: AppColors.ink(context),
                      fontSize: 16,
                    ),
                    onChanged: onQueryChanged,
                  ),
                ),
                if (searchQuery.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.clear, color: AppColors.ink50(context)),
                    onPressed: onClearQuery,
                  ),
              ],
            ),
          ),

          if (loadingHistory)
            Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent(context),
                ),
              ),
            )
          else
            Expanded(
              child: Column(
                children: [
                  // Category chips + date range filter
                  Row(
                    children: [
                      Expanded(child: _buildFilterBar(context)),
                      InfoIconButton(
                        title: l10n.filter,
                        body: l10n.infoExpenseTrackerFilter,
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),

                  Divider(color: AppColors.line(context), height: 1),

                  // Result count + eyebrow
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                    child: Row(
                      children: [
                        CalmEyebrow(l10n.expenseSearchResultsEyebrow),
                        const SizedBox(width: 8),
                        Text(
                          l10n.searchResultCount(searchResults.length),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.ink70(context),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Results
                  Expanded(
                    child: searchResults.isEmpty
                        ? Center(
                            child: CalmEmptyState(
                              icon: Icons.search_off,
                              // TODO(l10n): move to ARB (Wave H)
                              title: 'Nada encontrado',
                              body: l10n.searchNoResults,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: searchResults.length,
                            itemBuilder: (_, i) {
                              final expense = searchResults[i];
                              return SearchResultTile(
                                expense: expense,
                                categoryLabel: localizedExpenseCategory(
                                  expense.category,
                                  l10n,
                                ),
                                categoryIcon: categoryIconByName(
                                  expense.category,
                                  customCategories: customCategories,
                                ),
                                categoryColor: categoryColorByNameFull(
                                  expense.category,
                                  customCategories: customCategories,
                                ),
                                onTap: () => onShowDetail(expense),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final categories = allCategories.toList()..sort();

    return CalmCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...categories.map((cat) {
              final selected = selectedCategories.contains(cat);
              final catColor = categoryColorByNameFull(
                cat,
                customCategories: customCategories,
              );
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: FilterChip(
                  label: Text(
                    localizedExpenseCategory(cat, l10n),
                    style: const TextStyle(fontSize: 12),
                  ),
                  selected: selected,
                  onSelected: (_) => onToggleCategory(cat),
                  selectedColor: AppColors.accentSoft(context),
                  checkmarkColor: AppColors.accent(context),
                  side: selected
                      ? BorderSide(color: AppColors.accent(context))
                      : BorderSide(color: AppColors.line(context)),
                  avatar: selected
                      ? null
                      : SizedBox(
                          width: 10,
                          height: 10,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: catColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              );
            }),
            // Date range chip
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ActionChip(
                avatar: Icon(
                  Icons.date_range,
                  size: 16,
                  color: dateFrom != null
                      ? AppColors.accent(context)
                      : AppColors.ink50(context),
                ),
                label: Text(
                  dateFrom != null && dateTo != null
                      ? '${dateFrom!.day}/${dateFrom!.month} - ${dateTo!.day}/${dateTo!.month}'
                      : l10n.searchDateRange,
                  style: TextStyle(
                    fontSize: 12,
                    color: dateFrom != null
                        ? AppColors.accent(context)
                        : AppColors.ink50(context),
                  ),
                ),
                onPressed: onPickDateRange,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            if (dateFrom != null)
              Tooltip(
                message: l10n.shoppingClear,
                child: GestureDetector(
                  onTap: onClearDates,
                  child: Icon(
                    Icons.clear,
                    size: 16,
                    color: AppColors.ink50(context),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
