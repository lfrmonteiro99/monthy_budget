import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/scanned_product_candidate.dart';
import '../models/shopping_item.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import 'calm/calm.dart';

/// Displays the result of a barcode scan.
///
/// If a match was found, shows a confirmation card with product details.
/// If no match, shows a fallback form with manual entry fields pre-filled
/// with the barcode value.
class BarcodeResultCard extends StatefulWidget {
  final ScannedProductCandidate candidate;
  final ValueChanged<ShoppingItem> onAddToList;

  const BarcodeResultCard({
    super.key,
    required this.candidate,
    required this.onAddToList,
  });

  /// Show as a modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required ScannedProductCandidate candidate,
    required ValueChanged<ShoppingItem> onAddToList,
  }) {
    return CalmBottomSheet.show(
      context,
      builder: (_) => BarcodeResultCard(
        candidate: candidate,
        onAddToList: onAddToList,
      ),
    );
  }

  @override
  State<BarcodeResultCard> createState() => _BarcodeResultCardState();
}

class _BarcodeResultCardState extends State<BarcodeResultCard> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.candidate.matchedProduct?.name ?? '',
    );
    _priceController = TextEditingController(
      text: widget.candidate.matchedProduct != null
          ? widget.candidate.matchedProduct!.avgPrice.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    final price =
        double.tryParse(_priceController.text.trim().replaceAll(',', '.')) ??
            0.0;
    widget.onAddToList(ShoppingItem(
      productName: name,
      store: '',
      price: price,
    ));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final hasMatch = widget.candidate.hasMatch;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                color: AppColors.borderMuted(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Text(
              hasMatch
                  ? l10n.barcodeProductFound
                  : l10n.barcodeProductNotFound,
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '${l10n.barcodeLabel}: ${widget.candidate.barcode}',
              style: TextStyle(
                  fontSize: 12, color: AppColors.textMuted(context)),
            ),
          ),
          const SizedBox(height: 16),
          if (hasMatch) _buildMatchedView(context, l10n),
          if (!hasMatch) _buildFallbackView(context, l10n),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(l10n.barcodeAddToList),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchedView(BuildContext context, S l10n) {
    final product = widget.candidate.matchedProduct!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.background(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success(context)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle,
                color: AppColors.success(context), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${product.category} · ${product.unit}',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textMuted(context)),
                  ),
                ],
              ),
            ),
            Text(
              formatCurrency(product.avgPrice),
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success(context)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackView(BuildContext context, S l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.barcodeManualEntry,
            style: TextStyle(
                fontSize: 13, color: AppColors.textSecondary(context)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.barcodeProductName,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.barcodePrice,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
