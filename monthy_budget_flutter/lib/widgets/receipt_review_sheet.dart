import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/parsed_receipt.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';

/// Post-scan review sheet: user verifies extracted data and picks a category
/// before creating the expense.
class ReceiptReviewSheet extends StatefulWidget {
  final ParsedReceipt receipt;
  final List<String> categories;

  const ReceiptReviewSheet({
    super.key,
    required this.receipt,
    required this.categories,
  });

  /// Shows the review sheet and returns the chosen category, or null if dismissed.
  static Future<String?> show(
    BuildContext context, {
    required ParsedReceipt receipt,
    required List<String> categories,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReceiptReviewSheet(
        receipt: receipt,
        categories: categories,
      ),
    );
  }

  @override
  State<ReceiptReviewSheet> createState() => _ReceiptReviewSheetState();
}

class _ReceiptReviewSheetState extends State<ReceiptReviewSheet> {
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedCategory =
        widget.categories.isNotEmpty ? widget.categories.first : '';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final receipt = widget.receipt;
    final merchantLabel =
        receipt.merchantName ?? (receipt.merchantNif.isNotEmpty ? 'NIF ${receipt.merchantNif}' : l10n.receiptMerchantUnknown);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.borderMuted(context),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Text(
                l10n.receiptReviewTitle,
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              // Merchant
              _buildRow(
                context,
                label: l10n.receiptReviewMerchant,
                value: merchantLabel,
                icon: Icons.store_outlined,
              ),
              const SizedBox(height: 10),
              // Date
              _buildRow(
                context,
                label: l10n.receiptReviewDate,
                value: DateFormat.yMd().format(receipt.date),
                icon: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 10),
              // Total
              _buildRow(
                context,
                label: l10n.receiptReviewTotal,
                value: formatCurrency(receipt.totalAmount),
                icon: Icons.receipt_long_outlined,
                valueBold: true,
              ),
              const SizedBox(height: 10),
              // Items count
              if (receipt.hasLineItems)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildRow(
                    context,
                    label: l10n.receiptReviewItems(receipt.lineItems.length),
                    value: formatCurrency(receipt.itemsTotal),
                    icon: Icons.list_alt_outlined,
                  ),
                ),
              // Category picker
              Text(
                l10n.receiptReviewCategory,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary(context),
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory.isNotEmpty ? _selectedCategory : null,
                decoration: InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.border(context)),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: widget.categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategory = v);
                },
              ),
              const SizedBox(height: 20),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(l10n.receiptReviewRetake),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: _selectedCategory.isNotEmpty
                          ? () =>
                              Navigator.of(context).pop(_selectedCategory)
                          : null,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: AppColors.primary(context),
                        foregroundColor: AppColors.onPrimary(context),
                      ),
                      child: Text(l10n.receiptReviewConfirm),
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

  Widget _buildRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    bool valueBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted(context)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: valueBold ? FontWeight.w700 : FontWeight.w500,
            color: valueBold
                ? AppColors.success(context)
                : AppColors.textPrimary(context),
          ),
        ),
      ],
    );
  }
}
