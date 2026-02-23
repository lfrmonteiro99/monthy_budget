import 'package:flutter/material.dart';
import '../models/grocery_data.dart';
import '../models/shopping_item.dart';
import '../utils/formatters.dart';

class GroceryScreen extends StatefulWidget {
  final GroceryData groceryData;
  final List<String> favorites;
  final ValueChanged<List<String>> onFavoritesChanged;
  final ValueChanged<ShoppingItem>? onAddToShoppingList;

  const GroceryScreen({
    super.key,
    required this.groceryData,
    required this.favorites,
    required this.onFavoritesChanged,
    this.onAddToShoppingList,
  });

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String? _selectedCategory;
  bool _showFavoritesOnly = false;
  final Set<String> _expandedCategories = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _isFavorite(String productName) {
    final lower = productName.toLowerCase();
    return widget.favorites.any((fav) => lower.contains(fav.toLowerCase()));
  }

  void _toggleFavoriteFromProduct(String productName) {
    final lower = productName.toLowerCase();
    final matchIdx = widget.favorites.indexWhere((f) => lower.contains(f.toLowerCase()));
    final updated = List<String>.from(widget.favorites);
    if (matchIdx >= 0) {
      updated.removeAt(matchIdx);
    } else {
      final words = productName.split(RegExp(r'\s+'))
          .where((w) => w.length > 2)
          .take(3)
          .join(' ');
      if (words.isNotEmpty) updated.add(words);
    }
    widget.onFavoritesChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Comparador de Precos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
            ),
            Text(
              'SUPERMERCADOS',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8), letterSpacing: 1.2),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF3B82F6),
          unselectedLabelColor: const Color(0xFF94A3B8),
          indicatorColor: const Color(0xFF3B82F6),
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Ranking'),
            Tab(text: 'Comparar'),
            Tab(text: 'Categorias'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRankingTab(),
          _buildComparisonTab(),
          _buildCategoryTab(),
        ],
      ),
    );
  }

  // ─── Tab 1: DECO PROteste Store Rankings ─────────────────────────

  Widget _buildRankingTab() {
    final rankings = widget.groceryData.decoIndex.rankings;
    if (rankings.isEmpty) return _buildEmptyState('Sem dados de ranking disponíveis.');

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildInfoCard(
          icon: Icons.info_outline,
          title: 'Índice DECO PROteste',
          subtitle: 'Baseado num cabaz de ${widget.groceryData.decoIndex.basketSize} produtos. '
              'O supermercado mais barato recebe índice 100.',
        ),
        const SizedBox(height: 16),
        ...rankings.map((r) => _buildRankingCard(r, rankings.first.index)),
      ],
    );
  }

  Widget _buildRankingCard(StoreRanking ranking, int bestIndex) {
    final isBest = ranking.index == bestIndex;
    final diff = ranking.index - bestIndex;
    final diffText = diff == 0 ? 'Mais barato' : '+$diff%';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isBest ? const Color(0xFF10B981) : const Color(0xFFF1F5F9),
          width: isBest ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isBest ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '#${ranking.rank}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isBest ? const Color(0xFF059669) : const Color(0xFF64748B),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ranking.store,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Índice: ${ranking.index}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isBest ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              diffText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isBest ? const Color(0xFF059669) : const Color(0xFFDC2626),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Tab 2: Product Price Comparisons ─────────────────────────────

  Widget _buildComparisonTab() {
    final comparisons = widget.groceryData.comparisons;
    if (comparisons.isEmpty) {
      return _buildEmptyState(
        'Sem comparacoes de produtos disponíveis.\n'
        'Os scrapers serao executados diariamente as 06:00.',
      );
    }

    // Filter by search
    var filtered = _searchQuery.isEmpty
        ? comparisons
        : comparisons.where((c) => c.productName.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    // Separate favorites from rest
    final favItems = filtered.where((c) => _isFavorite(c.productName)).toList();
    final otherItems = filtered.where((c) => !_isFavorite(c.productName)).toList();

    // When toggle is on, show only favorites
    final displayItems = _showFavoritesOnly ? favItems : [...favItems, ...otherItems];
    final hasFavorites = widget.favorites.isNotEmpty;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: 'Pesquisar produto...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(Icons.savings, size: 14, color: Colors.green.shade400),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${filtered.length} produtos comparáveis',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                ),
              ),
              if (hasFavorites)
                GestureDetector(
                  onTap: () => setState(() => _showFavoritesOnly = !_showFavoritesOnly),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _showFavoritesOnly
                          ? const Color(0xFFEF4444).withValues(alpha: 0.08)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _showFavoritesOnly
                            ? const Color(0xFFEF4444).withValues(alpha: 0.4)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
                          size: 13,
                          color: _showFavoritesOnly ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Favoritos',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _showFavoritesOnly ? const Color(0xFFEF4444) : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: displayItems.length + (hasFavorites && !_showFavoritesOnly && favItems.isNotEmpty && otherItems.isNotEmpty ? 1 : 0),
            itemBuilder: (_, i) {
              final separatorIndex = favItems.length;
              if (hasFavorites && !_showFavoritesOnly && favItems.isNotEmpty && otherItems.isNotEmpty && i == separatorIndex) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(child: Container(height: 1, color: const Color(0xFFE2E8F0))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'OUTROS PRODUTOS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade400,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Expanded(child: Container(height: 1, color: const Color(0xFFE2E8F0))),
                    ],
                  ),
                );
              }
              final idx = (hasFavorites && !_showFavoritesOnly && favItems.isNotEmpty && otherItems.isNotEmpty && i > separatorIndex)
                  ? i - 1
                  : i;
              return _buildComparisonCard(displayItems[idx]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonCard(ProductComparison comparison) {
    final isFav = _isFavorite(comparison.productName);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isFav ? const Color(0xFFFFF5F5) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFav ? const Color(0xFFEF4444).withValues(alpha: 0.2) : const Color(0xFFF1F5F9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  comparison.productName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              if (comparison.potentialSavings > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Poupa ${formatCurrency(comparison.potentialSavings)}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF059669)),
                  ),
                ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () => _toggleFavoriteFromProduct(comparison.productName),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    size: 20,
                    color: isFav ? const Color(0xFFEF4444) : const Color(0xFFCBD5E1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...comparison.prices.map((sp) {
            final isCheapest = sp.store == comparison.cheapestStore;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(
                    isCheapest ? Icons.check_circle : Icons.circle_outlined,
                    size: 16,
                    color: isCheapest ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sp.store,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isCheapest ? FontWeight.w600 : FontWeight.w400,
                        color: isCheapest ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                  Text(
                    formatCurrency(sp.price),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isCheapest ? const Color(0xFF10B981) : const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── Tab 3: Category Average Prices ───────────────────────────────

  Widget _buildCategoryTab() {
    final categories = widget.groceryData.categorySummary;
    if (categories.isEmpty) {
      return _buildEmptyState(
        'Sem dados de categorias disponíveis.\n'
        'Os scrapers serao executados diariamente as 06:00.',
      );
    }

    final categoryNames = categories.map((c) => c.category).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('Todas', _selectedCategory == null, () {
                  setState(() => _selectedCategory = null);
                }),
                ...categoryNames.map((name) => Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: _buildFilterChip(name, _selectedCategory == name, () {
                        setState(() => _selectedCategory = name);
                      }),
                    )),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: categories
                .where((c) => _selectedCategory == null || c.category == _selectedCategory)
                .map((cat) => _buildCategoryCard(cat))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(CategorySummary category) {
    final storeEntries = category.stores.entries.toList()
      ..sort((a, b) => a.value.avgPrice.compareTo(b.value.avgPrice));
    final isExpanded = _expandedCategories.contains(category.category);

    final categoryProducts = widget.groceryData.products
        .where((p) => p.category == category.category)
        .toList()
      ..sort((a, b) => a.price.compareTo(b.price));

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() {
              if (isExpanded) {
                _expandedCategories.remove(category.category);
              } else {
                _expandedCategories.add(category.category);
              }
            }),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(_categoryIcon(category.category), size: 18, color: const Color(0xFF3B82F6)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.category,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                            ),
                            Text(
                              'Mais barato: ${category.cheapestStore}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: const Color(0xFF94A3B8),
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...storeEntries.map((entry) {
                    final isCheapest = entry.key == category.cheapestStore;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isCheapest ? FontWeight.w600 : FontWeight.w400,
                                color: isCheapest ? const Color(0xFF1E293B) : const Color(0xFF64748B),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: storeEntries.isNotEmpty && storeEntries.last.value.avgPrice > 0
                                    ? entry.value.avgPrice / storeEntries.last.value.avgPrice
                                    : 0,
                                backgroundColor: const Color(0xFFF1F5F9),
                                valueColor: AlwaysStoppedAnimation(
                                  isCheapest ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                                ),
                                minHeight: 8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            formatCurrency(entry.value.avgPrice),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isCheapest ? const Color(0xFF10B981) : const Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '${storeEntries.fold<int>(0, (sum, e) => sum + e.value.productCount)} produtos analisados',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            if (categoryProducts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Sem produtos individuais disponíveis.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              )
            else
              ...categoryProducts.map((product) => _buildProductRow(product)),
          ],
        ],
      ),
    );
  }

  Widget _buildProductRow(GroceryProduct product) {
    final storeColor = _storeColor(product.store);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: storeColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: storeColor.withValues(alpha: 0.25)),
            ),
            child: Text(
              product.store,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: storeColor, letterSpacing: 0.2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              product.name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatCurrency(product.price),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF10B981)),
          ),
          const SizedBox(width: 10),
          if (widget.onAddToShoppingList != null)
            GestureDetector(
              onTap: () {
                widget.onAddToShoppingList!(ShoppingItem(
                  productName: product.name,
                  store: product.store,
                  price: product.price,
                  unitPrice: product.unitPrice,
                ));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} adicionado à lista'),
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add, size: 18, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Color _storeColor(String store) {
    switch (store.toLowerCase()) {
      case 'auchan': return const Color(0xFFDC2626);
      case 'pingo doce': return const Color(0xFF16A34A);
      case 'continente': return const Color(0xFF2563EB);
      case 'froiz': return const Color(0xFF7C3AED);
      case 'intermarché': return const Color(0xFFD97706);
      case 'minipreço': return const Color(0xFFEA580C);
      default: return const Color(0xFF64748B);
    }
  }

  // ─── Shared Widgets ────────────────────────────────────────────────

  Widget _buildInfoCard({required IconData icon, required String title, required String subtitle}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF3B82F6)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3B82F6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? const Color(0xFF3B82F6) : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    final map = {
      'Lacticínios e Ovos': Icons.egg,
      'Carne': Icons.restaurant,
      'Peixe': Icons.set_meal,
      'Peixe e Marisco': Icons.set_meal,
      'Frutas e Legumes': Icons.eco,
      'Padaria e Pastelaria': Icons.bakery_dining,
      'Mercearia': Icons.shopping_basket,
      'Bebidas': Icons.local_drink,
      'Congelados': Icons.ac_unit,
      'Higiene e Beleza': Icons.spa,
      'Limpeza': Icons.cleaning_services,
      'Limpeza e Arrumação': Icons.cleaning_services,
    };
    return map[category] ?? Icons.category;
  }
}
