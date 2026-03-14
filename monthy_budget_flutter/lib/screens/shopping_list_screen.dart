import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/shopping_item.dart';
import '../models/purchase_record.dart';
import '../services/barcode_scan_service.dart';
import '../theme/app_colors.dart';
import '../utils/atcud_parser.dart';
import '../utils/formatters.dart';
import '../widgets/barcode_result_card.dart';
import '../widgets/barcode_scan_sheet.dart';
import '../widgets/receipt_scan_sheet.dart';
import '../utils/shopping_grouping.dart';
import '../onboarding/shopping_tour.dart';
import '../widgets/shopping_group_toggle.dart';
import '../widgets/shopping_list_grouped_view.dart';

class ShoppingListScreen extends StatefulWidget {
  final List<ShoppingItem> items;
  final ValueChanged<ShoppingItem> onToggleChecked;
  final ValueChanged<ShoppingItem> onRemove;
  final VoidCallback onClearChecked;
  final void Function(double? amount, List<ShoppingItem> checkedItems, {bool isMealPurchase}) onFinalize;
  final PurchaseHistory purchaseHistory;
  final bool showTour;
  final VoidCallback? onTourComplete;
  final ValueChanged<ShoppingItem>? onAddToShoppingList;
  final BarcodeScanService? barcodeScanService;
  final ValueChanged<ShoppingItem>? onMarkAtHome;
  final bool embedded;

  const ShoppingListScreen({
    super.key,
    required this.items,
    required this.onToggleChecked,
    required this.onRemove,
    required this.onClearChecked,
    required this.onFinalize,
    required this.purchaseHistory,
    this.showTour = false,
    this.onTourComplete,
    this.onAddToShoppingList,
    this.barcodeScanService,
    this.onMarkAtHome,
    this.embedded = false,
  });

  @override
  State<ShoppingListScreen> createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  bool _tourShown = false;
  ShoppingGroupMode _groupMode = ShoppingGroupMode.items;

  List<ShoppingGroupMode> get _availableModes =>
      availableGroupModes(widget.items);

