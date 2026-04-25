import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../models/grocery_data.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/product.dart';
import '../models/shopping_item.dart';
import '../services/barcode_scan_service.dart';
import '../theme/app_colors.dart';
import '../utils/atcud_parser.dart';
import '../utils/formatters.dart';
import '../widgets/barcode_result_card.dart';
import '../widgets/barcode_scan_sheet.dart';
import '../widgets/receipt_scan_sheet.dart';
import '../onboarding/grocery_tour.dart';
import 'package:monthly_management/widgets/calm/calm.dart';

class GroceryScreen extends StatefulWidget {
  final List<Product> products;
  final GroceryData? groceryData;
  final bool isLoading;
  final ValueChanged<ShoppingItem>? onAddToShoppingList;
  final bool showTour;
  final VoidCallback? onTourComplete;
  final BarcodeScanService? barcodeScanService;
  final Set<String> weeklyPantryIds;
  final ValueChanged<String>? onToggleWeeklyPantry;
  final bool embedded;

  const GroceryScreen({
    super.key,
    required this.products,
    this.groceryData,
    this.isLoading = false,
    this.onAddToShoppingList,
    this.showTour = false,
    this.onTourComplete,
    this.barcodeScanService,
    this.weeklyPantryIds = const {},
    this.onToggleWeeklyPantry,
    this.embedded = false,
  });

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  bool _tourShown = false;
  bool _hideStaleStores = false;

