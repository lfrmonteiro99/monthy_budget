import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'models/app_settings.dart';
import 'models/grocery_data.dart';
import 'models/product.dart';
import 'models/shopping_item.dart';
import 'models/purchase_record.dart';
import 'utils/calculations.dart';
import 'services/settings_service.dart';
import 'services/grocery_service.dart';
import 'services/favorites_service.dart';
import 'services/shopping_list_service.dart';
import 'services/purchase_history_service.dart';
import 'services/products_service.dart';
import 'services/household_service.dart';
import 'services/expense_snapshot_service.dart';
import 'services/local_config_service.dart';
import 'models/local_dashboard_config.dart';
import 'models/expense_snapshot.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/coach_screen.dart';
import 'screens/meal_planner_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/grocery_screen.dart';
import 'screens/auth/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const OrcamentoMensalApp());
}

class OrcamentoMensalApp extends StatelessWidget {
  const OrcamentoMensalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestão Mensal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF3B82F6),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: AuthGate(
        appBuilder: (profile) => AppHome(
          householdId: profile.householdId,
          isAdmin: profile.role == 'admin',
        ),
      ),
    );
  }
}

class AppHome extends StatefulWidget {
  final String householdId;
  final bool isAdmin;

  const AppHome({
    super.key,
    required this.householdId,
    required this.isAdmin,
  });

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> with WidgetsBindingObserver {
  final _settingsService = SettingsService();
  final _groceryService = GroceryService();
  final _favoritesService = FavoritesService();
  final _shoppingListService = ShoppingListService();
  final _purchaseHistoryService = PurchaseHistoryService();
  final _productsService = ProductsService();
  final _expenseSnapshotService = ExpenseSnapshotService();
  final _localConfigService = LocalConfigService();

  AppSettings _settings = const AppSettings();
  GroceryData _groceryData = const GroceryData();
  List<Product> _products = [];
  List<String> _favorites = [];
  List<ShoppingItem> _shoppingList = [];
  PurchaseHistory _purchaseHistory = const PurchaseHistory();
  LocalDashboardConfig _dashboardConfig = const LocalDashboardConfig();
  Map<String, List<ExpenseSnapshot>> _expenseHistory = {};
  bool _loaded = false;
  int _currentIndex = 0;

  late StreamSubscription<List<ShoppingItem>> _shoppingListSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _shoppingListSub = _shoppingListService
        .stream(widget.householdId)
        .listen((items) => setState(() => _shoppingList = items));
    _loadAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shoppingListSub.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshData();
  }

  /// Lightweight refresh of household-synced data — called on app resume.
  Future<void> _refreshData() async {
    if (!mounted) return;
    final results = await Future.wait([
      _settingsService.load(widget.householdId),
      _favoritesService.load(widget.householdId),
      _purchaseHistoryService.load(widget.householdId),
    ]);
    if (mounted) {
      setState(() {
        _settings = results[0] as AppSettings;
        _favorites = results[1] as List<String>;
        _purchaseHistory = results[2] as PurchaseHistory;
      });
    }
    _expenseSnapshotService.loadHistory(widget.householdId).then((history) {
      if (mounted) setState(() => _expenseHistory = history);
    });
  }

  Future<void> _loadAll() async {
    final results = await Future.wait([
      _settingsService.load(widget.householdId),
      _groceryService.load(),
      _favoritesService.load(widget.householdId),
      _purchaseHistoryService.load(widget.householdId),
      _productsService.load(),
      _localConfigService.load(),
    ]);
    setState(() {
      _settings = results[0] as AppSettings;
      _groceryData = results[1] as GroceryData;
      _favorites = results[2] as List<String>;
      _purchaseHistory = results[3] as PurchaseHistory;
      _products = results[4] as List<Product>;
      _dashboardConfig = results[5] as LocalDashboardConfig;
      _loaded = true;
    });
    _expenseSnapshotService.loadHistory(widget.householdId).then((history) {
      if (mounted) setState(() => _expenseHistory = history);
    });
  }

  void _saveSettings(AppSettings settings) {
    if (!widget.isAdmin) return;
    setState(() => _settings = settings);
    _settingsService.save(settings, widget.householdId);
  }

  void _saveDashboardConfig(LocalDashboardConfig config) {
    setState(() => _dashboardConfig = config);
    _localConfigService.save(config);
  }

  void _snapshotExpenses() {
    final now = DateTime.now();
    final monthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    _expenseSnapshotService
        .snapshotIfNeeded(widget.householdId, monthKey, _settings.expenses)
        .then((_) => _expenseSnapshotService.loadHistory(widget.householdId))
        .then((history) {
      if (mounted) setState(() => _expenseHistory = history);
    });
  }

  void _saveFavorites(List<String> favorites) {
    setState(() => _favorites = favorites);
    _favoritesService.save(favorites, widget.householdId);
  }

  void _addToShoppingList(ShoppingItem item) async {
    final exists = _shoppingList.any(
      (e) => e.productName == item.productName,
    );
    if (exists) return;
    await _shoppingListService.add(item, widget.householdId);
  }

  void _toggleShoppingItem(ShoppingItem item) async {
    if (item.id.isEmpty) return;
    // Optimistic: update local state immediately, don't wait for Realtime
    setState(() {
      _shoppingList = _shoppingList.map((i) {
        if (i.id != item.id) return i;
        return ShoppingItem(
          id: i.id,
          productName: i.productName,
          store: i.store,
          price: i.price,
          unitPrice: i.unitPrice,
          checked: !i.checked,
        );
      }).toList();
    });
    try {
      await _shoppingListService.toggle(item.id, !item.checked);
    } catch (_) {
      // Revert on failure — Realtime will correct on next emission anyway
      setState(() {
        _shoppingList = _shoppingList.map((i) {
          if (i.id != item.id) return i;
          return ShoppingItem(
            id: i.id,
            productName: i.productName,
            store: i.store,
            price: i.price,
            unitPrice: i.unitPrice,
            checked: item.checked,
          );
        }).toList();
      });
    }
  }

