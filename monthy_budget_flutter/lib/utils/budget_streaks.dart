import '../models/actual_expense.dart';
import '../models/app_settings.dart';
import '../models/purchase_record.dart';

enum StreakTier { bronze, silver, gold }

class StreakResult {
  final StreakTier tier;
  final int count;

  const StreakResult({required this.tier, this.count = 0});
}

class AllStreaks {
  final StreakResult bronze;
  final StreakResult silver;
  final StreakResult gold;

  const AllStreaks({
    this.bronze = const StreakResult(tier: StreakTier.bronze),
    this.silver = const StreakResult(tier: StreakTier.silver),
    this.gold = const StreakResult(tier: StreakTier.gold),
  });
}

/// Calculates budget streaks for all three tiers.
///
/// Parameters:
/// - `actualExpenseHistory`: Map of monthKey to list of ActualExpense
/// - [expenses]: Budget expense items (for per-category budgets)
/// - [totalNetIncome]: Total net income with meal allowance
/// - [purchaseHistory]: For food spending per month
/// - [monthlyBudgets]: Variable budget overrides for current month
AllStreaks calculateStreaks({
  required Map<String, List<ActualExpense>> actualExpenseHistory,
  required List<ExpenseItem> expenses,
  required double totalNetIncome,
  required PurchaseHistory purchaseHistory,
  Map<String, double> monthlyBudgets = const {},
}) {
  if (actualExpenseHistory.isEmpty) return const AllStreaks();

  final now = DateTime.now();
  final currentMonthKey =
      '${now.year}-${now.month.toString().padLeft(2, '0')}';

  // Sort month keys in reverse order, skip current month
  final monthKeys = actualExpenseHistory.keys
      .where((k) => k != currentMonthKey)
      .toList()
    ..sort((a, b) => b.compareTo(a));

  if (monthKeys.isEmpty) return const AllStreaks();

  // Sum per-category default amounts from expense items
  final defaultByCategory = <String, double>{};
  for (final item in expenses) {
    if (!item.enabled) continue;
    final catName = item.category;
    defaultByCategory[catName] = (defaultByCategory[catName] ?? 0) + item.amount;
  }

  // Apply monthly overrides at category level
  final budgetByCategory = <String, double>{};
  for (final entry in defaultByCategory.entries) {
    budgetByCategory[entry.key] = monthlyBudgets[entry.key] ?? entry.value;
  }

  final totalBudget = budgetByCategory.values.fold(0.0, (sum, v) => sum + v);

  int bronzeCount = 0;
  int silverCount = 0;
  int goldCount = 0;
  bool bronzeBroken = false;
  bool silverBroken = false;
  bool goldBroken = false;

  for (final monthKey in monthKeys) {
    final actuals = actualExpenseHistory[monthKey] ?? [];
    if (actuals.isEmpty) break; // No data for this month, end all streaks

    // Parse month for food spending
    final parts = monthKey.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final foodSpent = purchaseHistory.spentInMonth(year, month);

    // Aggregate actuals by category
    final actualByCategory = <String, double>{};
    double totalActual = 0;
    for (final e in actuals) {
      actualByCategory[e.category] =
          (actualByCategory[e.category] ?? 0) + e.amount;
      totalActual += e.amount;
    }

    // Add food purchases to alimentacao
    if (foodSpent > 0) {
      actualByCategory['alimentacao'] =
          (actualByCategory['alimentacao'] ?? 0) + foodSpent;
      totalActual += foodSpent;
    }

    // Bronze: Net liquidity > 0 (income > total spending)
    if (!bronzeBroken) {
      if (totalNetIncome > totalActual) {
        bronzeCount++;
      } else {
        bronzeBroken = true;
      }
    }

    // Silver: Total actual <= total budget
    if (!silverBroken) {
      if (totalActual <= totalBudget && totalBudget > 0) {
        silverCount++;
      } else {
        silverBroken = true;
      }
    }

    // Gold: Every category actual <= budgeted
    if (!goldBroken) {
      bool allUnder = true;
      for (final entry in actualByCategory.entries) {
        final budget = budgetByCategory[entry.key] ?? 0;
        if (budget > 0 && entry.value > budget) {
          allUnder = false;
          break;
        }
      }
      if (allUnder && totalBudget > 0) {
        goldCount++;
      } else {
        goldBroken = true;
      }
    }

    // If all streaks are broken, stop
    if (bronzeBroken && silverBroken && goldBroken) break;
  }

  return AllStreaks(
    bronze: StreakResult(tier: StreakTier.bronze, count: bronzeCount),
    silver: StreakResult(tier: StreakTier.silver, count: silverCount),
    gold: StreakResult(tier: StreakTier.gold, count: goldCount),
  );
}
