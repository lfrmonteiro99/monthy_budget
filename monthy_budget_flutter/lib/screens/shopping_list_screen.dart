import 'dart:async';

import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/shopping_item.dart';
import '../models/purchase_record.dart';
import '../services/analytics_service.dart';
import '../services/barcode_scan_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/atcud_parser.dart';
import '../utils/formatters.dart';
import '../widgets/barcode_result_card.dart';
import '../widgets/barcode_scan_sheet.dart';
import '../widgets/receipt_scan_sheet.dart';
import '../utils/shopping_grouping.dart';
import '../onboarding/shopping_tour.dart';
import '../widgets/shopping_group_toggle.dart';
import '../widgets/shopping_list_grouped_view.dart';
import 'package:monthly_management/widgets/calm/calm.dart';

class ShoppingListScreen extends StatefulWidget {
  final List<ShoppingItem> items;
  final ValueChanged<ShoppingItem> onToggleChecked;
  final ValueChanged<ShoppingItem> onRemove;
  final VoidCallback onClearChecked;
  final void Function(
    double? amount,
    List<ShoppingItem> checkedItems, {
    bool isMealPurchase,
  })
  onFinalize;
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
    Future.delayed(AppConstants.tourStartDelay, () {
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

    CalmBottomSheet.show(
      context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => CalmBottomSheetContent(
          title: l10n.shoppingFinalize,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CalmEyebrow('A FINALIZAR'), // TODO(l10n): extract to ARB
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: checkedItems.length,
                  itemBuilder: (_, i) {
                    final item = checkedItems[i];
                    return CalmListTile(
                      leadingIcon: Icons.check_circle,
                      leadingColor: AppColors.ok(ctx),
                      title: item.productName,
                      subtitle: item.price > 0
                          ? formatCurrency(item.price)
                          : null,
                      trailing: item.price > 0
                          ? formatCurrency(item.price)
                          : null,
                    );
                  },
                ),
              ),
              Divider(height: 24, color: AppColors.line(ctx)),
              if (estimatedTotal > 0)
                CalmCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 0,
                  ),
                  child: CalmListTile(
                    leadingIcon: Icons.shopping_cart_checkout,
                    leadingColor: AppColors.ok(ctx),
                    title: l10n.shoppingEstimatedTotal,
                    trailing: formatCurrency(estimatedTotal),
                  ),
                ),
              if (estimatedTotal > 0) const SizedBox(height: 12),
              Text(
                l10n.shoppingHowMuchSpent,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink50(ctx),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  suffixText: activeCurrencyCode,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.line(ctx)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.line(ctx)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.accent(ctx),
                      width: 2,
                    ),
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
                      onChanged: (v) => setSheetState(
                        () => isMealPurchase = v ?? false,
                      ),
                      activeColor: AppColors.ink(ctx),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      side: BorderSide(
                        width: 2,
                        color: AppColors.ink20(ctx),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.mealCostReconciliation,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.ink70(ctx),
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
                    widget.onFinalize(
                      amount,
                      checkedItems,
                      isMealPurchase: isMealPurchase,
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.ink(ctx),
                    foregroundColor: AppColors.bg(ctx),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(l10n.shoppingConfirm),
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
    final checkedItems = widget.items.where((i) => i.checked).toList();
    final uncheckedItems = widget.items.where((i) => !i.checked).toList();
    final uncheckedTotal = uncheckedItems.fold(0.0, (s, i) => s + i.price);

    if (widget.items.isEmpty) {
      final emptyBody = Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: CalmEmptyState(
            icon: Icons.shopping_basket_outlined,
            title: l10n.shoppingEmpty,
            body: l10n.shoppingEmptyMessage,
          ),
        ),
      );
      if (widget.embedded) return emptyBody;
      return CalmScaffold(
        title: l10n.shoppingTitle,
        actions: _buildAppBarActions(l10n),
        body: emptyBody,
      );
    }

