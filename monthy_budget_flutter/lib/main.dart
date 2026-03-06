import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/generated/app_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_public_config.dart';
import 'models/app_settings.dart';
import 'models/product.dart';
import 'models/shopping_item.dart';
import 'models/purchase_record.dart';
import 'utils/calculations.dart';
import 'utils/formatters.dart';
import 'data/tax/tax_factory.dart';
import 'services/settings_service.dart';
import 'services/favorites_service.dart';
import 'services/shopping_list_service.dart';
import 'services/ai_coach_service.dart';
import 'services/purchase_history_service.dart';
import 'services/products_service.dart';
import 'services/expense_snapshot_service.dart';
import 'services/local_config_service.dart';
import 'services/actual_expense_service.dart';
import 'services/monthly_budget_service.dart';
import 'models/actual_expense.dart';
import 'models/monthly_budget.dart';
import 'widgets/add_expense_sheet.dart';
import 'screens/expense_tracker_screen.dart';
import 'models/local_dashboard_config.dart';
import 'models/expense_snapshot.dart';
import 'screens/shopping_list_screen.dart';
import 'screens/coach_screen.dart';
import 'screens/meal_planner_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/grocery_screen.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/setup_wizard_screen.dart';
import 'screens/expense_trends_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/more_screen.dart';
import 'screens/plan_hub_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'models/recurring_expense.dart';
import 'models/notification_preferences.dart';
import 'services/recurring_expense_service.dart';
import 'services/notification_service.dart';
import 'services/savings_goal_service.dart';
import 'models/savings_goal.dart';
import 'screens/savings_goals_screen.dart';
import 'screens/tax_simulator_screen.dart';
import 'utils/savings_projections.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'models/onboarding_state.dart';
import 'models/subscription_state.dart';
import 'services/subscription_service.dart';
import 'screens/welcome_slideshow_screen.dart';
import 'screens/paywall_screen.dart';
import 'widgets/trial_banner.dart';
import 'widgets/feature_discovery_card.dart';
import 'services/ad_service.dart';
import 'services/revenuecat_service.dart';
import 'widgets/ad_banner_widget.dart';
import 'widgets/branded_loading.dart';
import 'services/command_chat_service.dart';
import 'services/command_pattern_cache.dart';
import 'services/command_action_registry.dart';
import 'models/command_action.dart';
import 'widgets/command_chat_fab.dart';
import 'widgets/command_chat_panel.dart';

/// Global notifier for reactive locale changes from settings.
final appLocaleNotifier = ValueNotifier<Locale?>(null);

/// Global notifier for reactive theme changes.
final appThemeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);

/// Global notifier for reactive color palette changes.
final appColorPaletteNotifier =
    ValueNotifier<AppColorPalette>(AppColorPalette.ocean);

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  final configService = LocalConfigService();
  final savedTheme = await configService.loadThemeMode();
  final savedPalette = await configService.loadColorPalette();
  appThemeModeNotifier.value = savedTheme;
  appColorPaletteNotifier.value = savedPalette;
  AppColors.palette = savedPalette;
  await NotificationService().init();
  await AdService.initialize();
  await RevenueCatService.initialize();
  FlutterNativeSplash.remove();
  runApp(const OrcamentoMensalApp());
}

