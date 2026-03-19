// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_snapshot.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpenseSnapshot _$ExpenseSnapshotFromJson(Map<String, dynamic> json) =>
    ExpenseSnapshot(
      expenseId: json['expense_id'] as String,
      label: json['label'] as String,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      enabled: json['enabled'] as bool? ?? true,
    );

Map<String, dynamic> _$ExpenseSnapshotToJson(ExpenseSnapshot instance) =>
    <String, dynamic>{
      'expense_id': instance.expenseId,
      'label': instance.label,
      'category': instance.category,
      'amount': instance.amount,
      'enabled': instance.enabled,
    };
