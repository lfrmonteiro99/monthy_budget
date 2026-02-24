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
import 'services/ai_coach_service.dart';
import 'services/purchase_history_service.dart';
import 'services/products_service.dart';
import 'services/household_service.dart';
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
      title: 'Orcamento Mensal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF3B82F6),
        useMaterial3: true,
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

class _AppHomeState extends State<AppHome> {
  final _settingsService = SettingsService();
  final _groceryService = GroceryService();
  final _favoritesService = FavoritesService();
  final _shoppingListService = ShoppingListService();
  final _aiCoachService = AiCoachService();
  final _purchaseHistoryService = PurchaseHistoryService();
  final _productsService = ProductsService();

  AppSettings _settings = const AppSettings();
  GroceryData _groceryData = const GroceryData();
  List<Product> _products = [];
  List<String> _favorites = [];
  List<ShoppingItem> _shoppingList = [];
  String _openAiApiKey = '';
  PurchaseHistory _purchaseHistory = const PurchaseHistory();
  bool _loaded = false;
  int _currentIndex = 0;

  late StreamSubscription<List<ShoppingItem>> _shoppingListSub;

  @override
  void initState() {
    super.initState();
    _shoppingListSub = _shoppingListService
        .stream(widget.householdId)
        .listen((items) => setState(() => _shoppingList = items));
    _loadAll();
  }

  @override
  void dispose() {
    _shoppingListSub.cancel();
    super.dispose();
  }

  Future<void> _loadAll() async {
    final results = await Future.wait([
      _settingsService.load(widget.householdId),
      _groceryService.load(),
      _favoritesService.load(widget.householdId),
      _purchaseHistoryService.load(widget.householdId),
      _aiCoachService.loadApiKey(),
      _productsService.load(),
    ]);
    setState(() {
      _settings = results[0] as AppSettings;
      _groceryData = results[1] as GroceryData;
      _favorites = results[2] as List<String>;
      _purchaseHistory = results[3] as PurchaseHistory;
      _openAiApiKey = results[4] as String;
      _products = results[5] as List<Product>;
      _loaded = true;
    });
  }

  void _saveSettings(AppSettings settings) {
    if (!widget.isAdmin) return;
    setState(() => _settings = settings);
    _settingsService.save(settings, widget.householdId);
  }

  void _saveFavorites(List<String> favorites) {
    setState(() => _favorites = favorites);
    _favoritesService.save(favorites, widget.householdId);
  }

  void _saveApiKey(String key) {
    setState(() => _openAiApiKey = key);
    _aiCoachService.saveApiKey(key);
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
    await _shoppingListService.toggle(item.id, !item.checked);
  }

  void _removeShoppingItem(ShoppingItem item) async {
    if (item.id.isEmpty) return;
    await _shoppingListService.remove(item.id);
  }

  void _clearCheckedItems() async {
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
          PurchaseHistory(records: [..._purchaseHistory.records, record]);
      if (mounted) setState(() => _purchaseHistory = updated);
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
      apiKey: _openAiApiKey,
      onSaveApiKey: _saveApiKey,
      isAdmin: widget.isAdmin,
      householdId: widget.householdId,
      products: _products,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF3B82F6)),
              SizedBox(height: 16),
              Text(
                'A carregar...',
                style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
              ),
            ],
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
      ),
      CoachScreen(
        settings: _settings,
        groceryData: _groceryData,
        apiKey: _openAiApiKey,
        onOpenSettings: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => _buildSettingsScreen()),
          );
        },
      ),
      MealPlannerScreen(
        settings: _settings,
        apiKey: _openAiApiKey,
        favorites: _favorites,
        onAddToShoppingList: _addToShoppingList,
        householdId: widget.householdId,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFDBEAFE),
        height: 64,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Color(0xFF3B82F6)),
            label: 'Orcamento',
          ),
          const NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon:
                Icon(Icons.shopping_cart, color: Color(0xFF3B82F6)),
            label: 'Supermercado',
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
          ),
          const NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology, color: Color(0xFF3B82F6)),
            label: 'Coach',
          ),
          const NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon:
                Icon(Icons.restaurant, color: Color(0xFF3B82F6)),
            label: 'Refeicoes',
          ),
        ],
      ),
    );
  }
}
