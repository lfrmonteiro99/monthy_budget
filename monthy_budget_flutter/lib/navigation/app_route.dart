import '../constants/app_constants.dart';

enum SettingsSection {
  salaries('salaries'),
  expenses('expenses'),
  meals('meals'),
  favorites('favorites'),
  appearance('appearance'),
  dashboard('dashboard'),
  profile('profile'),
  coach('coach'),
  household('household');

  const SettingsSection(this.key);

  final String key;

  static SettingsSection? fromKey(String? key) {
    if (key == null || key.isEmpty) return null;
    for (final section in values) {
      if (section.key == key) return section;
    }
    return null;
  }
}

enum AppRouteType {
  tab,
  addExpense,
  shoppingList,
  mealPlanner,
  assistant,
  scanReceipt,
  settings,
  expenseTrends,
  savingsGoals,
  productUpdates,
  notificationSettings,
  coach,
  insights,
  grocery,
  confidenceCenter,
  taxSimulator,
  yearlySummary,
  income,
}

class AppRoute {
  const AppRoute._({required this.type, this.tab, this.settingsSection});

  const AppRoute.tab(AppTab this.tab)
    : type = AppRouteType.tab,
      settingsSection = null;

  const AppRoute.addExpense() : this._(type: AppRouteType.addExpense);

  const AppRoute.shoppingList() : this._(type: AppRouteType.shoppingList);

  const AppRoute.mealPlanner() : this._(type: AppRouteType.mealPlanner);

  const AppRoute.assistant() : this._(type: AppRouteType.assistant);

  const AppRoute.scanReceipt() : this._(type: AppRouteType.scanReceipt);

  const AppRoute.settings({SettingsSection? section})
    : this._(type: AppRouteType.settings, settingsSection: section);

  const AppRoute.expenseTrends() : this._(type: AppRouteType.expenseTrends);

  const AppRoute.savingsGoals() : this._(type: AppRouteType.savingsGoals);

  const AppRoute.productUpdates() : this._(type: AppRouteType.productUpdates);

  const AppRoute.notificationSettings()
    : this._(type: AppRouteType.notificationSettings);

  const AppRoute.coach() : this._(type: AppRouteType.coach);

  const AppRoute.insights() : this._(type: AppRouteType.insights);

  const AppRoute.grocery() : this._(type: AppRouteType.grocery);

  const AppRoute.confidenceCenter()
    : this._(type: AppRouteType.confidenceCenter);

  const AppRoute.taxSimulator() : this._(type: AppRouteType.taxSimulator);

  const AppRoute.yearlySummary() : this._(type: AppRouteType.yearlySummary);

  const AppRoute.income() : this._(type: AppRouteType.income);

  final AppRouteType type;
  final AppTab? tab;
  final SettingsSection? settingsSection;

  @override
  bool operator ==(Object other) {
    return other is AppRoute &&
        other.type == type &&
        other.tab == tab &&
        other.settingsSection == settingsSection;
  }

  @override
  int get hashCode => Object.hash(type, tab, settingsSection);

  static AppRoute? fromUri(Uri? uri) {
    if (uri == null || uri.scheme != 'orcamentomensal') return null;

    switch (uri.host) {
      case 'dashboard':
        return const AppRoute.tab(AppTab.dashboard);
      case 'expenses':
        return const AppRoute.tab(AppTab.expenses);
      case 'plan':
      case 'shopping':
        return const AppRoute.tab(AppTab.planHub);
      case 'more':
        return const AppRoute.tab(AppTab.more);
      case 'yearly-summary':
        return const AppRoute.yearlySummary();
      case 'settings':
        return AppRoute.settings(
          section: SettingsSection.fromKey(
            uri.pathSegments.isEmpty ? null : uri.pathSegments.first,
          ),
        );
      case 'quick-add':
        switch (uri.path) {
          case '/shopping':
            return const AppRoute.shoppingList();
          case '/receipt':
            return const AppRoute.scanReceipt();
          case '/expense':
          case '':
          case '/':
            return const AppRoute.addExpense();
        }
        return const AppRoute.addExpense();
      case 'meals':
        return const AppRoute.mealPlanner();
      case 'assistant':
        return const AppRoute.assistant();
      case 'coach':
        return const AppRoute.coach();
      case 'insights':
        return const AppRoute.insights();
      case 'grocery':
        return const AppRoute.grocery();
      case 'savings-goals':
        return const AppRoute.savingsGoals();
      case 'income':
        return const AppRoute.income();
      default:
        return null;
    }
  }

  static AppRoute fromCommandTarget(String target) {
    return switch (target) {
      'dashboard' => const AppRoute.tab(AppTab.dashboard),
      'expenses' => const AppRoute.tab(AppTab.expenses),
      'plan' ||
      'grocery' ||
      'shopping_list' ||
      'meals' => const AppRoute.tab(AppTab.planHub),
      'more' => const AppRoute.tab(AppTab.more),
      'yearly_summary' => const AppRoute.yearlySummary(),
      'coach' => const AppRoute.coach(),
      'settings' => const AppRoute.settings(),
      'insights' => const AppRoute.insights(),
      'savings_goals' => const AppRoute.savingsGoals(),
      'income' => const AppRoute.income(),
      _ => const AppRoute.tab(AppTab.dashboard),
    };
  }

  static AppRoute fromFeatureKey(String featureKey) {
    return switch (featureKey) {
      'ai_coach' => const AppRoute.coach(),
      'meal_planner' => const AppRoute.mealPlanner(),
      'expense_tracker' => const AppRoute.tab(AppTab.expenses),
      'savings_goals' => const AppRoute.savingsGoals(),
      'shopping_list' ||
      'grocery_browser' => const AppRoute.tab(AppTab.planHub),
      'export' || 'tax_simulator' => const AppRoute.settings(),
      _ => const AppRoute.tab(AppTab.dashboard),
    };
  }
}
