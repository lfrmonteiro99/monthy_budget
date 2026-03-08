import 'dart:convert';

enum SyncDomain {
  settings,
  shopping,
  mealPlan,
  expenses,
  purchaseHistory,
  savingsGoals,
  recurringExpenses,
}

enum AlertSeverity {
  info,
  warning,
  critical;

  /// Higher = more urgent. Useful for sorting critical-first.
  int get sortOrder => switch (this) {
        AlertSeverity.critical => 0,
        AlertSeverity.warning => 1,
        AlertSeverity.info => 2,
      };
}

class SyncDomainStatus {
  final SyncDomain domain;
  final DateTime? lastLoadAt;
  final DateTime? lastSaveAt;
  final DateTime? lastErrorAt;
  final String? lastErrorMessage;

  /// How long after last load/save before the domain is considered stale.
  final Duration staleAfter;

  const SyncDomainStatus({
    required this.domain,
    this.lastLoadAt,
    this.lastSaveAt,
    this.lastErrorAt,
    this.lastErrorMessage,
    this.staleAfter = const Duration(hours: 24),
  });

  /// The most recent successful sync (load or save).
  DateTime? get lastSuccessAt {
    if (lastLoadAt == null) return lastSaveAt;
    if (lastSaveAt == null) return lastLoadAt;
    return lastLoadAt!.isAfter(lastSaveAt!) ? lastLoadAt : lastSaveAt;
  }

  /// True when the domain has synced at least once and is not past its stale
  /// threshold, and has no unresolved error after the last success.
  bool get isHealthy {
    final success = lastSuccessAt;
    if (success == null) return false;
    final now = DateTime.now();
    if (now.difference(success) > staleAfter) return false;
    if (lastErrorAt != null && lastErrorAt!.isAfter(success)) return false;
    return true;
  }

  /// True when the domain has never synced or is past its stale threshold.
  bool get isStale {
    final success = lastSuccessAt;
    if (success == null) return true;
    return DateTime.now().difference(success) > staleAfter;
  }

  /// True when the most recent event for this domain was an error.
  bool get hasRecentError {
    if (lastErrorAt == null) return false;
    final success = lastSuccessAt;
    if (success == null) return true;
    return lastErrorAt!.isAfter(success);
  }

  SyncDomainStatus copyWith({
    DateTime? lastLoadAt,
    DateTime? lastSaveAt,
    DateTime? lastErrorAt,
    String? lastErrorMessage,
    Duration? staleAfter,
  }) {
    return SyncDomainStatus(
      domain: domain,
      lastLoadAt: lastLoadAt ?? this.lastLoadAt,
      lastSaveAt: lastSaveAt ?? this.lastSaveAt,
      lastErrorAt: lastErrorAt ?? this.lastErrorAt,
      lastErrorMessage: lastErrorMessage ?? this.lastErrorMessage,
      staleAfter: staleAfter ?? this.staleAfter,
    );
  }

  Map<String, dynamic> toJson() => {
        'domain': domain.name,
        'lastLoadAt': lastLoadAt?.toIso8601String(),
        'lastSaveAt': lastSaveAt?.toIso8601String(),
        'lastErrorAt': lastErrorAt?.toIso8601String(),
        'lastErrorMessage': lastErrorMessage,
        'staleAfterMs': staleAfter.inMilliseconds,
      };

  factory SyncDomainStatus.fromJson(Map<String, dynamic> json) {
    return SyncDomainStatus(
      domain: SyncDomain.values.firstWhere(
        (d) => d.name == json['domain'],
        orElse: () => SyncDomain.settings,
      ),
      lastLoadAt: json['lastLoadAt'] != null
          ? DateTime.parse(json['lastLoadAt'] as String)
          : null,
      lastSaveAt: json['lastSaveAt'] != null
          ? DateTime.parse(json['lastSaveAt'] as String)
          : null,
      lastErrorAt: json['lastErrorAt'] != null
          ? DateTime.parse(json['lastErrorAt'] as String)
          : null,
      lastErrorMessage: json['lastErrorMessage'] as String?,
      staleAfter:
          Duration(milliseconds: (json['staleAfterMs'] as int?) ?? 86400000),
    );
  }
}

class DataAlert {
  final String id;
  final AlertSeverity severity;
  final SyncDomain? domain;
  final String title;
  final String body;
  final String? recommendedAction;
  final DateTime createdAt;

  const DataAlert({
    required this.id,
    required this.severity,
    this.domain,
    required this.title,
    required this.body,
    this.recommendedAction,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'severity': severity.name,
        'domain': domain?.name,
        'title': title,
        'body': body,
        'recommendedAction': recommendedAction,
        'createdAt': createdAt.toIso8601String(),
      };

  factory DataAlert.fromJson(Map<String, dynamic> json) {
    return DataAlert(
      id: json['id'] as String,
      severity: AlertSeverity.values.firstWhere(
        (s) => s.name == json['severity'],
        orElse: () => AlertSeverity.info,
      ),
      domain: json['domain'] != null
          ? SyncDomain.values.firstWhere(
              (d) => d.name == json['domain'],
              orElse: () => SyncDomain.settings,
            )
          : null,
      title: json['title'] as String,
      body: json['body'] as String,
      recommendedAction: json['recommendedAction'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Convenience for persisting a list of [SyncDomainStatus] as JSON.
String encodeDomainStatuses(Map<SyncDomain, SyncDomainStatus> statuses) {
  return jsonEncode(statuses.values.map((s) => s.toJson()).toList());
}

Map<SyncDomain, SyncDomainStatus> decodeDomainStatuses(String json) {
  final list = (jsonDecode(json) as List<dynamic>)
      .map((e) => SyncDomainStatus.fromJson(e as Map<String, dynamic>))
      .toList();
  return {for (final s in list) s.domain: s};
}