  @override
  void initState() {
    super.initState();
    if (widget.showTour && widget.items.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryShowTour());
    }
  }

  @override
  void didUpdateWidget(ShoppingListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showTour && !_tourShown && widget.items.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryShowTour());
    }
  }

  void _tryShowTour() {
    if (_tourShown || !mounted || widget.items.isEmpty) return;
    _tourShown = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      buildShoppingTour(
        context: context,
        onFinish: () => widget.onTourComplete?.call(),
        onSkip: () => widget.onTourComplete?.call(),
      ).show(context: context);
    });
  }

  void _showFinalizeSheet() {
    final l10n = S.of(context);
    final checkedItems = widget.items.where((i) => i.checked).toList();
    final controller = TextEditingController();
    final estimatedTotal = checkedItems.fold(0.0, (s, i) => s + i.price);
    bool isMealPurchase = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
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
                  color: AppColors.borderMuted(ctx),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                l10n.shoppingFinalize,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: checkedItems.length,
                itemBuilder: (_, i) {
                  final item = checkedItems[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle,
                            size: 16, color: AppColors.success(ctx)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(item.productName,
                              style: const TextStyle(fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        if (item.price > 0)
                          Text(
                            formatCurrency(item.price),
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success(ctx)),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(height: 24, indent: 20, endIndent: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (estimatedTotal > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(l10n.shoppingEstimatedTotal,
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.textSecondary(ctx))),
                          Text(formatCurrency(estimatedTotal),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary(ctx))),
                        ],
                      ),
                    ),
                  Text(
                    l10n.shoppingHowMuchSpent,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted(ctx),
                        letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      suffixText: activeCurrencyCode,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: AppColors.border(ctx)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: AppColors.border(ctx)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: AppColors.primary(ctx), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: isMealPurchase,
                          onChanged: (v) => setSheetState(() => isMealPurchase = v ?? false),
                          activeColor: AppColors.primary(ctx),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          side: const BorderSide(
                            width: 2,
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.mealCostReconciliation,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary(ctx),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final raw = controller.text.trim();
                        final amount = raw.isNotEmpty
                            ? double.tryParse(raw.replaceAll(',', '.'))
                            : null;
                        Navigator.pop(ctx);
                        widget.onFinalize(amount, checkedItems, isMealPurchase: isMealPurchase);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary(ctx),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(l10n.shoppingConfirm),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final hasChecked = widget.items.any((i) => i.checked);
    final uncheckedTotal =
        widget.items.where((i) => !i.checked).fold(0.0, (s, i) => s + i.price);

    if (widget.items.isEmpty) {
      final emptyBody = Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.shopping_basket_outlined,
                  size: 56, color: AppColors.dragHandle(context)),
              const SizedBox(height: 16),
              Text(
                l10n.shoppingEmpty,
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLabel(context)),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.shoppingEmptyMessage,
                style: TextStyle(fontSize: 14, color: AppColors.textMuted(context)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
      if (widget.embedded) return emptyBody;
      return Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: _buildAppBar(),
        body: emptyBody,
      );
    }

    final body = Column(
        children: [
          if (_availableModes.length > 1)
            ShoppingGroupToggle(
              availableModes: _availableModes,
              selected: _groupMode,
              onChanged: (mode) => setState(() => _groupMode = mode),
            ),
          Container(
            color: AppColors.surface(context),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Icon(Icons.shopping_basket,
                    size: 16, color: AppColors.success(context)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.shoppingItemsRemaining(widget.items.where((i) => !i.checked).length, formatCurrency(uncheckedTotal)),
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary(context)),
                  ),
                ),
                if (hasChecked)
                  TextButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(l10n.shoppingClear),
                          content: Text(l10n.shoppingClear),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text(l10n.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: Text(l10n.delete,
                                  style: TextStyle(
                                      color: AppColors.error(context))),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true) {
                        widget.onClearChecked();
                      }
                    },
                    icon: const Icon(Icons.delete_sweep, size: 16),
                    label: Text(l10n.shoppingClear),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textMuted(context),
                      textStyle: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.surfaceVariant(context)),
          if (widget.items.isNotEmpty && widget.items.every((i) => i.checked))
            _buildReceiptScanBanner(l10n),
          Expanded(
            child: _buildListBody(l10n),
          ),
        ],
      );

    if (widget.embedded) {
      return Stack(
        children: [
          body,
          if (hasChecked)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                key: ShoppingTourKeys.finalizeButton,
                onPressed: _showFinalizeSheet,
                backgroundColor: AppColors.success(context),
                icon: Icon(Icons.check_circle_outline, color: AppColors.onPrimary(context)),
                label: Text(
                  l10n.shoppingFinalize,
                  style: TextStyle(color: AppColors.onPrimary(context), fontWeight: FontWeight.w600),
                ),
              ),
            ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: _buildAppBar(),
      body: body,
      floatingActionButton: hasChecked
          ? FloatingActionButton.extended(
              key: ShoppingTourKeys.finalizeButton,
              onPressed: _showFinalizeSheet,
              backgroundColor: AppColors.success(context),
              icon: Icon(Icons.check_circle_outline, color: AppColors.onPrimary(context)),
              label: Text(
                l10n.shoppingFinalize,
                style: TextStyle(color: AppColors.onPrimary(context), fontWeight: FontWeight.w600),
              ),
            )
          : null,
    );
  }

  Future<void> _onScanBarcode() async {
    final barcode = await BarcodeScanSheet.show(context);
    if (barcode == null || !mounted) return;

    // Detect invoice/receipt barcodes (ATCUD QR codes) and redirect
    if (AtcudParser.isAtcudQrCode(barcode)) {
      if (!mounted) return;
      final l10n = S.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.barcodeInvoiceDetected),
          duration: const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          action: SnackBarAction(
            label: l10n.barcodeInvoiceAction,
            onPressed: () => ReceiptScanSheet.show(context),
          ),
        ),
      );
      return;
    }

    final service = widget.barcodeScanService ?? BarcodeScanService();
    final candidate = await service.lookup(barcode);

    if (!mounted) return;

    await BarcodeResultCard.show(
      context,
      candidate: candidate,
      onAddToList: (item) {
        widget.onAddToShoppingList?.call(item);
        final l10n = S.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.barcodeAddedToList(item.productName)),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
    );
  }

  Widget _buildReceiptScanBanner(S l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.primary(context).withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(Icons.document_scanner, size: 22, color: AppColors.primary(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.receiptScanPrompt,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.quickScanReceipt),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary(context),
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            child: Text(l10n.quickScanReceipt),
          ),
        ],
      ),
    );
  }

  Widget _buildListBody(S l10n) {
    switch (_groupMode) {
      case ShoppingGroupMode.items:
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          itemCount: widget.items.length,
          itemBuilder: (_, i) => _buildItemRow(widget.items[i], tourKey: i == 0 ? ShoppingTourKeys.shoppingItem : null),
        );
      case ShoppingGroupMode.meals:
        final groups = groupByMeal(
          widget.items,
          ungroupedLabel: l10n.shoppingGroupOther,
        );
        return ShoppingListGroupedView(
          groups: groups,
          mode: _groupMode,
          onToggleChecked: widget.onToggleChecked,
          onRemove: widget.onRemove,
        );
      case ShoppingGroupMode.stores:
        final groups = groupByStore(
          widget.items,
          ungroupedLabel: l10n.shoppingGroupOther,
        );
        return ShoppingListGroupedView(
          groups: groups,
          mode: _groupMode,
          onToggleChecked: widget.onToggleChecked,
          onRemove: widget.onRemove,
        );
    }
  }

  AppBar _buildAppBar() {
    final l10n = S.of(context);
    return AppBar(
        backgroundColor: AppColors.surface(context),
        surfaceTintColor: AppColors.surface(context),
        title: Text(
          l10n.shoppingTitle,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.document_scanner,
                color: AppColors.textSecondary(context)),
            tooltip: l10n.quickScanReceipt,
            onPressed: () => ReceiptScanSheet.show(context),
          ),
          if (widget.onAddToShoppingList != null)
            IconButton(
              icon: Icon(Icons.qr_code_scanner,
                  color: AppColors.textSecondary(context)),
              tooltip: l10n.barcodeScanTooltip,
              onPressed: _onScanBarcode,
            ),
          if (widget.purchaseHistory.records.isNotEmpty)
            IconButton(
              key: ShoppingTourKeys.historyButton,
              icon: Icon(Icons.receipt_long_outlined,
                  color: AppColors.textSecondary(context)),
              tooltip: l10n.shoppingHistoryTooltip,
              onPressed: _showHistory,
            ),
        ],
      );
  }

  void _showHistory() {
    final l10n = S.of(context);
    final expandedMap = <int, bool>{};
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => StatefulBuilder(
          builder: (ctx, setLocalState) => Column(
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.borderMuted(ctx),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    l10n.shoppingHistoryTitle,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  itemCount: widget.purchaseHistory.records.length,
                  itemBuilder: (_, i) {
                    final r = widget.purchaseHistory.records[i];
                    final isExpanded = expandedMap[i] ?? false;
                    return Material(
                      color: AppColors.background(ctx),
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                      onTap: () =>
                          setLocalState(() => expandedMap[i] = !isExpanded),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border(ctx)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${r.date.day}/${r.date.month}/${r.date.year}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textLabel(ctx)),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      formatCurrency(r.amount),
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary(ctx)),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      isExpanded
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      size: 18,
                                      color: AppColors.textMuted(ctx),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (!isExpanded)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  l10n.shoppingProductCount(r.itemCount),
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.textMuted(ctx)),
                                ),
                              ),
                            if (isExpanded && r.items.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              ...r.items.map((name) => Padding(
                                    padding: const EdgeInsets.only(bottom: 3),
                                    child: Row(
                                      children: [
                                        Icon(Icons.circle,
                                            size: 4, color: AppColors.textMuted(ctx)),
                                        const SizedBox(width: 8),
                                        Text(name,
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: AppColors.textLabel(ctx))),
                                      ],
                                    ),
                                  )),
                            ],
                          ],
                        ),
                      ),
                    ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemRow(ShoppingItem item, {GlobalKey? tourKey}) {
    final l10n = S.of(context);
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
        child:
            Icon(Icons.delete_outline, color: AppColors.error(context), size: 22),
      ),
      onDismissed: (_) => widget.onRemove(item),
      child: Semantics(
        key: tourKey,
        button: true,
        label: item.checked ? l10n.shoppingItemChecked(item.productName) : l10n.shoppingItemSwipe(item.productName),
        child: Material(
        color: item.checked ? AppColors.background(context) : AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
        onTap: () => widget.onToggleChecked(item),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                child: Text(
                  item.productName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: item.checked
                        ? const Color(0xFF94A3B8)
                        : AppColors.textPrimary(context),
                    decoration:
                        item.checked ? TextDecoration.lineThrough : null,
                    decorationColor: const Color(0xFF94A3B8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
              if (!item.checked && widget.onMarkAtHome != null)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Tooltip(
                    message: l10n.pantryMarkAtHome,
                    child: InkWell(
                      onTap: () {
                        widget.onMarkAtHome!(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.pantryMarkedAtHome(item.productName)),
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.home_outlined, size: 18, color: AppColors.primary(context)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      ),
      ),
    );
  }
}
