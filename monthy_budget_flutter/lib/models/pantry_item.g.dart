// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pantry_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PantryItem _$PantryItemFromJson(Map<String, dynamic> json) => PantryItem(
  ingredientId: json['ingredientId'] as String,
  quantity: (json['quantity'] as num).toDouble(),
  unit: json['unit'] as String,
  lastRestocked: json['lastRestocked'] == null
      ? null
      : DateTime.parse(json['lastRestocked'] as String),
  lowThreshold: (json['lowThreshold'] as num?)?.toDouble(),
);

Map<String, dynamic> _$PantryItemToJson(PantryItem instance) =>
    <String, dynamic>{
      'ingredientId': instance.ingredientId,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'lastRestocked': ?instance.lastRestocked?.toIso8601String(),
      'lowThreshold': ?instance.lowThreshold,
    };
