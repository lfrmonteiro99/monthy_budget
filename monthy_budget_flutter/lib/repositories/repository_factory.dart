import 'auth_repository.dart';
import 'expense_repository.dart';
import 'household_repository.dart';
import 'meal_repository.dart';
import 'product_repository.dart';
import 'savings_repository.dart';
import 'settings_repository.dart';
import 'shopping_repository.dart';

/// Single place where the concrete repository implementations are chosen.
///
/// Services keep their constructor-injection parameters — an explicitly
/// injected repository always wins. This provider only answers the
/// "nothing was injected" case that used to hard-code `Supabase*Repository()`.
abstract class RepositoryProvider {
  AuthRepository get auth;
  ExpenseRepository get expense;
  BudgetRepository get budget;
  RecurringExpenseRepository get recurringExpense;
  ExpenseSnapshotRepository get expenseSnapshot;
  HouseholdRepository get household;
  HouseholdActivityRepository get householdActivity;
  CoachInsightRepository get coachInsight;
  MealPlanRepository get mealPlan;
  MealPlannerAiRepository get mealPlannerAi;
  ProductRepository get product;
  MerchantRepository get merchant;
  SavingsRepository get savings;
  SettingsRepository get settings;
  ShoppingRepository get shopping;
  PurchaseRepository get purchase;
}

/// Production provider. Constructs a fresh instance per call, exactly like the
/// inline `??= Supabase*Repository()` expressions it replaced — the calling
/// service still caches the result, and constructors that throw when Supabase
/// is unconfigured keep throwing at the same moment.
class SupabaseRepositoryProvider implements RepositoryProvider {
  const SupabaseRepositoryProvider();

  @override
  AuthRepository get auth => SupabaseAuthRepository();

  @override
  ExpenseRepository get expense => SupabaseExpenseRepository();

  @override
  BudgetRepository get budget => SupabaseBudgetRepository();

  @override
  RecurringExpenseRepository get recurringExpense =>
      SupabaseRecurringExpenseRepository();

  @override
  ExpenseSnapshotRepository get expenseSnapshot =>
      SupabaseExpenseSnapshotRepository();

  @override
  HouseholdRepository get household => SupabaseHouseholdRepository();

  @override
  HouseholdActivityRepository get householdActivity =>
      SupabaseHouseholdActivityRepository();

  @override
  CoachInsightRepository get coachInsight => SupabaseCoachInsightRepository();

  @override
  MealPlanRepository get mealPlan => SupabaseMealPlanRepository();

  @override
  MealPlannerAiRepository get mealPlannerAi => SupabaseMealPlannerAiRepository();

  @override
  ProductRepository get product => SupabaseProductRepository();

  @override
  MerchantRepository get merchant => SupabaseMerchantRepository();

  @override
  SavingsRepository get savings => SupabaseSavingsRepository();

  @override
  SettingsRepository get settings => SupabaseSettingsRepository();

  @override
  ShoppingRepository get shopping => SupabaseShoppingRepository();

  @override
  PurchaseRepository get purchase => SupabasePurchaseRepository();
}

class RepositoryFactory {
  RepositoryFactory._();

  /// Swapped once, before `runApp`, by QA mode. Also the seam that makes the
  /// services injectable from widget tests.
  static RepositoryProvider instance = const SupabaseRepositoryProvider();

  /// Restores the production provider. Intended for test teardown.
  static void reset() => instance = const SupabaseRepositoryProvider();
}
