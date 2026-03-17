import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'l10n/generated/app_localizations.dart';
import 'main.dart';
import 'models/app_settings.dart';
import 'models/product.dart';
import 'models/shopping_item.dart';
import 'models/purchase_record.dart';
import 'utils/calculations.dart';
import 'utils/formatters.dart';
import 'utils/unit_converter.dart';
import 'data/tax/tax_factory.dart';
import 'data/tax/tax_system.dart';
import 'services/settings_service.dart';
import 'services/favorites_service.dart';
import 'services/shopping_list_service.dart';
import 'services/ai_coach_service.dart';
import 'services/purchase_history_service.dart';
import 'services/products_service.dart';
import 'services/expense_snapshot_service.dart';
import 'services/local_config_service.dart';
import 'services/meal_planner_service.dart';
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
import 'screens/setup_wizard_screen.dart';
import 'screens/expense_trends_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/more_screen.dart';
import 'screens/plan_hub_screen.dart';
import 'screens/plan_and_shop_screen.dart';
import 'screens/notification_settings_screen.dart';
import 'models/recurring_expense.dart';
import 'models/custom_category.dart';
import 'models/notification_preferences.dart';
import 'services/recurring_expense_service.dart';
import 'services/category_service.dart';
import 'services/notification_service.dart';
import 'services/savings_goal_service.dart';
import 'models/savings_goal.dart';
import 'screens/savings_goals_screen.dart';
import 'screens/tax_simulator_screen.dart';
import 'utils/savings_projections.dart';
import 'theme/app_colors.dart';
import 'models/onboarding_state.dart';
import 'models/subscription_state.dart';
import 'services/subscription_service.dart';
import 'services/grocery_service.dart';
import 'screens/welcome_slideshow_screen.dart';
import 'screens/paywall_screen.dart';
import 'widgets/trial_banner.dart';
import 'widgets/feature_discovery_card.dart';
import 'services/ad_service.dart';
import 'services/downgrade_service.dart';
import 'services/revenuecat_service.dart';
import 'widgets/ad_banner_widget.dart';
import 'widgets/trial_expired_bottom_sheet.dart';
import 'widgets/branded_loading.dart';
import 'services/command_chat_service.dart';
import 'services/command_pattern_cache.dart';
import 'services/command_action_registry.dart';
import 'services/data_health_service.dart';
import 'models/data_health_status.dart';
import 'utils/data_alert_builder.dart';
import 'screens/confidence_center_screen.dart';
import 'models/command_action.dart';
import 'models/grocery_data.dart';
import 'widgets/command_chat_fab.dart';
import 'widgets/command_chat_panel.dart';
import 'widgets/error_boundary.dart';
import 'services/quick_action_service.dart';
import 'services/receipt_scan_service.dart';
import 'widgets/quick_add_launcher.dart';
import 'widgets/receipt_review_sheet.dart';
import 'widgets/receipt_scan_sheet.dart';
import 'screens/product_updates_screen.dart';
import 'constants/app_constants.dart';

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
  final _groceryService = GroceryService();
  final _expenseSnapshotService = ExpenseSnapshotService();
  final _localConfigService = LocalConfigService();
  final _actualExpenseService = ActualExpenseService();
  final _recurringExpenseService = RecurringExpenseService();
  final _categoryService = CategoryService();
  final _savingsGoalService = SavingsGoalService();
  final _monthlyBudgetService = MonthlyBudgetService();
  final _subscriptionService = SubscriptionService();
  final _downgradeService = DowngradeService();
  final _commandChatService = CommandChatService();
  final _commandPatternCache = CommandPatternCache();
  final _dataHealthService = DataHealthService();
  bool _commandPanelOpen = false;

  // Use a far-past date so trial is NOT active before load() completes.
  SubscriptionState _subscription =
      SubscriptionState(trialStartDate: AppConstants.farPastDate);
  OnboardingState _onboardingState = const OnboardingState();
  final _fabKey = GlobalKey(debugLabel: 'tour_fab');
  final _navBarKey = GlobalKey(debugLabel: 'tour_nav_bar');

  AppSettings _settings = const AppSettings();
  List<ActualExpense> _actualExpenses = [];
  List<RecurringExpense> _recurringExpenses = [];
  List<CustomCategory> _customCategories = [];
  Map<String, List<ActualExpense>> _actualExpenseHistory = {};
  Map<String, double> _monthlyBudgets = {};
  NotificationPreferences _notificationPrefs = NotificationPreferences();
  List<SavingsGoal> _savingsGoals = [];
  Map<String, SavingsProjection> _savingsProjections = {};
  List<Product> _products = [];
  GroceryData _groceryData = const GroceryData();
  List<String> _favorites = [];
  List<ShoppingItem> _shoppingList = [];
  String _openAiApiKey = '';
  PurchaseHistory _purchaseHistory = const PurchaseHistory();
  LocalDashboardConfig _dashboardConfig = const LocalDashboardConfig();
  Map<String, List<ExpenseSnapshot>> _expenseHistory = {};
  bool _loaded = false;
  bool _groceryLoading = false;
  bool _hasMealPlan = false;
  int _currentIndex = AppTab.dashboard.index;

  /// Lifecycle debounce: skip refresh if resumed within this duration.
  static const _resumeDebounce = AppConstants.resumeDebounce;
  DateTime _lastRefresh = DateTime.fromMillisecondsSinceEpoch(0);
  bool _refreshing = false;

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
    QuickActionService.instance.init(onAction: _handleQuickAction);
    _dataHealthService.load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shoppingListSub.cancel();
    QuickActionService.instance.dispose();
    RevenueCatService.logout();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // Pause realtime stream to save battery/bandwidth in background.
        _shoppingListSub.pause();
        break;
      case AppLifecycleState.resumed:
        // Resume realtime stream.
        _shoppingListSub.resume();
        // Debounce: skip data refresh if we were backgrounded briefly.
        final elapsed = DateTime.now().difference(_lastRefresh);
        if (elapsed >= _resumeDebounce && !_refreshing) {
          _refreshData();
          _syncRevenueCat();
        }
        break;
      default:
        break;
    }
  }

  /// Lightweight refresh of household-synced data — called on app resume.
  ///
  /// Guarded by [_refreshing] to prevent overlapping calls and debounced by
  /// [_resumeDebounce] so quick app-switches don't trigger network requests.
  /// All state updates are batched into a single [setState] to minimise
  /// widget-tree rebuilds.
  Future<void> _refreshData() async {
    if (!mounted || _refreshing) return;
    _refreshing = true;
    try {
      final settings = await _settingsService.load(widget.householdId);
      final results = await Future.wait([
        _favoritesService.load(widget.householdId),
        _purchaseHistoryService.load(widget.householdId),
        _loadGroceryData(settings.country, updateLoadingState: false),
        _actualExpenseService.loadMonth(
            widget.householdId, _currentMonthKey),
        _expenseSnapshotService.loadHistory(widget.householdId),
      ]);
      if (mounted) {
        final newFavorites = results[0] as List<String>;
        final newHistory = results[1] as PurchaseHistory;
        final newGrocery = results[2] as GroceryData;
        final newExpenses = results[3] as List<ActualExpense>;
        final newSnapshots =
            results[4] as Map<String, List<ExpenseSnapshot>>;

        // Single setState — one rebuild instead of many.
        final changed = !identical(_settings, settings) ||
            !listEquals(_favorites, newFavorites) ||
            !identical(_purchaseHistory, newHistory) ||
            !identical(_groceryData, newGrocery) ||
            !listEquals(_actualExpenses, newExpenses) ||
            _expenseHistory.length != newSnapshots.length;

        if (changed) {
          setState(() {
            _settings = settings;
            _favorites = newFavorites;
            _purchaseHistory = newHistory;
            _groceryData = newGrocery;
            _actualExpenses = newExpenses;
            _expenseHistory = newSnapshots;
          });
        }
      }
      _lastRefresh = DateTime.now();
    } finally {
      _refreshing = false;
    }
  }

  Future<void> _loadAll() async {
    // Detect user change and clear stale per-user local data
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      final changed = await _localConfigService.checkUserChanged(userId);
      if (changed) await _subscriptionService.clear();
    }

    final settings = await _settingsService.load(widget.householdId);
    final results = await Future.wait([
      _favoritesService.load(widget.householdId),
      _purchaseHistoryService.load(widget.householdId),
      _aiCoachService.loadApiKey(),
      _productsService.load(),
      _loadGroceryData(settings.country, updateLoadingState: false),
      _localConfigService.load(),
      _localConfigService.loadOnboardingState(),
      _subscriptionService.load(),
    ]);
    setState(() {
      _settings = settings;
      _favorites = results[0] as List<String>;
      _purchaseHistory = results[1] as PurchaseHistory;
      _openAiApiKey = results[2] as String;
      _products = results[3] as List<Product>;
      _groceryData = results[4] as GroceryData;
      _dashboardConfig = results[5] as LocalDashboardConfig;
      _onboardingState = results[6] as OnboardingState;
      _subscription = results[7] as SubscriptionState;
      _loaded = true;
    });
    _lastRefresh = DateTime.now();
    _dataHealthService.recordLoad(SyncDomain.settings);
    _dataHealthService.recordLoad(SyncDomain.purchaseHistory);
    _dataHealthService.recordLoad(SyncDomain.shopping);
    _syncLocaleAndFormatter(_settings);
    _expenseSnapshotService.loadHistory(widget.householdId).then((history) {
      if (mounted) setState(() => _expenseHistory = history);
    });
    _loadActualExpenses();
    _loadRecurringExpenses();
    _loadCustomCategories();
    _loadActualExpenseHistory();
    _loadMonthlyBudgets();
    _loadNotificationPrefs();
    _loadMealPlanState();
    await _loadSavingsGoals();
    _syncRevenueCat();
    _checkDowngrade();
  }

  Future<GroceryData> _loadGroceryData(
    Country country, {
    bool updateLoadingState = true,
  }) async {
    if (updateLoadingState && mounted) {
      setState(() => _groceryLoading = true);
    }
    try {
      return await _groceryService.load(countryCode: country.name);
    } catch (e) {
      debugPrint('Failed to load grocery data for ${country.name}: $e');
      return const GroceryData();
    } finally {
      if (updateLoadingState && mounted) {
        setState(() => _groceryLoading = false);
      }
    }
  }

  /// Check if the user needs downgrade handling (trial expired or subscription cancelled).
  Future<void> _checkDowngrade() async {
    if (!_subscription.justDowngraded) return;

    // Apply free-tier limits if not already done
    final alreadyApplied = await _subscriptionService.isDowngradeApplied();
    if (!alreadyApplied) {
      await _downgradeService.applyFreeTierLimits(
        settings: _settings,
        goals: _savingsGoals,
        onSaveSettings: _saveSettings,
        householdId: widget.householdId,
        savingsGoalService: _savingsGoalService,
      );
      await _subscriptionService.markDowngradeApplied();
      // Reload goals after deactivation
      await _loadSavingsGoals();
    }

    // Show the trial-expired bottom sheet once
    final noticeSeen = await _subscriptionService.isTrialEndNoticeSeen();
    if (!noticeSeen && mounted) {
      // Wait for the next frame so the UI is fully built
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        final action = await showTrialExpiredBottomSheet(
          context: context,
          expenses: _settings.expenses,
          savingsGoals: _savingsGoals,
        );
        await _subscriptionService.markTrialEndNoticeSeen();
        if (!mounted) return;
        if (action == TrialExpiredAction.upgrade) {
          _openPaywall();
        } else if (action == TrialExpiredAction.manageCategories) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _buildSettingsScreen(initialSection: 'expenses'),
            ),
          );
        }
      });
    }
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
    try {
      final expenses = await _actualExpenseService.loadMonth(
          widget.householdId, _currentMonthKey);
      if (mounted) {
        setState(() => _actualExpenses = expenses);
        _refreshNotificationSchedules();
      }
      _dataHealthService.recordLoad(SyncDomain.expenses);
    } catch (e) {
      _dataHealthService.recordError(SyncDomain.expenses, '$e');
      rethrow;
    }
  }

  Future<void> _loadRecurringExpenses() async {
    try {
      final recurring =
          await _recurringExpenseService.load(widget.householdId);
      if (mounted) {
        setState(() => _recurringExpenses = recurring);
        _refreshNotificationSchedules();
      }
      _dataHealthService.recordLoad(SyncDomain.recurringExpenses);
      // Auto-populate recurring expenses for the current month
      final created = await _recurringExpenseService.populateMonthIfNeeded(
          widget.householdId, _currentMonthKey);
      if (created.isNotEmpty) {
        _loadActualExpenses();
      }
    } catch (e) {
      _dataHealthService.recordError(SyncDomain.recurringExpenses, '$e');
      rethrow;
    }
  }

  Future<void> _loadCustomCategories() async {
    try {
      final categories =
          await _categoryService.load(widget.householdId);
      if (mounted) {
        setState(() => _customCategories = categories);
      }
    } catch (e) {
      debugPrint('Failed to load custom categories: $e');
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

  Future<void> _loadMealPlanState() async {
    final now = DateTime.now();
    final plan = await MealPlannerService().load(widget.householdId, now.month, now.year);
    if (mounted) {
      setState(() => _hasMealPlan = plan != null);
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
      budgetByCategory.update(item.category, (v) => v + item.amount,
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
      hasMealPlan: _hasMealPlan,
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
    _dataHealthService.recordLoad(SyncDomain.savingsGoals);
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
          subscription: _subscription,
          onUpgrade: _openPaywall,
          showTour: !_onboardingState.isTourDone('savings_goals'),
          onTourComplete: () => _markTourDone('savings_goals'),
        ),
      ),
    );
  }

  void _openProductUpdates() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ProductUpdatesScreen(),
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
    final l10n = S.of(context);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaywallScreen(
          subscription: _subscription,
          blockedFeature: blockedFeature,
          onSelectTier: (tier) async {
            final updated =
                await _subscriptionService.upgradeTo(_subscription, tier);
            if (tier != SubscriptionTier.free) {
              await _subscriptionService.resetDowngradeTracking();
            }
            if (mounted) {
              setState(() => _subscription = updated);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tier == SubscriptionTier.free
                      ? l10n.paywallContinueFree
                      : l10n.paywallUpgradedPro),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          onPurchaseComplete: (tier) async {
            final updated =
                await _subscriptionService.upgradeTo(_subscription, tier);
            await _subscriptionService.resetDowngradeTracking();
            if (mounted) {
              setState(() => _subscription = updated);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.paywallUpgradedPro),
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
                      ? l10n.paywallNoRestore
                      : l10n.paywallRestoredPro),
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
        setState(() => _currentIndex = AppTab.expenses.index);
        break;
      case 'savings_goals':
        _openSavingsGoals();
        break;
      case 'shopping_list':
        setState(() => _currentIndex = AppTab.planHub.index);
        break;
      case 'grocery_browser':
        setState(() => _currentIndex = AppTab.planHub.index);
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
        setState(() => _currentIndex = AppTab.dashboard.index);
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

  void _openGrocery() {
    final countryProducts = _groceryData.toCatalogProducts();
    final effectiveProducts =
        countryProducts.isNotEmpty || _settings.country != Country.pt
            ? countryProducts
            : _products;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GroceryScreen(
          products: effectiveProducts,
          groceryData: _groceryData,
          isLoading: _groceryLoading,
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
    ).then((_) => _loadMealPlanState());
  }

  void _openConfidenceCenter() {
    final alerts = buildAlerts(
      statuses: _dataHealthService.statuses,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConfidenceCenterScreen(
          statuses: _dataHealthService.statuses,
          alerts: alerts,
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
    final countryChanged = settings.country != _settings.country;
    setState(() => _settings = settings);
    _syncLocaleAndFormatter(settings);
    _settingsService.save(settings, widget.householdId);
    _dataHealthService.recordSave(SyncDomain.settings);
    _refreshNotificationSchedules();
    if (countryChanged) {
      _loadGroceryData(settings.country).then((data) {
        if (!mounted) return;
        setState(() => _groceryData = data);
      });
    }
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
    final match = _shoppingList.cast<ShoppingItem?>().firstWhere(
      (e) => e!.productName.toLowerCase() == item.productName.toLowerCase()
          && (e.unit == null || item.unit == null || UnitConverter.compatible(e.unit!, item.unit!)),
      orElse: () => null,
    );
    if (match != null) {
      // Merge quantities with unit conversion when both have compatible units
      double? mergedQuantity;
      String? mergedUnit = match.unit ?? item.unit;
      if (match.quantity != null && item.quantity != null) {
        if (match.unit != null && item.unit != null && UnitConverter.compatible(match.unit!, item.unit!)) {
          final converted = UnitConverter.convert(item.quantity!, item.unit!, match.unit!);
          mergedQuantity = match.quantity! + (converted ?? item.quantity!);
        } else {
          mergedQuantity = match.quantity! + item.quantity!;
        }
      } else {
        mergedQuantity = match.quantity ?? item.quantity;
      }
      // Apply display-friendly normalization (e.g. 1500 g → 1.5 kg)
      if (mergedQuantity != null && mergedUnit != null) {
        final (displayQty, displayUnit) = UnitConverter.displayFriendly(mergedQuantity, mergedUnit);
        mergedQuantity = displayQty;
        mergedUnit = displayUnit;
      }
      final mergedPrice = match.price + item.price;
      final mergedLabels = {...match.sourceMealLabels, ...item.sourceMealLabels}.toList();
      await _shoppingListService.updateItem(
        match.id,
        price: mergedPrice,
        quantity: mergedQuantity,
        unit: mergedUnit,
      );
      // Optimistic local update — Realtime will reconcile
      setState(() {
        _shoppingList = _shoppingList.map((e) {
          if (e.id != match.id) return e;
          return ShoppingItem(
            id: match.id,
            productName: match.productName,
            store: match.store,
            price: mergedPrice,
            unitPrice: match.unitPrice ?? item.unitPrice,
            checked: match.checked,
            sourceMealLabels: mergedLabels,
            preferredStore: match.preferredStore,
            cheapestKnownStore: match.cheapestKnownStore,
            cheapestKnownPrice: match.cheapestKnownPrice,
            quantity: mergedQuantity,
            unit: mergedUnit,
          );
        }).toList();
      });
      return;
    }
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
        setState(() => _currentIndex = AppTab.dashboard.index);
      case 'expenses':
        setState(() => _currentIndex = AppTab.expenses.index);
      case 'plan':
      case 'more':
      case 'grocery':
      case 'shopping_list':
      case 'meals':
        setState(() => _currentIndex = AppTab.planHub.index);
      case 'coach':
        _openCoach();
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
            content: Text(S.of(context).errorSavingPurchase('$e')),
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
    final deleted = _actualExpenses.where((e) => e.id == id).firstOrNull;
    setState(() {
      _actualExpenses = _actualExpenses.where((e) => e.id != id).toList();
    });
    _refreshNotificationSchedules();
    await _actualExpenseService.delete(id);
    if (!mounted || deleted == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(S.of(context).expenseDeleted),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: S.of(context).cmdUndo,
          onPressed: () => _addActualExpense(deleted),
        ),
      ),
    );
  }

  void _openAddExpenseSheet() async {
    final result = await showAddExpenseSheet(
      context: context,
      budgetExpenses: _settings.expenses,
      currentExpenses: _actualExpenses,
      customCategories: _customCategories,
    );
    if (result != null) {
      var expense = result.expense;
      if (result.newAttachmentFiles.isNotEmpty) {
        final urls = await _actualExpenseService.uploadAttachments(
          result.newAttachmentFiles,
          widget.householdId,
          expense.id,
        );
        if (urls.isNotEmpty) {
          final allUrls = [
            ...?expense.attachmentUrls,
            ...urls,
          ];
          expense = expense.copyWith(attachmentUrls: allUrls);
        }
      }
      _addActualExpense(expense);
    }
  }

  Future<void> _openReceiptScanner() async {
    final receipt = await ReceiptScanSheet.show(context);
    if (receipt == null || !mounted) return;

    final categories =
        _settings.expenses.map((e) => e.label).toList();

    final chosenCategory = await ReceiptReviewSheet.show(
      context,
      receipt: receipt,
      categories: categories,
    );
    if (chosenCategory == null || !mounted) return;

    final expense = ReceiptScanService.buildExpense(
      receipt: receipt,
      category: chosenCategory,
    );
    await _addActualExpense(expense);

    if (mounted) {
      final l10n = S.of(context);
      final merchantLabel = receipt.merchantName ??
          (receipt.merchantNif.isNotEmpty
              ? 'NIF ${receipt.merchantNif}'
              : l10n.receiptMerchantUnknown);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.receiptScanSuccess(
            formatCurrency(receipt.totalAmount),
            merchantLabel,
          )),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _handleQuickAction(QuickAction action) {
    if (!_loaded) return;
    switch (action) {
      case QuickAction.addExpense:
        _openAddExpenseSheet();
      case QuickAction.addShopping:
        _openShoppingList();
      case QuickAction.openMeals:
        _openMealPlanner();
      case QuickAction.openAssistant:
        setState(() => _commandPanelOpen = true);
      case QuickAction.scanReceipt:
        _openReceiptScanner();
    }
  }

  SettingsScreen _buildSettingsScreen({String? initialSection}) {
    final l10n = S.of(context);
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
      onOpenNotificationSettings: _openNotificationSettings,
      onOpenSubscription: _openPaywall,
      onOpenCustomerCenter: _openCustomerCenter,
      subscription: _subscription,
      subscriptionLabel: _subscription.isTrialActive
          ? l10n.subscriptionTrialLabel(_subscription.trialDaysRemaining)
          : _subscription.tier == SubscriptionTier.free
              ? l10n.subscriptionFree
              : l10n.subscriptionPro,
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
      customCategories: _customCategories,
      onCustomCategoriesChanged: (updated) {
        setState(() => _customCategories = updated);
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

    // Welcome slideshow removed – the simplified wizard (3 steps) already
    // introduces the app.  Auto-mark as seen so old state doesn't block.
    if (!_onboardingState.welcomeSeen) {
      final updated = _onboardingState.copyWith(welcomeSeen: true);
      _onboardingState = updated;
      _localConfigService.saveOnboardingState(updated);
    }

    final l10n = S.of(context);
    final taxSystem = getTaxSystem(_settings.country);
    final summary = calculateBudgetSummary(
      _settings.salaries,
      _settings.personalInfo,
      _settings.expenses,
      taxSystem,
      monthlyBudgets: _monthlyBudgets,
    );

    final screens = [
      ErrorBoundary(
        onError: (error, stack) =>
            debugPrint('[ErrorBoundary:Dashboard] $error\n$stack'),
        child: DashboardScreen(
        settings: _settings,
        summary: summary,
        purchaseHistory: _purchaseHistory,
        onSaveSettings: _saveSettings,
        dashboardConfig: _dashboardConfig,
        expenseHistory: _expenseHistory,
        onSnapshotExpenses: _snapshotExpenses,
        actualExpenses: _actualExpenses,
        onAddExpense: _openAddExpenseSheet,
        monthlyBudgets: _monthlyBudgets,
        onOpenExpenseTracker: () => setState(() => _currentIndex = AppTab.expenses.index),
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
        onOpenInsights: _openInsights,
        onOpenCoach: _openCoach,
        customCategories: _customCategories,
      )),
      ErrorBoundary(
        onError: (error, stack) =>
            debugPrint('[ErrorBoundary:Expenses] $error\n$stack'),
        child: ExpenseTrackerScreen(
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
          customCategories: _customCategories,
        ),
      ),
      ErrorBoundary(
        onError: (error, stack) =>
            debugPrint('[ErrorBoundary:PlanAndShop] $error\n$stack'),
        child: PlanAndShopScreen(
          shoppingItems: _shoppingList,
          onToggleChecked: _toggleShoppingItem,
          onRemove: _removeShoppingItem,
          onClearChecked: _clearCheckedItems,
          onFinalize: _finalizeShopping,
          purchaseHistory: _purchaseHistory,
          onAddToShoppingList: _addToShoppingList,
          products: _groceryData.toCatalogProducts().isNotEmpty ||
                  _settings.country != Country.pt
              ? _groceryData.toCatalogProducts()
              : _products,
          groceryData: _groceryData,
          groceryLoading: _groceryLoading,
          settings: _settings,
          apiKey: _openAiApiKey,
          favorites: _favorites,
          householdId: widget.householdId,
          onSaveSettings: _saveSettings,
          onOpenMealSettings: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _buildSettingsScreen(initialSection: 'meals'),
            ),
          ),
          showShoppingTour: !_onboardingState.isTourDone('shopping'),
          onShoppingTourComplete: () => _markTourDone('shopping'),
          showGroceryTour: !_onboardingState.isTourDone('grocery'),
          onGroceryTourComplete: () => _markTourDone('grocery'),
          showMealsTour: !_onboardingState.isTourDone('meals'),
          onMealsTourComplete: () => _markTourDone('meals'),
          canAccessMeals: _subscription.hasPremiumAccess,
        ),
      ),
    ];

    return Stack(
      children: [
        Scaffold(
      body: _currentIndex == AppTab.dashboard.index
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
                CriticalAlertBanner(
                  criticalCount: buildAlerts(
                    statuses: _dataHealthService.statuses,
                  ).where((a) => a.severity == AlertSeverity.critical).length,
                  onTap: _openConfidenceCenter,
                ),
                Expanded(child: screens[AppTab.dashboard.index]),
                AdBannerWidget(
                  showAd: AdService.shouldShowAds(_subscription),
                ),
              ],
            )
          : screens[_currentIndex],
      floatingActionButton: _currentIndex == AppTab.dashboard.index
          ? Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: QuickAddLauncher(
                key: _fabKey,
                onAction: _handleQuickAction,
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 1,
            color: const Color(0xFFF1F5F9),
          ),
          NavigationBar(
            key: _navBarKey,
            selectedIndex: _currentIndex,
            onDestinationSelected: (i) {
              const tabFeatures = ['dashboard', 'expense_tracker', 'plan_and_shop'];
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
                label: l10n.navHome,
                tooltip: l10n.navHomeTip,
              ),
              NavigationDestination(
                icon: const Icon(Icons.receipt_long_outlined),
                selectedIcon:
                    Icon(Icons.receipt_long, color: AppColors.primary(context)),
                label: l10n.navTrack,
                tooltip: l10n.navTrackTip,
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: _shoppingList.any((i) => !i.checked),
                  backgroundColor: const Color(0xFFEF4444),
                  label: Text(
                    '${_shoppingList.where((i) => !i.checked).length}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  child: const Icon(Icons.shopping_basket_outlined),
                ),
                selectedIcon: Badge(
                  isLabelVisible: _shoppingList.any((i) => !i.checked),
                  backgroundColor: const Color(0xFFEF4444),
                  label: Text(
                    '${_shoppingList.where((i) => !i.checked).length}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  child: Icon(Icons.shopping_basket, color: AppColors.primary(context)),
                ),
                label: l10n.navPlanAndShop,
                tooltip: l10n.navPlanAndShopTip,
              ),
            ],
          ),
        ],
      ),
        ),
        // Command assistant scrim
        if (_commandPanelOpen)
          GestureDetector(
            onTap: () => setState(() => _commandPanelOpen = false),
            child: Container(color: Theme.of(context).shadowColor.withValues(alpha: 0.3)),
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
          isDashboard: _currentIndex == AppTab.dashboard.index,
          isExpanded: _commandPanelOpen,
          showTour: !_onboardingState.isTourDone('command_assistant'),
          onTourComplete: () => _markTourDone('command_assistant'),
        ),
      ],
    );
  }
}
