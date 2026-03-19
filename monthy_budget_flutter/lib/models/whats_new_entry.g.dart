// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'whats_new_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WhatsNewEntry _$WhatsNewEntryFromJson(Map<String, dynamic> json) =>
    WhatsNewEntry(
      id: json['id'] as String,
      version: json['version'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      featureKey: json['featureKey'] as String?,
    );

Map<String, dynamic> _$WhatsNewEntryToJson(WhatsNewEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'version': instance.version,
      'title': instance.title,
      'body': instance.body,
      'featureKey': ?instance.featureKey,
    };
