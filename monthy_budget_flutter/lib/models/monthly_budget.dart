class MonthlyBudget {
  final String id;
  final String category;
  final double amount;
  final String monthKey;

  const MonthlyBudget({
    required this.id,
    required this.category,
    required this.amount,
    required this.monthKey,
  });

  factory MonthlyBudget.create({
    required String category,
    required double amount,
    required String monthKey,
  }) {
    return MonthlyBudget(
      id: 'mb_${DateTime.now().millisecondsSinceEpoch}_$category',
      category: category,
      amount: amount,
      monthKey: monthKey,
    );
  }

  factory MonthlyBudget.fromSupabase(Map<String, dynamic> map) {
    return MonthlyBudget(
      id: map['id'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      monthKey: map['month_key'] as String,
    );
  }

  Map<String, dynamic> toSupabase(String householdId) => {
        'id': id,
        'household_id': householdId,
        'category': category,
        'amount': amount,
        'month_key': monthKey,
      };

  MonthlyBudget copyWith({
    String? id,
    String? category,
    double? amount,
    String? monthKey,
  }) {
    return MonthlyBudget(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      monthKey: monthKey ?? this.monthKey,
    );
  }
}
