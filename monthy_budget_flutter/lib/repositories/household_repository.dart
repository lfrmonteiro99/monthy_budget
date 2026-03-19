import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/coach_insight.dart';
import '../models/household_activity_event.dart';

abstract class HouseholdRepository {
  Future<Map<String, dynamic>?> getProfileRow(String userId);
  Future<List<Map<String, dynamic>>> getAssociatedMemberRows(String householdId);
  Future<Map<String, dynamic>> createHousehold(String name);
  Future<Map<String, dynamic>> joinHousehold(String inviteCode);
  Future<void> saveInviteCode({
    required String householdId,
    required String code,
    required String createdBy,
    required DateTime expiresAt,
  });
}

class SupabaseHouseholdRepository implements HouseholdRepository {
  final SupabaseClient _client;

  SupabaseHouseholdRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Future<Map<String, dynamic>?> getProfileRow(String userId) async {
    final row = await _client
        .from('profiles')
        .select('household_id, role, households(name)')
        .eq('id', userId)
        .maybeSingle();
    return row;
  }

  @override
  Future<List<Map<String, dynamic>>> getAssociatedMemberRows(String householdId) async {
    final rows = await _client
        .from('profiles')
        .select('id, email, role')
        .eq('household_id', householdId)
        .order('created_at', ascending: true);
    return (rows as List<dynamic>).cast<Map<String, dynamic>>();
  }

  @override
  Future<Map<String, dynamic>> createHousehold(String name) async {
    final result = await _client.rpc('create_household', params: {'p_name': name});
    return result as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> joinHousehold(String inviteCode) async {
    final result = await _client.rpc(
      'join_household',
      params: {'p_code': inviteCode.trim().toUpperCase()},
    );
    return result as Map<String, dynamic>;
  }

  @override
  Future<void> saveInviteCode({
    required String householdId,
    required String code,
    required String createdBy,
    required DateTime expiresAt,
  }) {
    return _client.from('household_invites').insert({
      'household_id': householdId,
      'code': code,
      'created_by': createdBy,
      'expires_at': expiresAt.toIso8601String(),
    });
  }
}

abstract class HouseholdActivityRepository {
  Future<void> append({
    required String householdId,
    required String actorUserId,
    required String actorDisplayName,
    required ActivityDomain domain,
    required ActivityAction action,
    required String subjectId,
    required String subjectLabel,
    Map<String, dynamic> metadata,
  });
  Future<List<HouseholdActivityEvent>> getRecent(String householdId, {int limit = 50});
  Future<List<HouseholdActivityEvent>> getByDomain(
    String householdId,
    ActivityDomain domain, {
    int limit = 50,
  });
}

class SupabaseHouseholdActivityRepository implements HouseholdActivityRepository {
  final SupabaseClient _client;

  SupabaseHouseholdActivityRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

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
    return _client.from('household_activity_events').insert({
      'household_id': householdId,
      'actor_user_id': actorUserId,
      'actor_display_name': actorDisplayName,
      'domain': domain.name,
      'action': action.name,
      'subject_id': subjectId,
      'subject_label': subjectLabel,
      'metadata': metadata,
    });
  }

  @override
  Future<List<HouseholdActivityEvent>> getRecent(String householdId, {int limit = 50}) async {
    final rows = await _client
        .from('household_activity_events')
        .select()
        .eq('household_id', householdId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (rows as List<dynamic>)
        .map((row) => HouseholdActivityEvent.fromSupabase(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<HouseholdActivityEvent>> getByDomain(
    String householdId,
    ActivityDomain domain, {
    int limit = 50,
  }) async {
    final rows = await _client
        .from('household_activity_events')
        .select()
        .eq('household_id', householdId)
        .eq('domain', domain.name)
        .order('created_at', ascending: false)
        .limit(limit);

    return (rows as List<dynamic>)
        .map((row) => HouseholdActivityEvent.fromSupabase(row as Map<String, dynamic>))
        .toList();
  }
}

abstract class CoachInsightRepository {
  Future<List<CoachInsight>> loadInsights(String householdId, {int limit = 20});
  Future<List<CoachInsight>> saveInsight(CoachInsight insight, String householdId);
  Future<List<CoachInsight>> deleteInsight(String id, String householdId);
  Future<void> clearInsights(String householdId);
}

class SupabaseCoachInsightRepository implements CoachInsightRepository {
  final SupabaseClient _client;

  SupabaseCoachInsightRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  Future<List<CoachInsight>> loadInsights(String householdId, {int limit = 20}) async {
    final rows = await _client
        .from('household_coach_insights')
        .select()
        .eq('household_id', householdId)
        .order('created_at', ascending: false)
        .limit(limit);
    return (rows as List<dynamic>).map((row) {
      final map = row as Map<String, dynamic>;
      return CoachInsight(
        id: map['id'] as String,
        timestamp: DateTime.parse(map['created_at'] as String),
        content: map['content'] as String,
        stressScore: (map['stress_score'] as num).toInt(),
      );
    }).toList();
  }

  @override
  Future<List<CoachInsight>> saveInsight(CoachInsight insight, String householdId) async {
    await _client.from('household_coach_insights').insert({
      'id': insight.id,
      'household_id': householdId,
      'created_at': insight.timestamp.toIso8601String(),
      'content': insight.content,
      'stress_score': insight.stressScore,
    });
    return loadInsights(householdId);
  }

  @override
  Future<List<CoachInsight>> deleteInsight(String id, String householdId) async {
    await _client.from('household_coach_insights').delete().eq('id', id);
    return loadInsights(householdId);
  }

  @override
  Future<void> clearInsights(String householdId) {
    return _client.from('household_coach_insights').delete().eq('household_id', householdId);
  }
}
