// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_health_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SyncDomainStatus _$SyncDomainStatusFromJson(Map<String, dynamic> json) =>
    SyncDomainStatus(
      domain: $enumDecode(
        _$SyncDomainEnumMap,
        json['domain'],
        unknownValue: SyncDomain.settings,
      ),
      lastLoadAt: json['lastLoadAt'] == null
          ? null
          : DateTime.parse(json['lastLoadAt'] as String),
      lastSaveAt: json['lastSaveAt'] == null
          ? null
          : DateTime.parse(json['lastSaveAt'] as String),
      lastErrorAt: json['lastErrorAt'] == null
          ? null
          : DateTime.parse(json['lastErrorAt'] as String),
      lastErrorMessage: json['lastErrorMessage'] as String?,
      staleAfter: json['staleAfter'] == null
          ? const Duration(hours: 24)
          : SyncDomainStatus._durationFromJson(json['staleAfter']),
    );

Map<String, dynamic> _$SyncDomainStatusToJson(SyncDomainStatus instance) =>
    <String, dynamic>{
      'domain': _$SyncDomainEnumMap[instance.domain]!,
      'lastLoadAt': instance.lastLoadAt?.toIso8601String(),
      'lastSaveAt': instance.lastSaveAt?.toIso8601String(),
      'lastErrorAt': instance.lastErrorAt?.toIso8601String(),
      'lastErrorMessage': instance.lastErrorMessage,
      'staleAfter': SyncDomainStatus._durationToJson(instance.staleAfter),
    };

const _$SyncDomainEnumMap = {
  SyncDomain.settings: 'settings',
  SyncDomain.shopping: 'shopping',
  SyncDomain.mealPlan: 'mealPlan',
  SyncDomain.expenses: 'expenses',
  SyncDomain.purchaseHistory: 'purchaseHistory',
  SyncDomain.savingsGoals: 'savingsGoals',
  SyncDomain.recurringExpenses: 'recurringExpenses',
};

DataAlert _$DataAlertFromJson(Map<String, dynamic> json) => DataAlert(
  id: json['id'] as String,
  severity: $enumDecode(
    _$AlertSeverityEnumMap,
    json['severity'],
    unknownValue: AlertSeverity.info,
  ),
  domain: $enumDecodeNullable(
    _$SyncDomainEnumMap,
    json['domain'],
    unknownValue: SyncDomain.settings,
  ),
  title: json['title'] as String,
  body: json['body'] as String,
  recommendedAction: json['recommendedAction'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$DataAlertToJson(DataAlert instance) => <String, dynamic>{
  'id': instance.id,
  'severity': _$AlertSeverityEnumMap[instance.severity]!,
  'domain': ?_$SyncDomainEnumMap[instance.domain],
  'title': instance.title,
  'body': instance.body,
  'recommendedAction': ?instance.recommendedAction,
  'createdAt': instance.createdAt.toIso8601String(),
};

const _$AlertSeverityEnumMap = {
  AlertSeverity.info: 'info',
  AlertSeverity.warning: 'warning',
  AlertSeverity.critical: 'critical',
};
