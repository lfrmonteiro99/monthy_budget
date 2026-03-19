// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_expense.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecurringExpense _$RecurringExpenseFromJson(Map<String, dynamic> json) =>
    RecurringExpense(
      id: json['id'] as String,
      category: json['category'] as String,
      amount: RecurringExpense._amountFromJson(json['amount']),
      description: json['description'] as String?,
      dayOfMonth: (json['day_of_month'] as num?)?.toInt(),
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$RecurringExpenseToJson(RecurringExpense instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'amount': instance.amount,
      'description': instance.description,
      'day_of_month': instance.dayOfMonth,
      'is_active': instance.isActive,
    };
