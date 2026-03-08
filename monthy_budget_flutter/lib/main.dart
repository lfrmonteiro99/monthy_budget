import 'dart:async';
import 'package:flutter/foundation.dart';
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
import 'services/downgrade_service.dart';
import 'services/revenuecat_service.dart';
import 'widgets/ad_banner_widget.dart';
import 'widgets/trial_expired_bottom_sheet.dart';
import 'widgets/branded_loading.dart';
import 'services/command_chat_service.dart';
import 'services/command_pattern_cache.dart';
import 'services/command_action_registry.dart';
import 'models/command_action.dart';
import 'widgets/command_chat_fab.dart';
import 'widgets/command_chat_panel.dart';

part 'app_home_data.dart';
part 'app_home_subscription.dart';
part 'app_home_navigation.dart';
part 'app_home_shopping.dart';
part 'app_home_commands.dart';
part 'app_home_build.dart';

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

  try {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
  }

  final configService = LocalConfigService();
  final savedTheme = await configService.loadThemeMode();
  final savedPalette = await configService.loadColorPalette();
  appThemeModeNotifier.value = savedTheme;
  appColorPaletteNotifier.value = savedPalette;
  AppColors.palette = savedPalette;

  try {
    await NotificationService().init();
  } catch (e) {
    debugPrint('NotificationService initialization failed: $e');
  }

  try {
    await AdService.initialize();
  } catch (e) {
    debugPrint('AdService initialization failed: $e');
  }

  try {
    await RevenueCatService.initialize();
  } catch (e) {
    debugPrint('RevenueCatService initialization failed: $e');
  }

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
  final _downgradeService = DowngradeService();
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
  NotificationPreferences _notificationPrefs = NotificationPreferences();
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

  @override
  Widget build(BuildContext context) => buildHome(context);
}
