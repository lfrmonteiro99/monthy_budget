import '../auth_repository.dart';
import '../expense_repository.dart';
import '../household_repository.dart';
import '../local/qa_local_store.dart';
import '../meal_repository.dart';
import '../product_repository.dart';
import '../repository_factory.dart';
import '../savings_repository.dart';
import '../settings_repository.dart';
import '../shopping_repository.dart';
import 'qa_auth_repository.dart';
import 'qa_expense_repository.dart';
import 'qa_household_repository.dart';
import 'qa_meal_repository.dart';
import 'qa_product_repository.dart';
import 'qa_savings_repository.dart';
import 'qa_seed.dart';
import 'qa_settings_repository.dart';
import 'qa_shopping_repository.dart';

/// [RepositoryProvider] backed entirely by [QaLocalStore].
///
/// Unlike [SupabaseRepositoryProvider] the instances are cached: the shopping
/// repository owns broadcast stream controllers, so handing out fresh copies
/// would break the stream-driven shopping UI.
class QaRepositoryProvider implements RepositoryProvider {
  QaRepositoryProvider({
    required QaLocalStore store,
    required String householdId,
    required String userId,
    required String userEmail,
    required DateTime Function() now,
  }) : _store = store,
       _householdId = householdId,
       _userId = userId,
       _userEmail = userEmail,
       _now = now;

  final QaLocalStore _store;
  final String _householdId;
  final String _userId;
  final String _userEmail;
  final DateTime Function() _now;

  @override
  late final AuthRepository auth = QaAuthRepository(
    userId: _userId,
    email: _userEmail,
    // Backdated so trial/subscription logic keyed on account age behaves like a
    // long-standing account rather than a brand-new signup.
    accountCreatedAt: _now().subtract(const Duration(days: 400)),
  );

  @override
  late final ExpenseRepository expense = QaExpenseRepository(_store, now: _now);

  @override
  late final BudgetRepository budget = QaBudgetRepository(_store);

  @override
  late final RecurringExpenseRepository recurringExpense =
      QaRecurringExpenseRepository(_store);

  @override
  late final ExpenseSnapshotRepository expenseSnapshot =
      QaExpenseSnapshotRepository(_store, now: _now);

  @override
  late final HouseholdRepository household = QaHouseholdRepository(
    _store,
    householdId: _householdId,
    now: _now,
  );

  @override
  late final HouseholdActivityRepository householdActivity =
      QaHouseholdActivityRepository(_store, now: _now);

  @override
  late final CoachInsightRepository coachInsight = QaCoachInsightRepository(
    _store,
  );

  @override
  late final MealPlanRepository mealPlan = QaMealPlanRepository(
    _store,
    now: _now,
  );

  @override
  late final MealPlannerAiRepository mealPlannerAi =
      const QaMealPlannerAiRepository();

  @override
  late final ProductRepository product = QaProductRepository(_store);

  @override
  late final MerchantRepository merchant = QaMerchantRepository(
    _store,
    globalScope: QaSeed.globalScope,
  );

  @override
  late final SavingsRepository savings = QaSavingsRepository(_store, now: _now);

  @override
  late final SettingsRepository settings = QaSettingsRepository(
    _store,
    now: _now,
  );

  @override
  late final ShoppingRepository shopping = QaShoppingRepository(
    _store,
    now: _now,
  );

  @override
  late final PurchaseRepository purchase = QaPurchaseRepository(_store);
}
