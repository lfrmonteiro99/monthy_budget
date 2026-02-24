import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/shopping_item.dart';
import '../utils/formatters.dart';

class GroceryScreen extends StatefulWidget {
  final List<Product> products;
  final ValueChanged<ShoppingItem>? onAddToShoppingList;

  const GroceryScreen({
    super.key,
    required this.products,
    this.onAddToShoppingList,
  });

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

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

  void _addToCart(Product product) {
    if (widget.onAddToShoppingList == null) return;
    widget.onAddToShoppingList!(ShoppingItem(
      productName: product.name,
      store: '',
      price: product.avgPrice,
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} adicionado à lista'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    // Group by category preserving current filter
    final Map<String, List<Product>> byCategory = {};
    for (final p in filtered) {
      byCategory.putIfAbsent(p.category, () => []).add(p);
    }
    final cats = byCategory.keys.toList()..sort();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'Supermercado',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B)),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Pesquisar produto...',
                hintStyle:
                    const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                prefixIcon: const Icon(Icons.search,
                    color: Color(0xFF94A3B8), size: 20),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF3B82F6), width: 2),
                ),
              ),
            ),
          ),
        ),
      ),
      body: widget.products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Category filter chips
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                    children: [
                      _chip('Todos', _selectedCategory == null,
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
                        '${filtered.length} produtos',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
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
                      return _buildCategory(cat, items);
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCategory(String category, List<Product> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 6),
          child: Row(
            children: [
              Icon(_categoryIcon(category),
                  size: 14, color: const Color(0xFF3B82F6)),
              const SizedBox(width: 6),
              Text(
                category.toUpperCase(),
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF3B82F6),
                    letterSpacing: 1.1),
              ),
            ],
          ),
        ),
        ...items.map(_buildProductRow),
      ],
    );
  }

  Widget _buildProductRow(Product product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 2),
                Text(
                  '${product.unit} · preço médio',
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
          Text(
            formatCurrency(product.avgPrice),
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF10B981)),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _addToCart(product),
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

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF3B82F6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: selected
                  ? const Color(0xFF3B82F6)
                  : const Color(0xFFE2E8F0)),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color:
                  selected ? Colors.white : const Color(0xFF64748B)),
        ),
      ),
    );
  }
}
