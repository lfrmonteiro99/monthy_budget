// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) => Product(
  id: json['id'] as String,
  name: json['name'] as String,
  category: json['category'] as String,
  avgPrice: (json['avg_price'] as num).toDouble(),
  unit: json['unit'] as String,
  barcode: json['barcode'] as String?,
);

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'category': instance.category,
  'avg_price': instance.avgPrice,
  'unit': instance.unit,
  'barcode': ?instance.barcode,
};
