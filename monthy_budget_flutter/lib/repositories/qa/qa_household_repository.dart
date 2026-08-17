import '../../models/coach_insight.dart';
import '../../models/household_activity_event.dart';
import '../household_repository.dart';
import '../local/qa_local_store.dart';
import 'qa_collections.dart';

class QaHouseholdRepository implements HouseholdRepository {
  QaHouseholdRepository(
    this._store, {
    required String householdId,
    required DateTime Function() now,
  }) : _householdId = householdId,
       _now = now;

  final QaLocalStore _store;
  final String _householdId;
  final DateTime Function() _now;

  @override
  Future<Map<String, dynamic>?> getProfileRow(String userId) {
    return _store.get(QaCollections.profiles, _householdId, userId);
  }

  @override
  Future<List<Map<String, dynamic>>> getAssociatedMemberRows(
    String householdId,
  ) async {
    final rows = await _store.query(QaCollections.profiles, householdId);
    rows.sort(
      (a, b) => (a['created_at'] as String).compareTo(b['created_at'] as String),
    );
    return rows;
  }

  /// QA never creates a second household — return the seeded one so the
  /// household-setup screen still completes if a tester reaches it.
  @override
  Future<Map<String, dynamic>> createHousehold(String name) async {
    return {'household_id': _householdId, 'name': name, 'role': 'admin'};
  }

  @override
  Future<Map<String, dynamic>> joinHousehold(String inviteCode) async {
    final household = await _store.get(
      QaCollections.households,
      _householdId,
      _householdId,
    );
    return {
      'household_id': _householdId,
      'name': household?['name'] ?? 'QA Household',
      'role': 'member',
    };
  }

  @override
  Future<void> saveInviteCode({
    required String householdId,
    required String code,
    required String createdBy,
    required DateTime expiresAt,
  }) {
    return _store.put(QaCollections.householdInvites, householdId, code, {
      'household_id': householdId,
      'code': code,
      'created_by': createdBy,
      'created_at': _now().toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
    });
  }
}

class QaHouseholdActivityRepository implements HouseholdActivityRepository {
  QaHouseholdActivityRepository(this._store, {required DateTime Function() now})
    : _now = now;

  final QaLocalStore _store;
  final DateTime Function() _now;

  @override
  Future<void> append({
    required String householdId,
    required String actorUserId,
    required String actorDisplayName,
    required ActivityDomain domain,
    required ActivityAction action,
    required String subjectId,
    required String subjectLabel,
    Map<String, dynamic> metadata = const {},
  }) {
    final createdAt = _now();
    // Postgres generates id/created_at; QA has to supply both, and the id must
    // sort chronologically because the store orders by doc_id.
    final id = 'evt-${createdAt.microsecondsSinceEpoch}';
    return _store.put(QaCollections.activityEvents, householdId, id, {
      'id': id,
      'household_id': householdId,
      'actor_user_id': actorUserId,
      'actor_display_name': actorDisplayName,
      'domain': domain.name,
      'action': action.name,
      'subject_id': subjectId,
      'subject_label': subjectLabel,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    });
  }

  @override
  Future<List<HouseholdActivityEvent>> getRecent(
    String householdId, {
    int limit = 50,
  }) async {
    final events = await _load(householdId);
    return events.take(limit).toList();
  }

  @override
  Future<List<HouseholdActivityEvent>> getByDomain(
    String householdId,
    ActivityDomain domain, {
    int limit = 50,
  }) async {
    final events = await _load(householdId);
    return events.where((e) => e.domain == domain).take(limit).toList();
  }

  Future<List<HouseholdActivityEvent>> _load(String householdId) async {
    final rows = await _store.query(QaCollections.activityEvents, householdId);
    final events = rows.map(HouseholdActivityEvent.fromSupabase).toList();
    events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return events;
  }
}

class QaCoachInsightRepository implements CoachInsightRepository {
  QaCoachInsightRepository(this._store);

  final QaLocalStore _store;

  @override
  Future<List<CoachInsight>> loadInsights(
    String householdId, {
    int limit = 20,
  }) async {
    final rows = await _store.query(QaCollections.coachInsights, householdId);
    final insights = rows
        .map(
          (row) => CoachInsight(
            id: row['id'] as String,
            timestamp: DateTime.parse(row['created_at'] as String),
            content: row['content'] as String,
            stressScore: (row['stress_score'] as num).toInt(),
          ),
        )
        .toList();
    insights.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return insights.take(limit).toList();
  }

  @override
  Future<List<CoachInsight>> saveInsight(
    CoachInsight insight,
    String householdId,
  ) async {
    await _store.put(QaCollections.coachInsights, householdId, insight.id, {
      'id': insight.id,
      'household_id': householdId,
      'created_at': insight.timestamp.toIso8601String(),
      'content': insight.content,
      'stress_score': insight.stressScore,
    });
    return loadInsights(householdId);
  }

  @override
  Future<List<CoachInsight>> deleteInsight(
    String id,
    String householdId,
  ) async {
    await _store.delete(QaCollections.coachInsights, householdId, id);
    return loadInsights(householdId);
  }

  @override
  Future<void> clearInsights(String householdId) {
    return _store.clearCollection(QaCollections.coachInsights, householdId);
  }
}