    final heroBlock = Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 16),
      child: CalmHero(
        eyebrow: 'LISTA', // TODO(l10n): extract to ARB
        amount: formatCurrency(uncheckedTotal),
        subtitle:
            '${uncheckedItems.length} por comprar', // TODO(l10n): extract to ARB
      ),
    );

    // Summary card with totals and status pill
    final summaryCard = CalmCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CalmEyebrow('RESUMO'), // TODO(l10n): extract to ARB
                const SizedBox(height: 4),
                Text(
                  l10n.shoppingItemsRemaining(
                    uncheckedItems.length,
                    formatCurrency(uncheckedTotal),
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Status pill: shows how many items checked
          CalmPill(
            label: '${checkedItems.length} ✓', // TODO(l10n): extract to ARB
            color: hasChecked
                ? AppColors.ok(context)
                : AppColors.ink50(context),
          ),
          if (hasChecked) ...[
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () async {
                final confirmed = await CalmDialog.confirm(
                  context,
                  title: l10n.shoppingClear,
                  confirmLabel: l10n.delete,
                  cancelLabel: l10n.cancel,
                  destructive: true,
                );
                if (confirmed == true) {
                  widget.onClearChecked();
                }
              },
              icon: const Icon(Icons.delete_sweep, size: 16),
              label: Text(l10n.shoppingClear),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.ink70(context),
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        heroBlock,
        Divider(color: AppColors.line(context), height: 1),
        const SizedBox(height: 12),
        if (_availableModes.length > 1)
          ShoppingGroupToggle(
            availableModes: _availableModes,
            selected: _groupMode,
            onChanged: (mode) => setState(() => _groupMode = mode),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: summaryCard,
        ),
        if (widget.items.isNotEmpty && widget.items.every((i) => i.checked))
          _buildReceiptScanBanner(l10n),
        Expanded(child: _buildListBody(l10n)),
      ],
    );

    final fab = hasChecked
        ? FloatingActionButton.extended(
            key: ShoppingTourKeys.finalizeButton,
            onPressed: _showFinalizeSheet,
            backgroundColor: AppColors.ink(context),
            icon: Icon(
              Icons.check_circle_outline,
              color: AppColors.bg(context),
            ),
            label: Text(
              l10n.shoppingFinalize,
              style: TextStyle(
                color: AppColors.bg(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        : null;

    if (widget.embedded) {
      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: body,
          ),
          if (hasChecked)
            Positioned(
              bottom: 16,
              right: 16,
              child: fab!,
            ),
        ],
      );
    }

    return CalmScaffold(
      title: l10n.shoppingTitle,
      actions: _buildAppBarActions(l10n),
      floatingActionButton: fab,
      body: body,
    );
  }

  List<Widget> _buildAppBarActions(S l10n) {
    return [
      IconButton(
        icon: Icon(
          Icons.document_scanner,
          color: AppColors.ink70(context),
        ),
        tooltip: l10n.quickScanReceipt,
        onPressed: () => ReceiptScanSheet.show(context),
      ),
      if (widget.onAddToShoppingList != null)
        IconButton(
          icon: Icon(
            Icons.qr_code_scanner,
            color: AppColors.ink70(context),
          ),
          tooltip: l10n.barcodeScanTooltip,
          onPressed: _onScanBarcode,
        ),
      if (widget.purchaseHistory.records.isNotEmpty)
        IconButton(
          key: ShoppingTourKeys.historyButton,
          icon: Icon(
            Icons.receipt_long_outlined,
            color: AppColors.ink70(context),
          ),
          tooltip: l10n.shoppingHistoryTooltip,
          onPressed: _showHistory,
        ),
    ];
  }

  Future<void> _onScanBarcode() async {
    final barcode = await BarcodeScanSheet.show(context);
    if (barcode == null || !mounted) return;

    // Detect invoice/receipt barcodes (ATCUD QR codes) and redirect
    if (AtcudParser.isAtcudQrCode(barcode)) {
      unawaited(
        AnalyticsService.instance.trackEvent(
          'barcode_scanned',
          properties: {'barcode_type': 'receipt_qr', 'matched_product': false},
        ),
      );
      if (!mounted) return;
      final l10n = S.of(context);
      CalmSnack.show(
        context,
        l10n.barcodeInvoiceDetected,
        duration: AppConstants.snackBarMedium,
        action: SnackBarAction(
          label: l10n.barcodeInvoiceAction,
          onPressed: () => ReceiptScanSheet.show(context),
        ),
      );
      return;
    }

    final service = widget.barcodeScanService ?? BarcodeScanService();
    final candidate = await service.lookup(barcode);
    unawaited(
      AnalyticsService.instance.trackEvent(
        'barcode_scanned',
        properties: {
          'barcode_type': 'product',
          'matched_product': candidate.matchedProduct != null,
          'source': candidate.source.name,
        },
      ),
    );

    if (!mounted) return;

    await BarcodeResultCard.show(
      context,
      candidate: candidate,
      onAddToList: (item) {
        widget.onAddToShoppingList?.call(item);
        final l10n = S.of(context);
        CalmSnack.success(
          context,
          l10n.barcodeAddedToList(item.productName),
          duration: AppConstants.snackBarShort,
        );
      },
    );
  }

  Widget _buildReceiptScanBanner(S l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CalmCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.document_scanner,
              size: 22,
              color: AppColors.accent(context),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.receiptScanPrompt,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.ink(context),
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                CalmSnack.show(
                  context,
                  l10n.quickScanReceipt,
                  duration: AppConstants.snackBarShort,
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent(context),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(l10n.quickScanReceipt),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListBody(S l10n) {
    switch (_groupMode) {
      case ShoppingGroupMode.items:
        final unchecked = widget.items.where((i) => !i.checked).toList();
        final checked = widget.items.where((i) => i.checked).toList();
        return ListView(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
          children: [
            if (unchecked.isNotEmpty) ...[
              CalmEyebrow('POR COMPRAR'), // TODO(l10n): extract to ARB
              const SizedBox(height: 6),
              ...unchecked.asMap().entries.map(
                (e) => _buildItemRow(
                  e.value,
                  tourKey: e.key == 0 ? ShoppingTourKeys.shoppingItem : null,
                  index: e.key,
                ),
              ),
            ],
            if (checked.isNotEmpty) ...[
              const SizedBox(height: 8),
              CalmEyebrow('NO CESTO'), // TODO(l10n): extract to ARB
              const SizedBox(height: 6),
              ...checked.asMap().entries.map(
                (e) => _buildItemRow(e.value, index: 1000 + e.key),
              ),
            ],
          ],
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

  void _showHistory() {
    final l10n = S.of(context);
    final expandedMap = <int, bool>{};
    CalmBottomSheet.show(
      context,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollController) => StatefulBuilder(
          builder: (ctx, setLocalState) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: SizedBox(
                    width: 40,
                    height: 4,
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                        color: AppColors.ink20(ctx),
                        shape: const StadiumBorder(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CalmEyebrow('HISTÓRICO'), // TODO(l10n): extract to ARB
                const SizedBox(height: 4),
                Text(
                  l10n.shoppingHistoryTitle,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink(ctx),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.only(bottom: 32),
                    itemCount: widget.purchaseHistory.records.length,
                    itemBuilder: (_, i) {
                      final r = widget.purchaseHistory.records[i];
                      final isExpanded = expandedMap[i] ?? false;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: CalmCard(
                          onTap: () => setLocalState(
                            () => expandedMap[i] = !isExpanded,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${r.date.day}/${r.date.month}/${r.date.year}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.ink(ctx),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        formatCurrency(r.amount),
                                        style: CalmText.amount(ctx),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        isExpanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        size: 18,
                                        color: AppColors.ink50(ctx),
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
                                      fontSize: 12,
                                      color: AppColors.ink70(ctx),
                                    ),
                                  ),
                                ),
                              if (isExpanded && r.items.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                ...r.items.map(
                                  (name) => CalmListTile(
                                    leadingIcon: Icons.receipt_outlined,
                                    leadingColor: AppColors.accent(ctx),
                                    title: name,
                                  ),
                                ),
                              ],
                            ],
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
      ),
    );
  }

  Widget _buildItemRow(ShoppingItem item, {GlobalKey? tourKey, int? index}) {
    final l10n = S.of(context);
    // subtitle: quantity · estimated price when available
    final subtitleParts = <String>[];
    if (item.price > 0) subtitleParts.add(formatCurrency(item.price));
    final subtitle = subtitleParts.isNotEmpty ? subtitleParts.join(' · ') : null;

    final tile = CalmListTile(
      leadingIcon: item.checked
          ? Icons.check_circle
          : Icons.radio_button_unchecked,
      leadingColor: item.checked
          ? AppColors.ok(context)
          : AppColors.accent(context),
      title: item.productName,
      subtitle: subtitle,
      trailing: item.price > 0 ? formatCurrency(item.price) : null,
      onTap: () => widget.onToggleChecked(item),
    );

    // Action button (mark at home) appended below the tile when relevant
    final tileWithAction = item.checked || widget.onMarkAtHome == null
        ? tile
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              tile,
              Align(
                alignment: Alignment.centerRight,
                child: Tooltip(
                  message: l10n.pantryMarkAtHome,
                  child: InkWell(
                    onTap: () {
                      widget.onMarkAtHome!(item);
                      CalmSnack.show(
                        context,
                        l10n.pantryMarkedAtHome(item.productName),
                        duration: AppConstants.snackBarShort,
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.home_outlined,
                        size: 18,
                        color: AppColors.accent(context),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );

    return Dismissible(
      key: Key(
        item.id.isNotEmpty
            ? 'sl_${item.id}'
            : 'sl_pending_${index ?? 0}_${item.productName}_${item.store}_${item.price}',
      ),
      direction: DismissDirection.endToStart,
      background: ColoredBox(
        color: AppColors.bad(context).withValues(alpha: 0.12),
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.delete_outline,
              color: AppColors.bad(context),
              size: 22,
            ),
          ),
        ),
      ),
      onDismissed: (_) => widget.onRemove(item),
      child: Semantics(
        key: tourKey,
        button: true,
        label: item.checked
            ? l10n.shoppingItemChecked(item.productName)
            : l10n.shoppingItemSwipe(item.productName),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CalmCard(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: tileWithAction,
          ),
        ),
      ),
    );
  }
}
