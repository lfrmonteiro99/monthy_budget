import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/app_colors.dart';
import '../models/app_settings.dart';
import '../models/actual_expense.dart';
import '../l10n/generated/app_localizations.dart';

/// Screen that scans a QR code from a receipt and creates an ActualExpense.
///
/// Portuguese receipts (ATCUD format) typically encode:
///   - NIF (tax number)
///   - Total amount
///   - Date
///   - ATCUD code
///
/// The screen extracts what it can and lets the user confirm/edit before saving.
class QrScannerScreen extends StatefulWidget {
  final List<ExpenseItem> budgetExpenses;

  const QrScannerScreen({super.key, required this.budgetExpenses});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _cameraController = MobileScannerController();
  bool _hasScanned = false;

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() => _hasScanned = true);
    _cameraController.stop();

    final raw = barcode.rawValue!;
    final parsed = _parseQrData(raw);

    _showConfirmSheet(parsed, raw);
  }

  /// Try to extract amount from QR data.
  /// Portuguese invoice QR codes use key-value pairs separated by '*',
  /// e.g. "A:123456789*B:999999990*...*N:12.50*O:1.44*Q:ABCD*R:1234"
  /// where N = net total, O = VAT total.
  _QrParsedData _parseQrData(String raw) {
    double? amount;
    String? description;
    DateTime? date;

    // Try Portuguese tax QR format (field separator: *)
    if (raw.contains('*')) {
      final fields = <String, String>{};
      for (final part in raw.split('*')) {
        final colonIdx = part.indexOf(':');
        if (colonIdx > 0) {
          fields[part.substring(0, colonIdx)] = part.substring(colonIdx + 1);
        }
      }

      // N = base taxável (net), O = IVA, total = N + O
      final netStr = fields['N'];
      final vatStr = fields['O'];
      if (netStr != null) {
        final net = double.tryParse(netStr);
        final vat = double.tryParse(vatStr ?? '0');
        if (net != null) {
          amount = net + (vat ?? 0);
        }
      }

      // F = date (YYYYMMDD)
      final dateStr = fields['F'];
      if (dateStr != null && dateStr.length == 8) {
        date = DateTime.tryParse(
          '${dateStr.substring(0, 4)}-${dateStr.substring(4, 6)}-${dateStr.substring(6, 8)}',
        );
      }

      // B = seller NIF — use as description hint
      final sellerNif = fields['B'];
      if (sellerNif != null) {
        description = 'NIF: $sellerNif';
      }
    }

    // Fallback: try to find a decimal number that looks like a price
    if (amount == null) {
      final pricePattern = RegExp(r'(\d+[.,]\d{2})');
      final match = pricePattern.firstMatch(raw);
      if (match != null) {
        amount = double.tryParse(match.group(1)!.replaceAll(',', '.'));
      }
    }

    return _QrParsedData(
      amount: amount,
      description: description,
      date: date ?? DateTime.now(),
    );
  }

  void _showConfirmSheet(_QrParsedData parsed, String rawData) {
    final l10n = S.of(context);
    final amountController = TextEditingController(
      text: parsed.amount?.toStringAsFixed(2) ?? '',
    );
    final descController = TextEditingController(
      text: parsed.description ?? '',
    );
    ExpenseCategory selectedCategory = ExpenseCategory.outros;
    DateTime selectedDate = parsed.date;

    showModalBottomSheet<ActualExpense>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface(ctx),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.dragHandle(ctx),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.qrExpenseConfirmTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(ctx),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Amount
                  Text(
                    l10n.addExpenseAmount,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(ctx),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      suffixText: 'EUR',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border(ctx)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border(ctx)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    l10n.addExpenseDescription,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(ctx),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(
                      hintText: l10n.addExpenseDescription,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border(ctx)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border(ctx)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category
                  Text(
                    l10n.addExpenseCategory,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(ctx),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border(ctx)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ExpenseCategory>(
                        value: selectedCategory,
                        isExpanded: true,
                        dropdownColor: AppColors.surface(ctx),
                        items: ExpenseCategory.values.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(
                              cat.localizedLabel(l10n),
                              style: TextStyle(
                                color: AppColors.textPrimary(ctx),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setSheetState(() => selectedCategory = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date
                  Text(
                    l10n.addExpenseDate,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary(ctx),
                    ),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate:
                            DateTime.now().subtract(const Duration(days: 365)),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setSheetState(() => selectedDate = picked);
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border(ctx)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 18,
                              color: AppColors.textSecondary(ctx)),
                          const SizedBox(width: 10),
                          Text(
                            '${selectedDate.day.toString().padLeft(2, '0')}/'
                            '${selectedDate.month.toString().padLeft(2, '0')}/'
                            '${selectedDate.year}',
                            style: TextStyle(
                              color: AppColors.textPrimary(ctx),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            // Reset scanner to allow re-scan
                            setState(() => _hasScanned = false);
                            _cameraController.start();
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: AppColors.border(ctx)),
                          ),
                          child: Text(l10n.qrScanAgain),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            final amount = double.tryParse(
                              amountController.text.replaceAll(',', '.'),
                            );
                            if (amount == null || amount <= 0) return;

                            final expense = ActualExpense.create(
                              category: selectedCategory.name,
                              amount: amount,
                              date: selectedDate,
                              description: descController.text.isNotEmpty
                                  ? descController.text
                                  : null,
                            );
                            Navigator.of(ctx).pop(expense);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary(ctx),
                            foregroundColor: AppColors.onPrimary(ctx),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(l10n.save),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).then((expense) {
      if (!mounted) return;
      if (expense != null) {
        // Expense confirmed — pop scanner screen with result
        Navigator.of(context).pop(expense);
      } else {
        // Sheet dismissed without saving — reset scanner
        setState(() => _hasScanned = false);
        _cameraController.start();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(l10n.qrScannerTitle),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: _cameraController,
            onDetect: _onDetect,
          ),

          // Scan overlay frame
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primary(context).withValues(alpha: 0.8),
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          // Bottom hint
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Text(
              l10n.qrScanHint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // Flash toggle
          Positioned(
            bottom: 100,
            right: 20,
            child: IconButton(
              onPressed: () => _cameraController.toggleTorch(),
              icon: const Icon(Icons.flash_on, color: Colors.white70, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrParsedData {
  final double? amount;
  final String? description;
  final DateTime date;

  _QrParsedData({
    this.amount,
    this.description,
    required this.date,
  });
}
