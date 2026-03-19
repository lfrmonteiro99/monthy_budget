// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'monthly_budget.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonthlyBudget _$MonthlyBudgetFromJson(Map<String, dynamic> json) =>
    MonthlyBudget(
      id: json['id'] as String,
      category: json['category'] as String,
      amount: MonthlyBudget._amountFromJson(json['amount']),
      monthKey: json['month_key'] as String,
    );

Map<String, dynamic> _$MonthlyBudgetToJson(MonthlyBudget instance) =>
    <String, dynamic>{
      'id': instance.id,
      'category': instance.category,
      'amount': instance.amount,
      'month_key': instance.monthKey,
    };
