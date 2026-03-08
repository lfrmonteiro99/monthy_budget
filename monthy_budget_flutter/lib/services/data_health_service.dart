import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_health_status.dart';

/// Records sync timestamps per domain and exposes aggregate health status.
///
/// Persistence is via SharedPreferences (local, per-device).
class DataHealthService {
  static const _storageKey = 'data_health_statuses';

  /// Default stale thresholds per domain.
  static const _staleThresholds = <SyncDomain, Duration>{
    SyncDomain.settings: Duration(hours: 48),
    SyncDomain.shopping: Duration(hours: 24),
    SyncDomain.mealPlan: Duration(days: 7),
    SyncDomain.expenses: Duration(hours: 24),
    SyncDomain.purchaseHistory: Duration(hours: 48),
    SyncDomain.savingsGoals: Duration(hours: 48),
    SyncDomain.recurringExpenses: Duration(hours: 48),
  };

  Map<SyncDomain, SyncDomainStatus> _statuses = {};

  Map<SyncDomain, SyncDomainStatus> get statuses =>
      Map.unmodifiable(_statuses);

  /// Load persisted statuses from SharedPreferences.
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_storageKey);
    if (json != null) {
      _statuses = decodeDomainStatuses(json);
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, encodeDomainStatuses(_statuses));
  }

  SyncDomainStatus _getOrCreate(SyncDomain domain) {
    return _statuses[domain] ??
        SyncDomainStatus(
          domain: domain,
          staleAfter: _staleThresholds[domain] ?? const Duration(hours: 24),
        );
  }

  /// Record a successful load for [domain].
  Future<void> recordLoad(SyncDomain domain) async {
    final existing = _getOrCreate(domain);
    _statuses[domain] = existing.copyWith(lastLoadAt: DateTime.now());
    await _persist();
  }

  /// Record a successful save for [domain].
  Future<void> recordSave(SyncDomain domain) async {
    final existing = _getOrCreate(domain);
    _statuses[domain] = existing.copyWith(lastSaveAt: DateTime.now());
    await _persist();
  }

  /// Record an error for [domain].
  Future<void> recordError(SyncDomain domain, String message) async {
    final existing = _getOrCreate(domain);
    _statuses[domain] = existing.copyWith(
      lastErrorAt: DateTime.now(),
      lastErrorMessage: message,
    );
    await _persist();
  }

  /// Returns the status for a single domain, or a default if never recorded.
  SyncDomainStatus statusFor(SyncDomain domain) => _getOrCreate(domain);

  /// Number of domains that are currently unhealthy.
  int get unhealthyCount =>
      SyncDomain.values.where((d) => !_getOrCreate(d).isHealthy).length;

  /// Number of domains with unresolved errors.
  int get errorCount =>
      SyncDomain.values.where((d) => _getOrCreate(d).hasRecentError).length;

  /// True if any domain has a critical issue (recent error or stale).
  bool get hasCriticalIssues =>
      SyncDomain.values.any((d) {
        final s = _getOrCreate(d);
        return s.hasRecentError || s.isStale;
      });

  /// Count of alerts that would be generated (for badge display).
  int get alertBadgeCount => unhealthyCount;
}
