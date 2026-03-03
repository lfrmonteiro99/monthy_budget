class RecurringExpense {
  final String id;
  final String category;
  final double amount;
  final String? description;
  final int? dayOfMonth;
  final bool isActive;

  const RecurringExpense({
    required this.id,
    required this.category,
    required this.amount,
    this.description,
    this.dayOfMonth,
    this.isActive = true,
  });

  RecurringExpense copyWith({
    String? id,
    String? category,
    double? amount,
    String? description,
    int? dayOfMonth,
    bool? isActive,
  }) {
    return RecurringExpense(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      dayOfMonth: dayOfMonth ?? this.dayOfMonth,
      isActive: isActive ?? this.isActive,
    );
  }

  factory RecurringExpense.fromSupabase(Map<String, dynamic> map) {
    return RecurringExpense(
      id: map['id'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      description: map['description'] as String?,
      dayOfMonth: map['day_of_month'] as int?,
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toSupabase(String householdId) => {
        'id': id,
        'household_id': householdId,
        'category': category,
        'amount': amount,
        'description': description,
        'day_of_month': dayOfMonth,
        'is_active': isActive,
      };
}
