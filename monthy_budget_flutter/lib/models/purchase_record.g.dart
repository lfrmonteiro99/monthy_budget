// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PurchaseRecord _$PurchaseRecordFromJson(Map<String, dynamic> json) =>
    PurchaseRecord(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      itemCount: (json['itemCount'] as num).toInt(),
      items:
          (json['items'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      isMealPurchase: json['isMealPurchase'] as bool? ?? false,
    );

Map<String, dynamic> _$PurchaseRecordToJson(PurchaseRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'amount': instance.amount,
      'itemCount': instance.itemCount,
      'items': instance.items,
      'isMealPurchase': instance.isMealPurchase,
    };

PurchaseHistory _$PurchaseHistoryFromJson(Map<String, dynamic> json) =>
    PurchaseHistory(
      records:
          (json['records'] as List<dynamic>?)
              ?.map((e) => PurchaseRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$PurchaseHistoryToJson(PurchaseHistory instance) =>
    <String, dynamic>{
      'records': instance.records.map((e) => e.toJson()).toList(),
    };
