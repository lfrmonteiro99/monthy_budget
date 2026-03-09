import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/grocery_data.dart';
import '../models/product.dart';
import '../models/shopping_item.dart';
import '../services/barcode_scan_service.dart';
import '../theme/app_colors.dart';
import '../utils/formatters.dart';
import '../widgets/barcode_result_card.dart';
import '../widgets/barcode_scan_sheet.dart';
import '../onboarding/grocery_tour.dart';

class GroceryScreen extends StatefulWidget {
  final List<Product> products;
  final GroceryData? groceryData;
  final String marketCode;
  final ValueChanged<ShoppingItem>? onAddToShoppingList;
  final bool showTour;
  final VoidCallback? onTourComplete;
  final BarcodeScanService? barcodeScanService;
  final Set<String> weeklyPantryIds;
  final ValueChanged<String>? onToggleWeeklyPantry;

  const GroceryScreen({
    super.key,
    required this.products,
    this.groceryData,
    this.marketCode = 'PT',
    this.onAddToShoppingList,
    this.showTour = false,
    this.onTourComplete,
    this.barcodeScanService,
    this.weeklyPantryIds = const {},
    this.onToggleWeeklyPantry,
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
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      buildGroceryTour(
        context: context,
        onFinish: () => widget.onTourComplete?.call(),
        onSkip: () => widget.onTourComplete?.call(),
      ).show(context: context);
    });
  }

  List<String> get _categories {
    final cats = widget.products.map((p) => p.category).toSet().toList();
    cats.sort();
    return cats;
  }

  List<Product> get _filtered {
    var list = widget.products;
    if (_selectedCategory != null) {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  GroceryData get _groceryData => widget.groceryData ?? const GroceryData();

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

  Future<void> _onScanBarcode() async {
    final barcode = await BarcodeScanSheet.show(context);
    if (barcode == null || !mounted) return;

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
        duration: const Duration(seconds: 2),
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

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surface(context),
        surfaceTintColor: AppColors.surface(context),
        title: Text(
          l10n.groceryTitle,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context)),
        ),
        actions: [
          if (widget.onAddToShoppingList != null)
            IconButton(
              icon: Icon(Icons.qr_code_scanner,
                  color: AppColors.textSecondary(context)),
              tooltip: l10n.barcodeScanTooltip,
              onPressed: _onScanBarcode,
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              key: GroceryTourKeys.searchBar,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: l10n.grocerySearchHint,
                hintStyle:
                    TextStyle(color: AppColors.textMuted(context), fontSize: 14),
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
        ),
      ),
      body: widget.products.isEmpty
          ? Center(
              child: Semantics(
                label: l10n.groceryLoadingLabel,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary(context)),
                    const SizedBox(height: 16),
                    Text(
                      l10n.groceryLoadingMessage,
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary(context)),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                if (_groceryData.hasStoreStatuses)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _buildMarketStatusCard(),
                  ),
                // Category filter chips
                SizedBox(
                  key: GroceryTourKeys.categoryFilter,
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                    children: [
                      _chip(l10n.groceryAll, _selectedCategory == null,
                          () => setState(() => _selectedCategory = null)),
                      ..._categories.map((cat) => Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: _chip(
                              cat,
                              _selectedCategory == cat,
                              () => setState(() => _selectedCategory == cat
                                  ? _selectedCategory = null
                                  : _selectedCategory = cat),
                            ),
                          )),
                    ],
                  ),
                ),
                // Count
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        l10n.groceryProductCount(filtered.length),
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textMuted(context),
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                // Product list grouped by category
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: cats.length,
                    itemBuilder: (_, i) {
                      final cat = cats[i];
                      final items = byCategory[cat]!;
                      return _buildCategory(cat, items, isFirst: i == 0);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategory(String category, List<Product> items, {bool isFirst = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Row(
            children: [
              Icon(_categoryIcon(category),
                  size: 14, color: AppColors.primary(context)),
              const SizedBox(width: 6),
              Text(
                category.toUpperCase(),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary(context),
                    letterSpacing: 1.1),
              ),
            ],
          ),
        ),
        ...items.asMap().entries.map((e) =>
          _buildProductRow(e.value, tourKey: isFirst && e.key == 0 ? GroceryTourKeys.productCard : null)),
      ],
    );
  }

  Widget _buildMarketStatusCard() {
    final l10n = S.of(context);
    final activeStores = _groceryData.freshStoreCount;
    final totalStores = _groceryData.storeStatuses.length;
    final visibleComparisons =
        _groceryData.filterComparisons(hideStaleStores: _hideStaleStores);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.groceryMarketData(widget.marketCode),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.groceryStoreCoverage(activeStores, totalStores),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary(context),
            ),
          ),
          if (_groceryData.hasDegradedStores) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _statusPill(
                  l10n.groceryStoreFreshCount(_groceryData.freshStoreCount),
                  AppColors.successBackground(context),
                  AppColors.success(context),
                ),
                if (_groceryData.partialStoreCount > 0)
                  _statusPill(
                    l10n.groceryStorePartialCount(_groceryData.partialStoreCount),
                    AppColors.warningBackground(context),
                    AppColors.warning(context),
                  ),
                if (_groceryData.failedStoreCount > 0)
                  _statusPill(
                    l10n.groceryStoreFailedCount(_groceryData.failedStoreCount),
                    AppColors.errorBackground(context),
                    AppColors.error(context),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => setState(() => _hideStaleStores = !_hideStaleStores),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Checkbox(
                      value: _hideStaleStores,
                      onChanged: (value) => setState(() => _hideStaleStores = value ?? false),
                    ),
                    Expanded(
                      child: Text(
                        l10n.groceryHideStaleStores,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text(
              l10n.groceryComparisonsFreshOnly(
                _hideStaleStores ? activeStores : visibleComparisons.isEmpty ? 0 : visibleComparisons.first.prices.length,
              ),
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusPill(String label, Color backgroundColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildProductRow(Product product, {GlobalKey? tourKey}) {
    final l10n = S.of(context);
    return Semantics(
      label: '${product.name}, ${formatCurrency(product.avgPrice)}, ${product.unit}',
      child: Container(
      key: tourKey,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary(context)),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.groceryAvgPrice(product.unit),
                  style: TextStyle(
                      fontSize: 11, color: AppColors.textMuted(context)),
                ),
              ],
            ),
          ),
          Text(
            formatCurrency(product.avgPrice),
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.success(context)),
          ),
          const SizedBox(width: 10),
          if (widget.onToggleWeeklyPantry != null)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Tooltip(
                message: l10n.pantryHaveIt,
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Material(
                    color: widget.weeklyPantryIds.contains(product.name.toLowerCase())
                        ? AppColors.successBackground(context)
                        : AppColors.surfaceVariant(context),
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: () => widget.onToggleWeeklyPantry!(product.name.toLowerCase()),
                      borderRadius: BorderRadius.circular(10),
                      child: Icon(
                        widget.weeklyPantryIds.contains(product.name.toLowerCase())
                            ? Icons.home
                            : Icons.home_outlined,
                        size: 18,
                        color: widget.weeklyPantryIds.contains(product.name.toLowerCase())
                            ? AppColors.success(context)
                            : AppColors.textMuted(context),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Semantics(
            button: true,
            label: l10n.addToList(product.name),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Material(
                color: AppColors.primary(context),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => _addToCart(product),
                  borderRadius: BorderRadius.circular(12),
                  child: Icon(Icons.add, size: 20, color: AppColors.onPrimary(context)),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Semantics(
      button: true,
      label: S.of(context).filterBy(label),
      selected: selected,
      child: Material(
        color: selected ? AppColors.primary(context) : AppColors.surface(context),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: selected
                      ? AppColors.primary(context)
                      : AppColors.border(context)),
            ),
            child: Text(
              label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color:
                      selected ? AppColors.onPrimary(context) : AppColors.textSecondary(context)),
            ),
          ),
        ),
      ),
    );
  }
}
