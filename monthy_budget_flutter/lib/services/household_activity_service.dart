import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/household_activity_event.dart';

class HouseholdActivityService {
  SupabaseClient get _client => Supabase.instance.client;

  /// Appends a new activity event for the current user.
  Future<void> append({
    required String householdId,
    required ActivityDomain domain,
    required ActivityAction action,
    required String subjectId,
    required String subjectLabel,
    Map<String, dynamic> metadata = const {},
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final displayName =
        user.userMetadata?['display_name'] as String? ??
        user.email ??
        'Unknown';

    await _client.from('household_activity_events').insert({
      'household_id': householdId,
      'actor_user_id': user.id,
      'actor_display_name': displayName,
      'domain': domain.name,
      'action': action.name,
      'subject_id': subjectId,
      'subject_label': subjectLabel,
      'metadata': metadata,
    });
  }

  /// Queries recent activity events for a household.
  /// Returns up to [limit] events, ordered newest first.
  Future<List<HouseholdActivityEvent>> getRecent(
    String householdId, {
    int limit = 50,
  }) async {
    final rows = await _client
        .from('household_activity_events')
        .select()
        .eq('household_id', householdId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (rows as List<dynamic>)
        .map((r) =>
            HouseholdActivityEvent.fromSupabase(r as Map<String, dynamic>))
        .toList();
  }

  /// Queries recent activity events filtered by domain.
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
        .map((r) =>
            HouseholdActivityEvent.fromSupabase(r as Map<String, dynamic>))
        .toList();
  }
}
