import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;

import '../l10n/generated/app_localizations.dart';
import '../models/actual_expense.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

enum ExpenseDetailAction { edit }

Future<ExpenseDetailAction?> showExpenseDetailSheet({
  required BuildContext context,
  required ActualExpense expense,
  required String categoryLabel,
  required IconData categoryIcon,
  required Color categoryColor,
}) {
  return showModalBottomSheet<ExpenseDetailAction>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ExpenseDetailSheet(
      expense: expense,
      categoryLabel: categoryLabel,
      categoryIcon: categoryIcon,
      categoryColor: categoryColor,
    ),
  );
}

class ExpenseDetailSheet extends StatelessWidget {
  final ActualExpense expense;
  final String categoryLabel;
  final IconData categoryIcon;
  final Color categoryColor;

  const ExpenseDetailSheet({
    super.key,
    required this.expense,
    required this.categoryLabel,
    required this.categoryIcon,
    required this.categoryColor,
  });

  String get _dateLabel =>
      '${expense.date.day.toString().padLeft(2, '0')}/${expense.date.month.toString().padLeft(2, '0')}/${expense.date.year}';

  bool get _hasLocation =>
      expense.locationLat != null && expense.locationLng != null;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final title = expense.description ?? categoryLabel;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border(context),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: categoryColor.withValues(alpha: 0.15),
                    child: Icon(categoryIcon, color: categoryColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                        if (expense.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            categoryLabel,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    formatCurrency(expense.amount),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _DetailStatCard(
                      label: l10n.addExpenseDate,
                      value: _dateLabel,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DetailStatCard(
                      label: l10n.addExpenseCategory,
                      value: categoryLabel,
                    ),
                  ),
                ],
              ),
              if (_hasLocation) ...[
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 200,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: latlong.LatLng(
                          expense.locationLat!,
                          expense.locationLng!,
                        ),
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none,
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.sinmetro.monthybudget',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: latlong.LatLng(
                                expense.locationLat!,
                                expense.locationLng!,
                              ),
                              child: const Icon(
                                Icons.location_pin,
                                color: Colors.red,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (expense.locationAddress != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background(context),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border(context)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: AppColors.textSecondary(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          expense.locationAddress!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary(context),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.close),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () =>
                          Navigator.of(context).pop(ExpenseDetailAction.edit),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: Text(l10n.editExpenseTitle),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailStatCard extends StatelessWidget {
  final String label;
  final String value;

  const _DetailStatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}
