import 'package:json_annotation/json_annotation.dart';

part 'recurring_expense.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RecurringExpense {
  final String id;
  final String category;
  @JsonKey(fromJson: _amountFromJson)
  final double amount;
  final String? description;
  final int? dayOfMonth;
  final bool isActive;

  RecurringExpense({
    required this.id,
    required this.category,
    required this.amount,
    this.description,
    this.dayOfMonth,
    this.isActive = true,
  }) : assert(amount >= 0, 'amount must be non-negative');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecurringExpense &&
          id == other.id &&
          category == other.category &&
          amount == other.amount &&
          description == other.description &&
          dayOfMonth == other.dayOfMonth &&
          isActive == other.isActive;

  @override
  int get hashCode =>
      Object.hash(id, category, amount, description, dayOfMonth, isActive);

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

  factory RecurringExpense.fromSupabase(Map<String, dynamic> map) =>
      RecurringExpense.fromJson(map);

  Map<String, dynamic> toSupabase(String householdId) => {
        ...toJson(),
        'household_id': householdId,
      };

  factory RecurringExpense.fromJson(Map<String, dynamic> json) =>
      _$RecurringExpenseFromJson(json);

  Map<String, dynamic> toJson() => _$RecurringExpenseToJson(this);

  static double _amountFromJson(Object? value) {
    final rawAmount = (value as num?)?.toDouble() ?? 0;
    return rawAmount < 0 ? 0 : rawAmount;
  }
}
