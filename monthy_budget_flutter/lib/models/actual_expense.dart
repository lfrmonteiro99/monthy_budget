import 'app_settings.dart';

class ActualExpense {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String? description;
  final String monthKey;

  const ActualExpense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.description,
    required this.monthKey,
  });

  factory ActualExpense.create({
    required String category,
    required double amount,
    required DateTime date,
    String? description,
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
    );
  }

  ActualExpense copyWith({
    String? id,
    String? category,
    double? amount,
    DateTime? date,
    String? description,
    String? monthKey,
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
    );
  }

  Map<String, dynamic> toSupabase(String householdId) => {
        'id': id,
        'household_id': householdId,
        'category': category,
        'amount': amount,
        'expense_date':
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
        'description': description,
        'month_key': monthKey,
      };
}

class CategoryBudgetSummary {
  final String category;
  final double budgeted;
  final double actual;

  const CategoryBudgetSummary({
    required this.category,
    required this.budgeted,
    required this.actual,
  });

  double get remaining => budgeted - actual;
  double get progress =>
      budgeted > 0 ? (actual / budgeted).clamp(0.0, 1.5) : 0;
  bool get isOver => actual > budgeted;
  bool get isCustom => budgeted == 0;

  static List<CategoryBudgetSummary> buildSummaries(
    List<ExpenseItem> budgetItems,
    List<ActualExpense> actuals,
  ) {
    final actualsByCategory = <String, double>{};
    for (final e in actuals) {
      actualsByCategory[e.category] =
          (actualsByCategory[e.category] ?? 0) + e.amount;
    }

    final budgetByCategory = <String, double>{};
    for (final item in budgetItems) {
      if (!item.enabled) continue;
      budgetByCategory[item.category.name] =
          (budgetByCategory[item.category.name] ?? 0) + item.amount;
    }

    final allCategories = <String>{
      ...budgetByCategory.keys,
      ...actualsByCategory.keys,
    };

    final summaries = allCategories.map((cat) {
      return CategoryBudgetSummary(
        category: cat,
        budgeted: budgetByCategory[cat] ?? 0,
        actual: actualsByCategory[cat] ?? 0,
      );
    }).toList();

    summaries.sort((a, b) {
      if (a.isCustom != b.isCustom) return a.isCustom ? 1 : -1;
      return b.actual.compareTo(a.actual);
    });

    return summaries;
  }
}
