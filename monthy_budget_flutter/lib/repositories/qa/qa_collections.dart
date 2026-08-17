/// Collection names used by the QA repositories inside `qa_documents`.
///
/// Deliberately mirror the Supabase table names so a payload written by a QA
/// repository is the same map the Supabase repository would have read back.
class QaCollections {
  QaCollections._();

  static const profiles = 'profiles';
  static const households = 'households';
  static const householdInvites = 'household_invites';
  static const householdSettings = 'household_settings';
  static const householdFavorites = 'household_favorites';
  static const customCategories = 'custom_categories';
  static const actualExpenses = 'actual_expenses';
  static const monthlyBudgets = 'monthly_budgets';
  static const recurringExpenses = 'recurring_expenses';
  static const recurringExpenseRuns = 'recurring_expense_runs';
  static const expenseSnapshots = 'expense_snapshots';
  static const savingsGoals = 'savings_goals';
  static const savingsContributions = 'savings_contributions';
  static const shoppingItems = 'shopping_items';
  static const purchaseRecords = 'purchase_records';
  static const activityEvents = 'household_activity_events';
  static const coachInsights = 'household_coach_insights';
  static const mealPlans = 'meal_plans';
  static const products = 'products';
  static const merchants = 'merchant_nif_registry';

  /// Marker collection whose single row records that the seed already ran, so a
  /// browser reload reuses the persisted sqlite data instead of duplicating it.
  static const seedMarker = 'qa_seed_marker';
}
