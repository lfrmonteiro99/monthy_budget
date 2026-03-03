import 'app_settings.dart';

class ActualExpense {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String? description;
  final String monthKey;
  final String? recurringExpenseId;
  final bool isFromRecurring;

  const ActualExpense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.description,
    required this.monthKey,
    this.recurringExpenseId,
    this.isFromRecurring = false,
  });

  factory ActualExpense.create({
    required String category,
    required double amount,
    required DateTime date,
    String? description,
    String? recurringExpenseId,
    bool isFromRecurring = false,
  }) {
    final monthKey =
        '${date.year}-${date.month.toString().padLeft(2, '0')}';
    return ActualExpense(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      category: category,
      amount: amount,
      date: date,
      description: description,
      monthKey: monthKey,
      recurringExpenseId: recurringExpenseId,
      isFromRecurring: isFromRecurring,
    );
  }

  ActualExpense copyWith({
    String? id,
    String? category,
    double? amount,
    DateTime? date,
    String? description,
    String? monthKey,
    String? recurringExpenseId,
    bool? isFromRecurring,
  }) {
    final newDate = date ?? this.date;
    final newMonthKey = date != null
        ? '${newDate.year}-${newDate.month.toString().padLeft(2, '0')}'
        : (monthKey ?? this.monthKey);
    return ActualExpense(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: newDate,
      description: description ?? this.description,
      monthKey: newMonthKey,
      recurringExpenseId: recurringExpenseId ?? this.recurringExpenseId,
      isFromRecurring: isFromRecurring ?? this.isFromRecurring,
    );
  }

  factory ActualExpense.fromSupabase(Map<String, dynamic> map) {
    return ActualExpense(
      id: map['id'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      date: DateTime.parse(map['expense_date'] as String),
      description: map['description'] as String?,
      monthKey: map['month_key'] as String,
      recurringExpenseId: map['recurring_expense_id'] as String?,
      isFromRecurring: map['is_from_recurring'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toSupabase(String householdId) {
    final map = <String, dynamic>{
      'id': id,
      'household_id': householdId,
      'category': category,
      'amount': amount,
      'expense_date':
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
      'description': description,
      'month_key': monthKey,
    };
    if (recurringExpenseId != null) {
      map['recurring_expense_id'] = recurringExpenseId;
    }
    if (isFromRecurring) {
      map['is_from_recurring'] = isFromRecurring;
    }
    return map;
  }
}

class CategoryBudgetSummary {
  final String category;
  final double budgeted;
  final double actual;
  final double projectedTotal;
  final bool isOverPace;
  final String paceSeverity; // 'ok' | 'warning' | 'danger'

  const CategoryBudgetSummary({
    required this.category,
    required this.budgeted,
    required this.actual,
    this.projectedTotal = 0,
    this.isOverPace = false,
    this.paceSeverity = 'ok',
  });

  double get remaining => budgeted - actual;
  double get progress =>
      budgeted > 0 ? (actual / budgeted).clamp(0.0, 1.5) : 0;
  bool get isOver => actual > budgeted;
  bool get isCustom => budgeted == 0;

  static List<CategoryBudgetSummary> buildSummaries(
    List<ExpenseItem> budgetItems,
    List<ActualExpense> actuals, {
    Map<String, double> monthlyBudgets = const {},
    double foodPurchaseSpent = 0,
    DateTime? now,
  }) {
    final date = now ?? DateTime.now();
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    final daysElapsed = date.day;

    final actualsByCategory = <String, double>{};
    for (final e in actuals) {
      actualsByCategory[e.category] =
          (actualsByCategory[e.category] ?? 0) + e.amount;
    }

    // Merge food purchase history into alimentacao actual
    if (foodPurchaseSpent > 0) {
      actualsByCategory['alimentacao'] =
          (actualsByCategory['alimentacao'] ?? 0) + foodPurchaseSpent;
    }

    final budgetByCategory = <String, double>{};
    for (final item in budgetItems) {
      if (!item.enabled) continue;
      final catName = item.category.name;
      if (item.isFixed) {
        budgetByCategory[catName] =
            (budgetByCategory[catName] ?? 0) + item.amount;
      } else {
        // Variable: use monthly budget if set, otherwise 0
        final monthlyAmount = monthlyBudgets[catName];
        if (monthlyAmount != null) {
          budgetByCategory[catName] =
              (budgetByCategory[catName] ?? 0) + monthlyAmount;
        }
        // If not set, we still include the category with 0 budget
        // so it shows up as "unset" in the UI
        budgetByCategory.putIfAbsent(catName, () => 0);
      }
    }

    final allCategories = <String>{
      ...budgetByCategory.keys,
      ...actualsByCategory.keys,
    };

    final summaries = allCategories.map((cat) {
      final budgeted = budgetByCategory[cat] ?? 0;
      final actual = actualsByCategory[cat] ?? 0;

      // Calculate pace
      double projected = 0;
      bool overPace = false;
      String severity = 'ok';
      if (daysElapsed > 0 && actual > 0 && budgeted > 0) {
        final dailyPace = actual / daysElapsed;
        final expectedPace = budgeted / daysInMonth;
        projected = actual + (dailyPace * (daysInMonth - daysElapsed));
        overPace = projected > budgeted;
        final paceRatio = expectedPace > 0 ? dailyPace / expectedPace : 0.0;
        severity = paceRatio <= 1.0
            ? 'ok'
            : paceRatio <= 1.2
                ? 'warning'
                : 'danger';
      }

      return CategoryBudgetSummary(
        category: cat,
        budgeted: budgeted,
        actual: actual,
        projectedTotal: projected,
        isOverPace: overPace,
        paceSeverity: severity,
      );
    }).toList();

    summaries.sort((a, b) {
      if (a.isCustom != b.isCustom) return a.isCustom ? 1 : -1;
      return b.actual.compareTo(a.actual);
    });

    return summaries;
  }
}
