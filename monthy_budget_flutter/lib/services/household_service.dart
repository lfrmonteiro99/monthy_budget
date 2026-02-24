import 'package:supabase_flutter/supabase_flutter.dart';

class HouseholdProfile {
  final String householdId;
  final String householdName;
  final String role; // 'admin' | 'member'

  const HouseholdProfile({
    required this.householdId,
    required this.householdName,
    required this.role,
  });
}

class HouseholdService {
  final _client = Supabase.instance.client;

  /// Returns null if the current user has no household yet.
  Future<HouseholdProfile?> getProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final row = await _client
        .from('profiles')
        .select('household_id, role, households(name)')
        .eq('id', userId)
        .maybeSingle();

    if (row == null || row['household_id'] == null) return null;

    return HouseholdProfile(
      householdId: row['household_id'] as String,
      householdName:
          (row['households'] as Map<String, dynamic>)['name'] as String,
      role: row['role'] as String,
    );
  }

  /// Creates a new household; assigns current user as admin.
  Future<HouseholdProfile> createHousehold(String name) async {
    final result = await _client.rpc(
      'create_household',
      params: {'p_name': name},
    ) as Map<String, dynamic>;

    return HouseholdProfile(
      householdId: result['household_id'] as String,
      householdName: result['name'] as String,
      role: result['role'] as String,
    );
  }

  /// Joins an existing household via 6-char invite code.
  Future<HouseholdProfile> joinHousehold(String inviteCode) async {
    final userId = _client.auth.currentUser!.id;

    final invite = await _client
        .from('household_invites')
        .select('household_id, households(name)')
        .eq('code', inviteCode.trim().toUpperCase())
        .gte('expires_at', DateTime.now().toIso8601String())
        .maybeSingle();

    if (invite == null) throw Exception('Código inválido ou expirado.');

    final householdId = invite['household_id'] as String;
    final householdName =
        (invite['households'] as Map<String, dynamic>)['name'] as String;

    await _client.from('profiles').update({
      'household_id': householdId,
      'role': 'admin',
    }).eq('id', userId);

    return HouseholdProfile(
        householdId: householdId, householdName: householdName, role: 'admin');
  }

  /// Admin only: generates and persists a 6-char invite code.
  Future<String> generateInviteCode(String householdId) async {
    final userId = _client.auth.currentUser!.id;
    final code = _randomCode();
    final expiresAt = DateTime.now().add(const Duration(days: 7));
    await _client.from('household_invites').insert({
      'household_id': householdId,
      'code': code,
      'created_by': userId,
      'expires_at': expiresAt.toIso8601String(),
    });
    return code;
  }

  String _randomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    var r = DateTime.now().microsecondsSinceEpoch;
    final buf = StringBuffer();
    for (int i = 0; i < 6; i++) {
      buf.write(chars[r % chars.length]);
      r = (r * 1664525 + 1013904223) & 0x7fffffff;
    }
    return buf.toString();
  }
}
