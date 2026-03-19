import 'package:json_annotation/json_annotation.dart';

part 'expense_snapshot.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ExpenseSnapshot {
  final String expenseId;
  final String label;
  final String category;
  final double amount;
  @JsonKey(defaultValue: true)
  final bool enabled;

  const ExpenseSnapshot({
    required this.expenseId,
    required this.label,
    required this.category,
    required this.amount,
    required this.enabled,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseSnapshot &&
          expenseId == other.expenseId &&
          label == other.label &&
          category == other.category &&
          amount == other.amount &&
          enabled == other.enabled;

  @override
  int get hashCode => Object.hash(expenseId, label, category, amount, enabled);

  Map<String, dynamic> toJson() => _$ExpenseSnapshotToJson(this);

  factory ExpenseSnapshot.fromJson(Map<String, dynamic> json) =>
      _$ExpenseSnapshotFromJson(json);
}