  void _removeShoppingItem(ShoppingItem item) async {
    if (item.id.isEmpty) return;
    // Dismissible already removes it from view; fire-and-forget
    _shoppingListService.remove(item.id);
  }

  void _clearCheckedItems() async {
    // Optimistic: remove checked items locally immediately
    setState(() {
      _shoppingList = _shoppingList.where((i) => !i.checked).toList();
    });
    await _shoppingListService.clearChecked(widget.householdId);
  }

  Future<void> _finalizeShopping(
      double? amount, List<ShoppingItem> checkedItems) async {
    if (checkedItems.isEmpty) return;
    try {
      final estimated = checkedItems.fold(0.0, (s, i) => s + i.price);
      final totalAmount =
          (amount != null && amount > 0) ? amount : estimated;
      final record = PurchaseRecord(
        id: 'purchase_${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now(),
        amount: totalAmount,
        itemCount: checkedItems.length,
        items: checkedItems.map((i) => i.productName).toList(),
      );
      await _purchaseHistoryService.saveRecord(record, widget.householdId);
      await _shoppingListService.clearChecked(widget.householdId);
      final updated =
          PurchaseHistory(records: [record, ..._purchaseHistory.records]);
      if (mounted) {
        setState(() {
          _purchaseHistory = updated;
          _shoppingList = _shoppingList.where((i) => !i.checked).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao guardar compra: $e'),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  SettingsScreen _buildSettingsScreen() {
    return SettingsScreen(
      settings: _settings,
      onSave: _saveSettings,
      favorites: _favorites,
      onSaveFavorites: _saveFavorites,
      isAdmin: widget.isAdmin,
      householdId: widget.householdId,
      products: _products,
      dashboardConfig: _dashboardConfig,
      onSaveDashboardConfig: _saveDashboardConfig,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Semantics(
            label: 'A carregar a aplicação',
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF3B82F6)),
                SizedBox(height: 16),
                Text(
                  'A carregar...',
                  style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final summary = calculateBudgetSummary(
      _settings.salaries,
      _settings.personalInfo,
      _settings.expenses,
    );

    final screens = [
      DashboardScreen(
        settings: _settings,
        summary: summary,
        purchaseHistory: _purchaseHistory,
        onSaveSettings: _saveSettings,
        dashboardConfig: _dashboardConfig,
        expenseHistory: _expenseHistory,
        onSnapshotExpenses: _snapshotExpenses,
        onOpenSettings: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => _buildSettingsScreen()),
          );
        },
      ),
      GroceryScreen(
        products: _products,
        onAddToShoppingList: _addToShoppingList,
      ),
      ShoppingListScreen(
        items: _shoppingList,
        onToggleChecked: _toggleShoppingItem,
        onRemove: _removeShoppingItem,
        onClearChecked: _clearCheckedItems,
        onFinalize: _finalizeShopping,
        purchaseHistory: _purchaseHistory,
      ),
      CoachScreen(
        settings: _settings,
        purchaseHistory: _purchaseHistory,
        householdId: widget.householdId,
        onOpenSettings: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => _buildSettingsScreen()),
          );
        },
      ),
      MealPlannerScreen(
        settings: _settings,
        favorites: _favorites,
        onAddToShoppingList: _addToShoppingList,
        householdId: widget.householdId,
        onSaveSettings: _saveSettings,
        onOpenMealSettings: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SettingsScreen(
              settings: _settings,
              onSave: _saveSettings,
              favorites: _favorites,
              onSaveFavorites: _saveFavorites,
              isAdmin: widget.isAdmin,
              householdId: widget.householdId,
              products: _products,
              dashboardConfig: _dashboardConfig,
              onSaveDashboardConfig: _saveDashboardConfig,
              initialSection: 'meals',
            ),
          ),
        ),
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFDBEAFE),
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Color(0xFF3B82F6)),
            label: 'Orçamento',
            tooltip: 'Resumo do orçamento mensal',
          ),
          const NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon:
                Icon(Icons.shopping_cart, color: Color(0xFF3B82F6)),
            label: 'Supermercado',
            tooltip: 'Catálogo de produtos',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _shoppingList.any((i) => !i.checked),
              label: Text(
                '${_shoppingList.where((i) => !i.checked).length}',
                style: const TextStyle(fontSize: 10),
              ),
              child: const Icon(Icons.shopping_basket_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: _shoppingList.any((i) => !i.checked),
              label: Text(
                '${_shoppingList.where((i) => !i.checked).length}',
                style: const TextStyle(fontSize: 10),
              ),
              child: const Icon(Icons.shopping_basket,
                  color: Color(0xFF3B82F6)),
            ),
            label: 'Lista',
            tooltip: 'Lista de compras',
          ),
          const NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology, color: Color(0xFF3B82F6)),
            label: 'Coach',
            tooltip: 'Coach financeiro com IA',
          ),
          const NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon:
                Icon(Icons.restaurant, color: Color(0xFF3B82F6)),
            label: 'Refeições',
            tooltip: 'Planeador de refeições',
          ),
        ],
      ),
    );
  }
}
