import 'package:flutter/material.dart';
import 'models/app_settings.dart';
import 'models/grocery_data.dart';
import 'utils/calculations.dart';
import 'services/settings_service.dart';
import 'services/grocery_service.dart';
import 'services/favorites_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/grocery_screen.dart';
import 'screens/meal_plan_screen.dart';

void main() {
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
      home: const AppHome(),
    );
  }
}

class AppHome extends StatefulWidget {
  const AppHome({super.key});

  @override
  State<AppHome> createState() => _AppHomeState();
}

class _AppHomeState extends State<AppHome> {
  final _settingsService = SettingsService();
  final _groceryService = GroceryService();
  final _favoritesService = FavoritesService();
  AppSettings _settings = const AppSettings();
  GroceryData _groceryData = const GroceryData();
  List<String> _favorites = [];
  bool _loaded = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final results = await Future.wait([
      _settingsService.load(),
      _groceryService.load(),
      _favoritesService.load(),
    ]);
    setState(() {
      _settings = results[0] as AppSettings;
      _groceryData = results[1] as GroceryData;
      _favorites = results[2] as List<String>;
      _loaded = true;
    });
  }

  void _saveSettings(AppSettings settings) {
    setState(() {
      _settings = settings;
    });
    _settingsService.save(settings);
  }

  void _saveFavorites(List<String> favorites) {
    setState(() {
      _favorites = favorites;
    });
    _favoritesService.save(favorites);
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
                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14, fontWeight: FontWeight.w500),
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
        onOpenSettings: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SettingsScreen(
                settings: _settings,
                onSave: _saveSettings,
                favorites: _favorites,
                onSaveFavorites: _saveFavorites,
              ),
            ),
          );
        },
      ),
      MealPlanScreen(
        settings: _settings,
      ),
      GroceryScreen(
        groceryData: _groceryData,
        favorites: _favorites,
        onFavoritesChanged: _saveFavorites,
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: Color(0xFF3B82F6)),
            label: 'Orcamento',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu, color: Color(0xFF3B82F6)),
            label: 'Refeicoes',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart, color: Color(0xFF3B82F6)),
            label: 'Supermercados',
          ),
        ],
      ),
    );
  }
}