class OrcamentoMensalApp extends StatelessWidget {
  const OrcamentoMensalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeModeNotifier,
      builder: (_, themeMode, _) => ValueListenableBuilder<AppColorPalette>(
        valueListenable: appColorPaletteNotifier,
        builder: (_, palette, _) {
          AppColors.palette = palette;
          return ValueListenableBuilder<Locale?>(
            valueListenable: appLocaleNotifier,
            builder: (_, locale, _) => MaterialApp(
              title: 'Orçamento Mensal',
              debugShowCheckedModeBanner: false,
              locale: locale,
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.supportedLocales,
              theme: lightTheme(palette),
              darkTheme: darkTheme(palette),
              themeMode: themeMode,
              home: AuthGate(
                appBuilder: (profile) => AppHome(
                  householdId: profile.householdId,
                  isAdmin: profile.role == 'admin',
                ),
              ),
            ),
          );
        },
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
  final _favoritesService = FavoritesService();
  final _shoppingListService = ShoppingListService();
  final _aiCoachService = AiCoachService();
  final _purchaseHistoryService = PurchaseHistoryService();
  final _productsService = ProductsService();
  final _expenseSnapshotService = ExpenseSnapshotService();
  final _localConfigService = LocalConfigService();
  final _actualExpenseService = ActualExpenseService();
  final _recurringExpenseService = RecurringExpenseService();
  final _savingsGoalService = SavingsGoalService();
  final _monthlyBudgetService = MonthlyBudgetService();
  final _subscriptionService = SubscriptionService();
  final _commandChatService = CommandChatService();
  final _commandPatternCache = CommandPatternCache();
  bool _commandPanelOpen = false;

  SubscriptionState _subscription =
      SubscriptionState(trialStartDate: DateTime.now());
  OnboardingState _onboardingState = const OnboardingState();
  final _fabKey = GlobalKey(debugLabel: 'tour_fab');
  final _navBarKey = GlobalKey(debugLabel: 'tour_nav_bar');

  AppSettings _settings = const AppSettings();
  List<ActualExpense> _actualExpenses = [];
  List<RecurringExpense> _recurringExpenses = [];
  Map<String, List<ActualExpense>> _actualExpenseHistory = {};
  Map<String, double> _monthlyBudgets = {};
  NotificationPreferences _notificationPrefs = const NotificationPreferences();
  List<SavingsGoal> _savingsGoals = [];
  Map<String, SavingsProjection> _savingsProjections = {};
  List<Product> _products = [];
  List<String> _favorites = [];
  List<ShoppingItem> _shoppingList = [];
  String _openAiApiKey = '';
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
    _commandPatternCache.load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shoppingListSub.cancel();
    RevenueCatService.logout();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshData();
      _syncRevenueCat();
    }
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
    _loadActualExpenses();
  }

  Future<void> _loadAll() async {
    final results = await Future.wait([
      _settingsService.load(widget.householdId),
      _favoritesService.load(widget.householdId),
      _purchaseHistoryService.load(widget.householdId),
      _aiCoachService.loadApiKey(),
      _productsService.load(),
      _localConfigService.load(),
      _localConfigService.loadOnboardingState(),
      _subscriptionService.load(),
    ]);
    setState(() {
      _settings = results[0] as AppSettings;
      _favorites = results[1] as List<String>;
      _purchaseHistory = results[2] as PurchaseHistory;
      _openAiApiKey = results[3] as String;
      _products = results[4] as List<Product>;
      _dashboardConfig = results[5] as LocalDashboardConfig;
      _onboardingState = results[6] as OnboardingState;
      _subscription = results[7] as SubscriptionState;
      _loaded = true;
    });
    _syncLocaleAndFormatter(_settings);
    _expenseSnapshotService.loadHistory(widget.householdId).then((history) {
      if (mounted) setState(() => _expenseHistory = history);
    });
    _loadActualExpenses();
    _loadRecurringExpenses();
    _loadActualExpenseHistory();
    _loadMonthlyBudgets();
    _loadNotificationPrefs();
    _loadSavingsGoals();
    _syncRevenueCat();
  }

  /// Login to RevenueCat and sync the remote subscription tier.
  Future<void> _syncRevenueCat() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      await RevenueCatService.login(user?.id);
      final remoteTier = await RevenueCatService.getCurrentTier();
      final updated = await _subscriptionService.syncFromRemoteTier(
          _subscription, remoteTier);
      if (mounted && updated != _subscription) {
        setState(() => _subscription = updated);
      }
    } catch (e) {
      debugPrint('RevenueCat sync error: $e');
    }
  }

  String get _currentMonthKey {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  Future<void> _loadActualExpenses() async {
    final expenses = await _actualExpenseService.loadMonth(
        widget.householdId, _currentMonthKey);
    if (mounted) {
      setState(() => _actualExpenses = expenses);
      _refreshNotificationSchedules();
    }
  }

  Future<void> _loadRecurringExpenses() async {
    final recurring =
        await _recurringExpenseService.load(widget.householdId);
    if (mounted) {
      setState(() => _recurringExpenses = recurring);
      _refreshNotificationSchedules();
    }
    // Auto-populate recurring expenses for the current month
    final created = await _recurringExpenseService.populateMonthIfNeeded(
        widget.householdId, _currentMonthKey);
    if (created.isNotEmpty) {
      _loadActualExpenses();
    }
  }

  void _openRecurringExpenses() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _buildSettingsScreen(initialSection: 'expenses'),
      ),
    );
  }

  Future<void> _loadActualExpenseHistory() async {
    final history =
        await _actualExpenseService.loadHistory(widget.householdId);
    if (mounted) setState(() => _actualExpenseHistory = history);
  }

  Future<void> _loadMonthlyBudgets() async {
    final budgets = await _monthlyBudgetService.loadMonth(
        widget.householdId, _currentMonthKey);
    if (mounted) {
      setState(() => _monthlyBudgets = {
        for (final b in budgets) b.category: b.amount,
      });
    }
  }

  Future<void> _loadNotificationPrefs() async {
    final prefs =
        await _localConfigService.loadNotificationPreferences();
    if (mounted) {
      setState(() => _notificationPrefs = prefs);
      _refreshNotificationSchedules();
    }
  }

  double _currentBudgetUsagePercent() {
    final totalBudget = _settings.expenses
        .where((e) => e.enabled)
        .fold<double>(0, (sum, e) => sum + e.amount);
    if (totalBudget <= 0) return 0;

    final spent = _actualExpenses.fold<double>(
      0,
      (sum, e) => sum + e.amount,
    );
    return (spent / totalBudget) * 100;
  }

  ({String category, double percent})? _topCategoryUsage() {
    final budgetByCategory = <String, double>{};
    for (final item in _settings.expenses.where((e) => e.enabled && e.amount > 0)) {
      budgetByCategory.update(item.category.name, (v) => v + item.amount,
          ifAbsent: () => item.amount);
    }
    if (budgetByCategory.isEmpty) return null;

    final spentByCategory = <String, double>{};
    for (final expense in _actualExpenses) {
      spentByCategory.update(expense.category, (v) => v + expense.amount,
          ifAbsent: () => expense.amount);
    }

    String? topCategory;
    double topPercent = 0.0;
    for (final entry in budgetByCategory.entries) {
      final spent = spentByCategory[entry.key] ?? 0.0;
      final percent = entry.value > 0 ? (spent / entry.value) * 100 : 0.0;
      if (topCategory == null || percent > topPercent) {
        topCategory = entry.key;
        topPercent = percent;
      }
    }
    if (topCategory == null) return null;
    return (category: topCategory, percent: topPercent);
  }

  void _refreshNotificationSchedules() {
    final topCategory = _topCategoryUsage();
    unawaited(NotificationService().refreshAllSchedules(
      prefs: _notificationPrefs,
      recurringExpenses: _recurringExpenses,
      budgetUsagePercent: _currentBudgetUsagePercent(),
      hasMealPlan: true, // TODO: wire with generated meal plan state.
      topCategoryName: topCategory?.category,
      topCategoryUsagePercent: topCategory?.percent,
    ));
  }

  void _openExpenseTrends() {
    if (!_gateFeature(PremiumFeature.expenseTrends)) return;
    _trackFeature('expense_tracker');
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExpenseTrendsScreen(
          actualExpenseHistory: _actualExpenseHistory,
          expenseHistory: _expenseHistory,
        ),
      ),
    );
  }

  Future<void> _loadSavingsGoals() async {
    final goals = await _savingsGoalService.loadGoals(widget.householdId);
    if (mounted) setState(() => _savingsGoals = goals);
    // Load contributions and compute projections for dashboard card
    final allContribs = await _savingsGoalService.loadAllContributions(
        widget.householdId, recentMonths: 6);
    final projections = <String, SavingsProjection>{};
    for (final goal in goals) {
      projections[goal.id] = calculateProjection(
        goal: goal,
        contributions: allContribs[goal.id] ?? [],
      );
    }
    if (mounted) setState(() => _savingsProjections = projections);
  }

  void _openSavingsGoals() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SavingsGoalsScreen(
          householdId: widget.householdId,
          goals: _savingsGoals,
          onChanged: (updated) {
            setState(() => _savingsGoals = updated);
            _loadSavingsGoals();
          },
          showTour: !_onboardingState.isTourDone('savings_goals'),
          onTourComplete: () => _markTourDone('savings_goals'),
        ),
      ),
    );
  }

  void _openNotificationSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NotificationSettingsScreen(
          preferences: _notificationPrefs,
          onSave: (prefs) {
            setState(() => _notificationPrefs = prefs);
            _refreshNotificationSchedules();
          },
        ),
      ),
    );
  }

  // ── Subscription helpers ──────────────────────────────────────────

  /// Track that a feature was explored during trial.
  void _trackFeature(String featureKey) async {
    final updated =
        await _subscriptionService.markFeatureExplored(_subscription, featureKey);
    if (mounted) setState(() => _subscription = updated);
  }

  /// Open the paywall — tries RevenueCat's hosted paywall first, falls back
  /// to the custom PaywallScreen (e.g. in simulate mode).
  void _openPaywall({PremiumFeature? blockedFeature}) async {
    // Try the RevenueCat-hosted paywall first.
    final result = await RevenueCatService.presentPaywall();
    if (result != null) {
      // RC paywall was shown. Sync tier regardless of outcome — the user
      // may have purchased, restored, or dismissed.
      await _syncRevenueCat();
      return;
    }

    // Fallback: custom paywall (simulate mode or RC not configured).
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaywallScreen(
          subscription: _subscription,
          blockedFeature: blockedFeature,
          onSelectTier: (tier) async {
            final updated =
                await _subscriptionService.upgradeTo(_subscription, tier);
            if (mounted) {
              setState(() => _subscription = updated);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tier == SubscriptionTier.free
                      ? 'Continuing with Free plan'
                      : 'Upgraded to Pro — thank you!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          onPurchaseComplete: (tier) async {
            final updated =
                await _subscriptionService.upgradeTo(_subscription, tier);
            if (mounted) {
              setState(() => _subscription = updated);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Upgraded to Pro — thank you!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          onRestoreComplete: (tier) async {
            final updated = await _subscriptionService.syncFromRemoteTier(
                _subscription, tier);
            if (mounted) {
              setState(() => _subscription = updated);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tier == SubscriptionTier.free
                      ? 'No previous purchases found'
                      : 'Restored Pro subscription!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      ),
    );
  }

  /// Open the RevenueCat Customer Center for subscription management.
  void _openCustomerCenter() async {
    await RevenueCatService.presentCustomerCenter();
    // Sync after Customer Center closes — user may have changed subscription.
    await _syncRevenueCat();
  }

  /// Check if a feature is accessible; if not, show paywall.
  bool _gateFeature(PremiumFeature feature) {
    if (_subscription.canAccess(feature)) return true;
    _openPaywall(blockedFeature: feature);
    return false;
  }

  /// Navigate to a feature from the discovery card.
  void _navigateToFeature(String featureKey) {
    _trackFeature(featureKey);
    switch (featureKey) {
      case 'ai_coach':
        _openCoach();
        break;
      case 'meal_planner':
        _openMealPlanner();
        break;
      case 'expense_tracker':
        setState(() => _currentIndex = 1);
        break;
      case 'savings_goals':
        _openSavingsGoals();
        break;
      case 'shopping_list':
        _openShoppingList();
        break;
      case 'grocery_browser':
        _openGrocery();
        break;
      case 'export':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => _buildSettingsScreen()),
        );
        break;
      case 'tax_simulator':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => _buildSettingsScreen()),
        );
        break;
      default:
        setState(() => _currentIndex = 0);
    }
  }

  void _openInsights() {
    final taxSystem = getTaxSystem(_settings.country);
    final summary = calculateBudgetSummary(
      _settings.salaries,
      _settings.personalInfo,
      _settings.expenses,
      taxSystem,
      monthlyBudgets: _monthlyBudgets,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InsightsScreen(
          settings: _settings,
          summary: summary,
          onOpenExpenseTrends: _openExpenseTrends,
          onOpenSavingsGoals: _openSavingsGoals,
          onOpenTaxSimulator: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TaxSimulatorScreen(settings: _settings),
            ),
          ),
        ),
      ),
    );
  }

  void _openDetailedDashboard() {
    final taxSystem = getTaxSystem(_settings.country);
    final summary = calculateBudgetSummary(
      _settings.salaries,
      _settings.personalInfo,
      _settings.expenses,
      taxSystem,
      monthlyBudgets: _monthlyBudgets,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DashboardScreen(
          settings: _settings,
          summary: summary,
          purchaseHistory: _purchaseHistory,
          onSaveSettings: _saveSettings,
          dashboardConfig: LocalDashboardConfig.full(),
          expenseHistory: _expenseHistory,
          onSnapshotExpenses: _snapshotExpenses,
          actualExpenses: _actualExpenses,
          onAddExpense: _openAddExpenseSheet,
          monthlyBudgets: _monthlyBudgets,
          onOpenExpenseTracker: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ExpenseTrackerScreen(
                settings: _settings,
                expenses: _actualExpenses,
                householdId: widget.householdId,
                onAdd: _addActualExpense,
                onUpdate: _updateActualExpense,
                onDelete: _deleteActualExpense,
                onLoadMonth: (monthKey) =>
                    _actualExpenseService.loadMonth(widget.householdId, monthKey),
                onLoadHistory: () =>
                    _actualExpenseService.loadHistory(widget.householdId),
                onOpenRecurring: _openRecurringExpenses,
                showTour: !_onboardingState.isTourDone('expense_tracker'),
                onTourComplete: () => _markTourDone('expense_tracker'),
              ),
            ),
          ),
          onViewTrends: _openExpenseTrends,
          savingsGoals: _savingsGoals,
          savingsProjections: _savingsProjections,
          onOpenSavingsGoals: _openSavingsGoals,
          recurringExpenses: _recurringExpenses,
          actualExpenseHistory: _actualExpenseHistory,
          billReminderDaysBefore: _notificationPrefs.billReminderDaysBefore,
          onOpenRecurringExpenses: _openRecurringExpenses,
          onOpenSettings: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => _buildSettingsScreen()),
            );
          },
        ),
      ),
    );
  }

  void _openGrocery() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GroceryScreen(
          products: _products,
          onAddToShoppingList: _addToShoppingList,
          showTour: !_onboardingState.isTourDone('grocery'),
          onTourComplete: () => _markTourDone('grocery'),
        ),
      ),
    );
  }

  void _openShoppingList() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShoppingListScreen(
          items: _shoppingList,
          onToggleChecked: _toggleShoppingItem,
          onRemove: _removeShoppingItem,
          onClearChecked: _clearCheckedItems,
          onFinalize: _finalizeShopping,
          purchaseHistory: _purchaseHistory,
          showTour: !_onboardingState.isTourDone('shopping'),
          onTourComplete: () => _markTourDone('shopping'),
        ),
      ),
    );
  }

  void _openCoach() {
    if (!_gateFeature(PremiumFeature.aiCoach)) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CoachScreen(
          settings: _settings,
          purchaseHistory: _purchaseHistory,
          apiKey: _openAiApiKey,
          householdId: widget.householdId,
          subscription: _subscription,
          onSubscriptionChanged: (next) {
            if (!mounted) return;
            setState(() => _subscription = next);
          },
          onRestoreMemory: _openPaywall,
          onOpenSettings: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => _buildSettingsScreen()),
            );
          },
          showTour: !_onboardingState.isTourDone('coach'),
          onTourComplete: () => _markTourDone('coach'),
        ),
      ),
    );
  }

  void _openMealPlanner() {
    if (!_gateFeature(PremiumFeature.mealPlanner)) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MealPlannerScreen(
          settings: _settings,
          apiKey: _openAiApiKey,
          favorites: _favorites,
          onAddToShoppingList: _addToShoppingList,
          householdId: widget.householdId,
          onSaveSettings: _saveSettings,
          purchaseHistory: _purchaseHistory,
          onOpenMealSettings: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _buildSettingsScreen(initialSection: 'meals'),
            ),
          ),
          showTour: !_onboardingState.isTourDone('meals'),
          onTourComplete: () => _markTourDone('meals'),
        ),
      ),
    );
  }

  void _markTourDone(String key) {
    final updated = _onboardingState.copyWith(
      toursCompleted: {..._onboardingState.toursCompleted, key: true},
    );
    setState(() => _onboardingState = updated);
    _localConfigService.saveOnboardingState(updated);
  }

  void _syncLocaleAndFormatter(AppSettings settings) {
    setFormatterCountry(settings.country);
    if (settings.localeOverride != null) {
      appLocaleNotifier.value = Locale(settings.localeOverride!);
    } else {
      appLocaleNotifier.value = null; // system default
    }
  }

  void _saveSettings(AppSettings settings) {
    if (!widget.isAdmin) return;
    setState(() => _settings = settings);
    _syncLocaleAndFormatter(settings);
    _settingsService.save(settings, widget.householdId);
    _refreshNotificationSchedules();
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

  CommandActionRegistry _buildCommandRegistry() {
    return CommandActionRegistry(
      onAddExpense: _addActualExpense,
      onAddShoppingItem: (item) async => _addToShoppingList(item),
      onAddSavingsGoal: _addSavingsGoalFromCommand,
      onAddRecurringExpense: _addRecurringExpenseFromCommand,
      onRemoveShoppingItemByName: _removeShoppingItemByNameFromCommand,
      onToggleShoppingItemCheckedByName:
          _toggleShoppingItemCheckedByNameFromCommand,
      onAddSavingsContributionByGoalName:
          _addSavingsContributionByGoalNameFromCommand,
      onDeleteExpenseByDescription: _deleteExpenseByDescriptionFromCommand,
      onDeleteExpense: _deleteActualExpense,
      onSetThemeMode: (mode) => appThemeModeNotifier.value = mode,
      onSetColorPalette: (palette) {
        AppColors.palette = palette;
        appColorPaletteNotifier.value = palette;
        _localConfigService.saveColorPalette(palette);
      },
      onSetLanguage: (localeCode) {
        _saveSettings(_settings.copyWith(localeOverride: localeCode));
      },
      onNavigateTo: _handleCommandNavigation,
      onClearCheckedItems: _clearCheckedItems,
    );
  }

  void _handleCommandNavigation(String screen) {
    switch (screen) {
      case 'dashboard':
        setState(() => _currentIndex = 0);
      case 'expenses':
        setState(() => _currentIndex = 1);
      case 'plan':
        setState(() => _currentIndex = 2);
      case 'more':
        setState(() => _currentIndex = 3);
      case 'coach':
        _openCoach();
      case 'grocery':
        _openGrocery();
      case 'shopping_list':
        _openShoppingList();
      case 'meals':
        _openMealPlanner();
      case 'settings':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => _buildSettingsScreen()),
        );
      case 'insights':
        _openInsights();
      case 'savings_goals':
        _openSavingsGoals();
    }
    setState(() => _commandPanelOpen = false);
  }

  Future<void> _finalizeShopping(
      double? amount, List<ShoppingItem> checkedItems, {bool isMealPurchase = false}) async {
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
        isMealPurchase: isMealPurchase,
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
            backgroundColor: AppColors.error(context),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _addActualExpense(ActualExpense expense) async {
    setState(() => _actualExpenses = [expense, ..._actualExpenses]);
    _refreshNotificationSchedules();
    try {
      await _actualExpenseService.add(expense, widget.householdId);
    } catch (e) {
      debugPrint('Failed to add expense: $e');
      // Reload from Supabase to get the real state
      _loadActualExpenses();
    }
  }

  Future<void> _addSavingsGoalFromCommand(SavingsGoal goal) async {
    setState(() {
      _savingsGoals = [..._savingsGoals, goal]
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    });
    try {
      await _savingsGoalService.saveGoal(goal, widget.householdId);
    } catch (e) {
      debugPrint('Failed to add savings goal: $e');
      _loadSavingsGoals();
    }
  }

  Future<void> _addRecurringExpenseFromCommand(
    RecurringExpense expense,
  ) async {
    setState(() {
      _recurringExpenses = [..._recurringExpenses, expense]
        ..sort((a, b) {
          final dayA = a.dayOfMonth ?? 99;
          final dayB = b.dayOfMonth ?? 99;
          return dayA.compareTo(dayB);
        });
    });
    _refreshNotificationSchedules();
    try {
      await _recurringExpenseService.save(expense, widget.householdId);
    } catch (e) {
      debugPrint('Failed to add recurring expense: $e');
      _loadRecurringExpenses();
    }
  }

  Future<bool> _removeShoppingItemByNameFromCommand(String itemName) async {
    final query = itemName.trim().toLowerCase();
    final match = _shoppingList
        .where((item) => item.productName.trim().toLowerCase() == query)
        .cast<ShoppingItem?>()
        .firstWhere((item) => item != null, orElse: () => null);
    final fallback = match ??
        _shoppingList
            .where((item) => item.productName.trim().toLowerCase().contains(query))
            .cast<ShoppingItem?>()
            .firstWhere((item) => item != null, orElse: () => null);
    final item = fallback;
    if (item == null || item.id.isEmpty) return false;
    final previousItems = List<ShoppingItem>.from(_shoppingList);
    setState(() {
      _shoppingList = _shoppingList.where((i) => i.id != item.id).toList();
    });
    try {
      await _shoppingListService.remove(item.id);
      return true;
    } catch (e) {
      debugPrint('Failed to remove shopping item: $e');
      setState(() => _shoppingList = previousItems);
      return false;
    }
  }

  Future<bool> _toggleShoppingItemCheckedByNameFromCommand(
    String itemName,
    bool checked,
  ) async {
    final query = itemName.trim().toLowerCase();
    final exact = _shoppingList
        .where((item) => item.productName.trim().toLowerCase() == query)
        .cast<ShoppingItem?>()
        .firstWhere((item) => item != null, orElse: () => null);
    final item = exact ??
        _shoppingList
            .where((i) => i.productName.trim().toLowerCase().contains(query))
            .cast<ShoppingItem?>()
            .firstWhere((i) => i != null, orElse: () => null);
    if (item == null || item.id.isEmpty) return false;
    final previousItems = List<ShoppingItem>.from(_shoppingList);
    setState(() {
      _shoppingList = _shoppingList.map((i) {
        if (i.id != item.id) return i;
        return ShoppingItem(
          id: i.id,
          productName: i.productName,
          store: i.store,
          price: i.price,
          unitPrice: i.unitPrice,
          checked: checked,
        );
      }).toList();
    });
    try {
      await _shoppingListService.toggle(item.id, checked);
      return true;
    } catch (e) {
      debugPrint('Failed to toggle shopping item: $e');
      setState(() => _shoppingList = previousItems);
      return false;
    }
  }

  Future<bool> _addSavingsContributionByGoalNameFromCommand(
    String goalName,
    double amount,
  ) async {
    final query = goalName.trim().toLowerCase();
    final exact = _savingsGoals
        .where((goal) => goal.name.trim().toLowerCase() == query)
        .cast<SavingsGoal?>()
        .firstWhere((goal) => goal != null, orElse: () => null);
    final goal = exact ??
        _savingsGoals
            .where((g) => g.name.trim().toLowerCase().contains(query))
            .cast<SavingsGoal?>()
            .firstWhere((g) => g != null, orElse: () => null);
    if (goal == null) return false;

    final contribution = SavingsContribution(
      id: 'contrib_${DateTime.now().millisecondsSinceEpoch}',
      goalId: goal.id,
      amount: amount,
      contributionDate: DateTime.now(),
    );

    try {
      final updatedGoal = await _savingsGoalService.addContribution(
        contribution,
        widget.householdId,
      );
      setState(() {
        _savingsGoals = _savingsGoals
            .map((g) => g.id == updatedGoal.id ? updatedGoal : g)
            .toList();
      });
      return true;
    } catch (e) {
      debugPrint('Failed to add savings contribution: $e');
      _loadSavingsGoals();
      return false;
    }
  }

  Future<bool> _deleteExpenseByDescriptionFromCommand(
    String description, {
    String? category,
  }) async {
    final query = description.trim().toLowerCase();
    final exact = _actualExpenses
        .where((expense) {
          final desc = (expense.description ?? '').trim().toLowerCase();
          if (desc != query) return false;
          return category == null || expense.category == category;
        })
        .cast<ActualExpense?>()
        .firstWhere((expense) => expense != null, orElse: () => null);
    final expense = exact ??
        _actualExpenses
            .where((e) {
              final desc = (e.description ?? '').trim().toLowerCase();
              if (!desc.contains(query)) return false;
              return category == null || e.category == category;
            })
            .cast<ActualExpense?>()
            .firstWhere((e) => e != null, orElse: () => null);
    if (expense == null) return false;
    final previousExpenses = List<ActualExpense>.from(_actualExpenses);
    setState(() {
      _actualExpenses = _actualExpenses.where((e) => e.id != expense.id).toList();
    });
    _refreshNotificationSchedules();
    try {
      await _actualExpenseService.delete(expense.id);
      return true;
    } catch (e) {
      debugPrint('Failed to delete expense by description: $e');
      setState(() => _actualExpenses = previousExpenses);
      _refreshNotificationSchedules();
      return false;
    }
  }

  Future<void> _updateActualExpense(ActualExpense expense) async {
    setState(() {
      _actualExpenses =
          _actualExpenses.map((e) => e.id == expense.id ? expense : e).toList();
    });
    _refreshNotificationSchedules();
    await _actualExpenseService.update(expense);
  }

  Future<void> _deleteActualExpense(String id) async {
    setState(() {
      _actualExpenses = _actualExpenses.where((e) => e.id != id).toList();
    });
    _refreshNotificationSchedules();
    await _actualExpenseService.delete(id);
  }

  void _openAddExpenseSheet() async {
    final result = await showAddExpenseSheet(
      context: context,
      budgetExpenses: _settings.expenses,
      currentExpenses: _actualExpenses,
    );
    if (result != null) {
      _addActualExpense(result);
    }
  }


  SettingsScreen _buildSettingsScreen({String? initialSection}) {
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
      dashboardConfig: _dashboardConfig,
      onSaveDashboardConfig: _saveDashboardConfig,
      onOpenDetailedDashboard: _openDetailedDashboard,
      onOpenNotificationSettings: _openNotificationSettings,
      onOpenSubscription: _openPaywall,
      onOpenCustomerCenter: _openCustomerCenter,
      subscriptionLabel: _subscription.isTrialActive
          ? 'Trial (${_subscription.trialDaysRemaining} days left)'
          : _subscription.tier == SubscriptionTier.free
              ? 'Free'
              : 'Pro',
      monthlyBudgets: _monthlyBudgets,
      onSaveMonthlyBudgets: (budgetMap) async {
        final budgets = budgetMap.entries
            .map((e) => MonthlyBudget.create(
                  category: e.key,
                  amount: e.value,
                  monthKey: _currentMonthKey,
                ))
            .toList();
        await _monthlyBudgetService.saveAll(budgets, widget.householdId);
        _loadMonthlyBudgets();
      },
      recurringExpenses: _recurringExpenses,
      onRecurringChanged: (updated) {
        setState(() => _recurringExpenses = updated);
        _refreshNotificationSchedules();
      },
      initialSection: initialSection,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const BrandedLoading();
    }

    if (!_settings.setupWizardCompleted) {
      return SetupWizardScreen(
        initial: _settings,
        onComplete: (settings) {
          final completed = settings.copyWith(setupWizardCompleted: true);
          _saveSettings(completed);
        },
      );
    }

    if (!_onboardingState.welcomeSeen) {
      return WelcomeSlideshowScreen(
        onComplete: () {
          final updated = _onboardingState.copyWith(welcomeSeen: true);
          setState(() => _onboardingState = updated);
          _localConfigService.saveOnboardingState(updated);
        },
      );
    }

    final taxSystem = getTaxSystem(_settings.country);
    final summary = calculateBudgetSummary(
      _settings.salaries,
      _settings.personalInfo,
      _settings.expenses,
      taxSystem,
      monthlyBudgets: _monthlyBudgets,
    );

    final focusedDashboardConfig = _dashboardConfig.copyWith(
      showSummaryCards: false,
      showSalaryBreakdown: false,
      showPurchaseHistory: false,
      showExpensesBreakdown: false,
      showCharts: false,
      showBudgetVsActual: false,
      showSavingsGoals: false,
      showTaxDeductions: false,
    );

    final screens = [
      DashboardScreen(
        settings: _settings,
        summary: summary,
        purchaseHistory: _purchaseHistory,
        onSaveSettings: _saveSettings,
        dashboardConfig: focusedDashboardConfig,
        expenseHistory: _expenseHistory,
        onSnapshotExpenses: _snapshotExpenses,
        actualExpenses: _actualExpenses,
        onAddExpense: _openAddExpenseSheet,
        monthlyBudgets: _monthlyBudgets,
        onOpenExpenseTracker: () => setState(() => _currentIndex = 1),
        onViewTrends: _openExpenseTrends,
        savingsGoals: _savingsGoals,
        savingsProjections: _savingsProjections,
        onOpenSavingsGoals: _openSavingsGoals,
        recurringExpenses: _recurringExpenses,
        actualExpenseHistory: _actualExpenseHistory,
        billReminderDaysBefore: _notificationPrefs.billReminderDaysBefore,
        onOpenRecurringExpenses: _openRecurringExpenses,
        onOpenSettings: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => _buildSettingsScreen()),
          );
        },
        showTour: !_onboardingState.isTourDone('dashboard'),
        onTourComplete: () => _markTourDone('dashboard'),
        fabKey: _fabKey,
        navBarKey: _navBarKey,
        focusedMode: true,
        onOpenInsights: _openInsights,
      ),
      ExpenseTrackerScreen(
        settings: _settings,
        expenses: _actualExpenses,
        householdId: widget.householdId,
        onAdd: _addActualExpense,
        onUpdate: _updateActualExpense,
        onDelete: _deleteActualExpense,
        onLoadMonth: (monthKey) =>
            _actualExpenseService.loadMonth(widget.householdId, monthKey),
        onLoadHistory: () =>
            _actualExpenseService.loadHistory(widget.householdId),
        onOpenRecurring: _openRecurringExpenses,
        showTour: !_onboardingState.isTourDone('expense_tracker'),
        onTourComplete: () => _markTourDone('expense_tracker'),
      ),
      PlanHubScreen(
        onOpenGrocery: _openGrocery,
        onOpenShoppingList: _openShoppingList,
        onOpenMealPlanner: _openMealPlanner,
        onOpenCoach: _openCoach,
      ),
      MoreScreen(
        onOpenDetailedDashboard: _openDetailedDashboard,
        onOpenInsights: _openInsights,
        onOpenSavingsGoals: _openSavingsGoals,
        onOpenSettings: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => _buildSettingsScreen()),
          );
        },
        onOpenNotifications: _openNotificationSettings,
        onOpenSubscription: _openPaywall,
      ),
    ];

    return Stack(
      children: [
        Scaffold(
      body: _currentIndex == 0
          ? Column(
              children: [
                // Trial banner on dashboard
                if (_subscription.isTrialActive)
                  TrialBanner(
                    subscription: _subscription,
                    onUpgrade: _openPaywall,
                  ),
                // Feature discovery nudge
                if (_subscription.isTrialActive &&
                    _subscription.nextFeatureToDiscover != null)
                  FeatureDiscoveryCard(
                    subscription: _subscription,
                    onExploreFeature: _navigateToFeature,
                    onDismiss: () {
                      // Skip this feature in discovery
                      final next = _subscription.nextFeatureToDiscover;
                      if (next != null) _trackFeature(next);
                    },
                  ),
                Expanded(child: screens[0]),
                AdBannerWidget(
                  showAd: AdService.shouldShowAds(_subscription),
                ),
              ],
            )
          : screens[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              key: _fabKey,
              onPressed: _openAddExpenseSheet,
              backgroundColor: AppColors.primary(context),
              tooltip: S.of(context).addExpenseTooltip,
              child: Icon(Icons.add, color: AppColors.onPrimary(context)),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        key: _navBarKey,
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) {
          const tabFeatures = ['dashboard', 'expense_tracker', 'planning', 'more'];
          if (i < tabFeatures.length) _trackFeature(tabFeatures[i]);

          setState(() => _currentIndex = i);
        },
        backgroundColor: AppColors.surface(context),
        indicatorColor: AppColors.navIndicator(context),
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.primary(context)),
            label: 'Home',
            tooltip: 'Monthly overview',
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon:
                Icon(Icons.receipt_long, color: AppColors.primary(context)),
            label: 'Track',
            tooltip: 'Track monthly expenses',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _shoppingList.any((i) => !i.checked),
              label: Text(
                '${_shoppingList.where((i) => !i.checked).length}',
                style: const TextStyle(fontSize: 10),
              ),
              child: const Icon(Icons.event_note_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: _shoppingList.any((i) => !i.checked),
              label: Text(
                '${_shoppingList.where((i) => !i.checked).length}',
                style: const TextStyle(fontSize: 10),
              ),
              child: Icon(Icons.event_note, color: AppColors.primary(context)),
            ),
            label: 'Plan',
            tooltip: 'Groceries, list and meal plan',
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz),
            selectedIcon:
                Icon(Icons.more_horiz, color: AppColors.primary(context)),
            label: 'More',
            tooltip: 'Settings and insights',
          ),
        ],
      ),
        ),
        // Command assistant scrim
        if (_commandPanelOpen)
          GestureDetector(
            onTap: () => setState(() => _commandPanelOpen = false),
            child: Container(color: Colors.black.withValues(alpha: 0.3)),
          ),
        // Command assistant panel
        if (_commandPanelOpen)
          CommandChatPanel(
            onMinimize: () => setState(() => _commandPanelOpen = false),
            onSendCommand: (input) async {
              final cached = _commandPatternCache.match(input);
              if (cached != null) {
                return CommandAction.withAction(
                  action: cached.action,
                  params: cached.params,
                  message: '',
                );
              }
              return _commandChatService.parseCommand(input);
            },
            onExecuteAction: (action) async {
              final registry = _buildCommandRegistry();
              return registry.execute(
                action.action!,
                action.params ?? {},
              );
            },
            onCachePattern: (input, action, params) {
              _commandPatternCache.store(
                input: input,
                action: action,
                params: params,
              );
            },
          ),
        // Command assistant FAB
        CommandChatFab(
          onTap: () => setState(() => _commandPanelOpen = !_commandPanelOpen),
          isDashboard: _currentIndex == 0,
          isExpanded: _commandPanelOpen,
          showTour: !_onboardingState.isTourDone('command_assistant'),
          onTourComplete: () => _markTourDone('command_assistant'),
        ),
      ],
    );
  }
}

