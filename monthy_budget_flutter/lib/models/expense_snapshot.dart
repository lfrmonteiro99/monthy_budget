class ExpenseSnapshot {
  final String expenseId;
  final String label;
  final String category;
  final double amount;
  final bool enabled;

  const ExpenseSnapshot({
    required this.expenseId,
    required this.label,
    required this.category,
    required this.amount,
    required this.enabled,
  });

  factory ExpenseSnapshot.fromJson(Map<String, dynamic> json) => ExpenseSnapshot(
        expenseId: json['expense_id'] as String,
        label: json['label'] as String,
        category: json['category'] as String,
        amount: (json['amount'] as num).toDouble(),
        enabled: json['enabled'] as bool? ?? true,
      );
}
