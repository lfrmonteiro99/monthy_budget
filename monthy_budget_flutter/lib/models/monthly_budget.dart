import 'package:json_annotation/json_annotation.dart';

part 'monthly_budget.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MonthlyBudget {
  final String id;
  final String category;
  @JsonKey(fromJson: _amountFromJson)
  final double amount;
  final String monthKey;

  MonthlyBudget({
    required this.id,
    required this.category,
    required this.amount,
    required this.monthKey,
  }) : assert(amount >= 0, 'amount must be non-negative');

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyBudget &&
          id == other.id &&
          category == other.category &&
          amount == other.amount &&
          monthKey == other.monthKey;

  @override
  int get hashCode => Object.hash(id, category, amount, monthKey);

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

  factory MonthlyBudget.fromSupabase(Map<String, dynamic> map) =>
      MonthlyBudget.fromJson(map);

  Map<String, dynamic> toSupabase(String householdId) => {
        ...toJson(),
        'household_id': householdId,
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

  factory MonthlyBudget.fromJson(Map<String, dynamic> json) =>
      _$MonthlyBudgetFromJson(json);

  Map<String, dynamic> toJson() => _$MonthlyBudgetToJson(this);

  static double _amountFromJson(Object? value) {
    final rawAmount = (value as num?)?.toDouble() ?? 0;
    return rawAmount < 0 ? 0 : rawAmount;
  }
}