  @override
  void initState() {
    super.initState();
    if (widget.showTour && widget.products.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryShowTour();
      });
    }
  }

  @override
  void didUpdateWidget(GroceryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showTour && !_tourShown && widget.products.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tryShowTour();
      });
    }
  }

  void _tryShowTour() {
    if (_tourShown || !mounted || widget.products.isEmpty) return;
    _tourShown = true;
    Future.delayed(AppConstants.tourStartDelay, () {
      if (!mounted) return;
      buildGroceryTour(
        context: context,
        onFinish: () => widget.onTourComplete?.call(),
        onSkip: () => widget.onTourComplete?.call(),
      ).show(context: context);
    });
  }

  bool get _canFilterStaleStores =>
      widget.groceryData != null &&
      widget.groceryData!.hasDegradedStores &&
      widget.products.isNotEmpty;

  List<Product> get _effectiveProducts {
    if (_hideStaleStores && _canFilterStaleStores) {
      return widget.groceryData!.filterByFreshStores().toCatalogProducts();
    }
    return widget.products;
  }

  List<String> get _categories {
    final cats = _effectiveProducts.map((p) => p.category).toSet().toList();
    cats.sort();
    return cats;
  }

  List<Product> get _filtered {
    var list = _effectiveProducts;
    if (_selectedCategory != null) {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  /// Products whose names are in the pantry id set.
  List<Product> get _pantryProducts {
    if (widget.weeklyPantryIds.isEmpty) return const [];
    return widget.products
        .where((p) =>
            widget.weeklyPantryIds.contains(p.name.toLowerCase()))
        .toList();
  }

  IconData _categoryIcon(String cat) {
    const map = {
      'Frutas': Icons.eco,
      'Legumes': Icons.grass,
      'Carnes': Icons.restaurant,
      'Peixe': Icons.set_meal,
      'Laticinios': Icons.egg_outlined,
      'Pao e Cereais': Icons.bakery_dining,
      'Ovos': Icons.egg,
      'Conservas': Icons.inventory_2_outlined,
      'Azeite e Condimentos': Icons.oil_barrel_outlined,
      'Bebidas': Icons.local_drink_outlined,
      'Congelados': Icons.ac_unit,
      'Snacks': Icons.cookie_outlined,
      'Limpeza': Icons.cleaning_services_outlined,
      'Higiene': Icons.spa_outlined,
    };
    return map[cat] ?? Icons.category_outlined;
  }

  Color _categoryColor(String cat) {
    // Map grocery category strings to Calm category swatches by semantic match.
    // Resolved via AppColors.categoryColorByName which reads from
    // AppColors._expenseCategoryColors — the single source of truth for swatches.
    const groceryCategoryToExpense = {
      'Frutas': 'alimentacao',
      'Legumes': 'alimentacao',
      'Carnes': 'habitacao',
      'Peixe': 'agua',
      'Laticinios': 'transportes',
      'Pao e Cereais': 'energia',
      'Ovos': 'energia',
      'Conservas': 'outros',
      'Azeite e Condimentos': 'transportes',
      'Bebidas': 'agua',
      'Congelados': 'telecomunicacoes',
      'Snacks': 'lazer',
      'Limpeza': 'educacao',
      'Higiene': 'saude',
    };
    final expenseName = groceryCategoryToExpense[cat] ?? 'outros';
    return AppColors.categoryColorByName(expenseName);
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
          duration: AppConstants.snackBarMedium,
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
            duration: AppConstants.snackBarShort,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
    );
  }

  void _addToCart(Product product) {
    if (widget.onAddToShoppingList == null) return;
    final l10n = S.of(context);
    widget.onAddToShoppingList!(ShoppingItem(
      productName: product.name,
      store: '',
      price: product.avgPrice,
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.groceryAddedToList(product.name)),
        duration: AppConstants.snackBarShort,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final filtered = _filtered;
    // Group by category preserving current filter
    final Map<String, List<Product>> byCategory = {};
    for (final p in filtered) {
      byCategory.putIfAbsent(p.category, () => []).add(p);
    }
    final cats = byCategory.keys.toList()..sort();

    final bodyContent = widget.isLoading
        ? Center(
            child: Semantics(
              label: l10n.groceryLoadingLabel,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.accent(context)),
                  const SizedBox(height: 16),
                  Text(
                    l10n.groceryLoadingMessage,
                    style: TextStyle(
                        fontSize: 14, color: AppColors.ink70(context)),
                  ),
                ],
              ),
            ),
          )
        : widget.products.isEmpty
            ? Center(child: _buildEmptyState(l10n))
            : Column(
                children: [
                  // Hero summary: catalog count + active scope
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: CalmHero(
                      eyebrow: 'COMPRAS', // TODO(l10n): extrair chave
                      amount: '${widget.products.length}',
                      subtitle: _selectedCategory ?? l10n.groceryAll,
                    ),
                  ),
                  // Search + filter wrapped in a CalmCard surface
                  CalmCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CalmEyebrow('FILTROS'), // TODO(l10n): extrair chave
                        const SizedBox(height: 10),
                        TextField(
                          key: GroceryTourKeys.searchBar,
                          onChanged: (v) =>
                              setState(() => _searchQuery = v),
                          decoration: InputDecoration(
                            hintText: l10n.grocerySearchHint,
                            hintStyle: TextStyle(
                                color: AppColors.ink50(context),
                                fontSize: 14),
                            prefixIcon: Icon(Icons.search,
                                color: AppColors.ink50(context), size: 20),
                            filled: true,
                            fillColor: AppColors.bgSunk(context),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: AppColors.line(context)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: AppColors.line(context)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                  color: AppColors.accent(context),
                                  width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          key: GroceryTourKeys.categoryFilter,
                          height: 36,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              if (_canFilterStaleStores) ...[
                                _staleFilterPill(),
                                const SizedBox(width: 8),
                              ],
                              _categoryChip(
                                l10n.groceryAll,
                                _selectedCategory == null,
                                () => setState(
                                    () => _selectedCategory = null),
                              ),
                              ..._categories.map((cat) => Padding(
                                    padding:
                                        const EdgeInsets.only(left: 8),
                                    child: _categoryChip(
                                      cat,
                                      _selectedCategory == cat,
                                      () => setState(
                                        () =>
                                            _selectedCategory == cat
                                                ? _selectedCategory = null
                                                : _selectedCategory = cat,
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.groceryProductCount(filtered.length),
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.ink50(context),
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Pantry items summary card (shown when user has marked items)
                  if (_pantryProducts.isNotEmpty) _buildPantryCard(l10n),
                  // Availability card (country data bundle)
                  if ((widget.groceryData?.hasCountryBundle ?? false))
                    _buildAvailabilityCard(l10n),
                  // Product list grouped by category
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80),
                      itemCount: cats.length,
                      itemBuilder: (_, i) {
                        final cat = cats[i];
                        final items = byCategory[cat]!;
                        return _buildCategory(
                            cat, items, isFirst: i == 0);
                      },
                    ),
                  ),
                ],
              );

    if (widget.embedded) {
      // In embedded mode (e.g. inside TabBarView), the parent provides
      // height constraints. Wrap in Column so the inner Expanded resolves.
      return Column(children: [Expanded(child: bodyContent)]);
    }

    return CalmScaffold(
      title: l10n.groceryTitle,
      actions: [
        if (widget.onAddToShoppingList != null)
          IconButton(
            icon: Icon(Icons.qr_code_scanner,
                color: AppColors.ink70(context)),
            tooltip: l10n.barcodeScanTooltip,
            onPressed: _onScanBarcode,
          ),
      ],
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: bodyContent,
      ),
    );
  }

  Widget _buildEmptyState(S l10n) {
    return CalmEmptyState(
      icon: Icons.shopping_basket_outlined,
      title: l10n.groceryEmptyStateTitle,
      body: l10n.groceryEmptyStateMessage,
    );
  }

  /// Pantry items section — products already marked as "em casa".
  /// Each product is rendered as a CalmListTile row so pantry status is
  /// visible before the user scrolls the full product list.
  Widget _buildPantryCard(S l10n) {
    final pantry = _pantryProducts;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CalmCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CalmEyebrow('EM CASA'), // TODO(l10n): extrair chave
            const SizedBox(height: 8),
            for (int i = 0; i < pantry.length; i++) ...[
              CalmListTile(
                leadingIcon: Icons.home,
                leadingColor: AppColors.ok(context),
                title: pantry[i].name,
                subtitle: pantry[i].category,
                trailing: formatCurrency(pantry[i].avgPrice),
              ),
              if (i < pantry.length - 1)
                Divider(
                  color: AppColors.line(context),
                  height: 1,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityCard(S l10n) {
    final groceryData = widget.groceryData;
    if (groceryData == null || !groceryData.hasCountryBundle) {
      return const SizedBox.shrink();
    }

    final hasWarning = groceryData.hasDegradedStores;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CalmCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CalmEyebrow(
              'DISPONIBILIDADE', // TODO(l10n): extrair chave
            ),
            const SizedBox(height: 8),
            Text(
              l10n.groceryAvailabilityCountry(groceryData.countryCode),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.ink(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              l10n.groceryAvailabilitySummary(
                groceryData.freshStoreCount,
                groceryData.partialStoreCount,
                groceryData.failedStoreCount,
              ),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.ink70(context),
              ),
            ),
            if (hasWarning) ...[
              const SizedBox(height: 6),
              Text(
                l10n.groceryAvailabilityWarning,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.ink70(context),
                ),
              ),
            ],
            const SizedBox(height: 8),
            // Summary stat rows — store counts by freshness bucket
            CalmListTile(
              leadingIcon: Icons.check_circle_outline,
              leadingColor: AppColors.ok(context),
              title: l10n.groceryStoreFreshCount(groceryData.freshStoreCount),
              trailing: '${groceryData.freshStoreCount}',
            ),
            Divider(color: AppColors.line(context), height: 1),
            CalmListTile(
              leadingIcon: Icons.error_outline,
              leadingColor: AppColors.bad(context),
              title: l10n.groceryStoreFailedCount(groceryData.failedStoreCount),
              trailing: '${groceryData.failedStoreCount}',
            ),
            Divider(color: AppColors.line(context), height: 1),
            const SizedBox(height: 4),
            // Per-store detail rows (one per store, each shows its own status)
            ...groceryData.storeSummaries.map(
              (store) => _buildStoreHealthRow(l10n, store),
            ),
          ],
        ),
      ),
    );
  }

  Color _storeStatusColor(GroceryStoreStatus status) {
    switch (status) {
      case GroceryStoreStatus.fresh:
        return AppColors.ok(context);
      case GroceryStoreStatus.stale:
        return AppColors.warn(context);
      case GroceryStoreStatus.partial:
        return AppColors.warn(context);
      case GroceryStoreStatus.failed:
        return AppColors.bad(context);
    }
  }

  String _storeStatusLabel(S l10n, GroceryStoreStatus status) {
    switch (status) {
      case GroceryStoreStatus.fresh:
        return l10n.groceryStoreFreshLabel;
      case GroceryStoreStatus.stale:
        return l10n.groceryStoreStaleLabel;
      case GroceryStoreStatus.partial:
        return l10n.groceryStorePartialLabel;
      case GroceryStoreStatus.failed:
        return l10n.groceryStoreFailedLabel;
    }
  }

  String? _freshnessAgeText(S l10n, GroceryStoreSummary store) {
    final age = store.freshnessAge;
    if (age == null) return null;
    final totalHours = age.inHours;
    if (totalHours >= 24) {
      return l10n.groceryStoreUpdatedDaysAgo(totalHours ~/ 24);
    }
    return l10n.groceryStoreUpdatedHoursAgo(totalHours);
  }

  /// Each store's freshness rendered as a CalmListTile row.
  /// Leading icon reflects status; trailing shows a CalmPill badge.
  Widget _buildStoreHealthRow(S l10n, GroceryStoreSummary store) {
    final color = _storeStatusColor(store.status);
    final label = _storeStatusLabel(l10n, store.status);
    final ageText = _freshnessAgeText(l10n, store);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        children: [
          CalmListTile(
            leadingIcon: _storeStatusIcon(store.status),
            leadingColor: color,
            title: store.storeName,
            subtitle: ageText,
            trailing: label,
          ),
          Divider(color: AppColors.line(context), height: 1),
        ],
      ),
    );
  }

  IconData _storeStatusIcon(GroceryStoreStatus status) {
    switch (status) {
      case GroceryStoreStatus.fresh:
        return Icons.check_circle_outline;
      case GroceryStoreStatus.stale:
        return Icons.schedule_outlined;
      case GroceryStoreStatus.partial:
        return Icons.warning_amber_outlined;
      case GroceryStoreStatus.failed:
        return Icons.error_outline;
    }
  }

  Widget _buildCategory(String category, List<Product> items,
      {bool isFirst = false}) {
    final catColor = _categoryColor(category);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 8),
          child: CalmEyebrow(category.toUpperCase()),
        ),
        CalmCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildProductRow(
                    items[i],
                    catColor: catColor,
                    tourKey: isFirst && i == 0
                        ? GroceryTourKeys.productCard
                        : null,
                  ),
                ),
                if (i < items.length - 1)
                  Divider(
                    color: AppColors.line(context),
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductRow(Product product,
      {required Color catColor, GlobalKey? tourKey}) {
    final l10n = S.of(context);
    final inPantry =
        widget.weeklyPantryIds.contains(product.name.toLowerCase());

    return Semantics(
      label:
          '${product.name}, ${formatCurrency(product.avgPrice)}, ${product.unit}',
      child: SizedBox(
        key: tourKey,
        child: Row(
          children: [
            Expanded(
              child: CalmListTile(
                leadingIcon: _categoryIcon(product.category),
                leadingColor: catColor,
                title: product.name,
                subtitle: l10n.groceryAvgPrice(product.unit),
                trailing: formatCurrency(product.avgPrice),
              ),
            ),
            if (widget.onToggleWeeklyPantry != null)
              Tooltip(
                message: l10n.pantryHaveIt,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Material(
                    color: inPantry
                        ? AppColors.ok(context).withValues(alpha: 0.12)
                        : AppColors.bgSunk(context),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => widget.onToggleWeeklyPantry!(
                          product.name.toLowerCase()),
                      borderRadius: BorderRadius.circular(10),
                      child: Icon(
                        inPantry ? Icons.home : Icons.home_outlined,
                        size: 18,
                        color: inPantry
                            ? AppColors.ok(context)
                            : AppColors.ink50(context),
                      ),
                    ),
                  ),
                ),
              ),
            if (widget.onAddToShoppingList != null) ...[
              const SizedBox(width: 8),
              Semantics(
                button: true,
                label: l10n.addToList(product.name),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: Material(
                    color: AppColors.ink(context),
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => _addToCart(product),
                      borderRadius: BorderRadius.circular(12),
                      child: Icon(Icons.add,
                          size: 20, color: AppColors.bg(context)),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Stale-stores filter pill button.
  Widget _staleFilterPill() {
    return GestureDetector(
      onTap: () => setState(() => _hideStaleStores = !_hideStaleStores),
      child: CalmPill(
        label: S.of(context).groceryHideStaleStores,
        color: _hideStaleStores
            ? AppColors.warn(context)
            : AppColors.ink50(context),
      ),
    );
  }

  Widget _categoryChip(String label, bool selected, VoidCallback onTap) {
    return Semantics(
      button: true,
      label: S.of(context).filterBy(label),
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: CalmPill(
          label: label,
          color: selected
              ? AppColors.accent(context)
              : AppColors.ink50(context),
        ),
      ),
    );
  }
}
