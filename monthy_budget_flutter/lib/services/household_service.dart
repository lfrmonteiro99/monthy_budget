import 'dart:math';

import '../exceptions/app_exceptions.dart';
import '../repositories/auth_repository.dart';
import '../repositories/household_repository.dart';
import 'log_service.dart';

class HouseholdProfile {
  final String householdId;
  final String householdName;
  final String role;

  const HouseholdProfile({
    required this.householdId,
    required this.householdName,
    required this.role,
  });
}

class AssociatedHouseholdMember {
  final String id;
  final String email;
  final String role;

  const AssociatedHouseholdMember({
    required this.id,
    required this.email,
    required this.role,
  });
}

class HouseholdService {
  AuthRepository? _authRepository;
  HouseholdRepository? _repository;

  HouseholdService({
    AuthRepository? authRepository,
    HouseholdRepository? repository,
  }) : _authRepository = authRepository,
       _repository = repository;

  AuthRepository get _resolvedAuthRepository =>
      _authRepository ??= SupabaseAuthRepository();

  HouseholdRepository get _resolvedRepository =>
      _repository ??= SupabaseHouseholdRepository();

  Future<HouseholdProfile?> getProfile() async {
    try {
      final userId = _resolvedAuthRepository.currentUserId;
      if (userId == null) return null;

      final row = await _resolvedRepository.getProfileRow(userId);
      if (row == null || row['household_id'] == null) return null;

      return HouseholdProfile(
        householdId: row['household_id'] as String,
        householdName: (row['households'] as Map<String, dynamic>)['name'] as String,
        role: row['role'] as String,
      );
    } catch (e, stack) {
      if (e is DataException) rethrow;
      LogService.error(
        'Failed to get household profile',
        error: e,
        stackTrace: stack,
        category: 'service.household',
      );
      throw DataException('Failed to get household profile', e, stack);
    }
  }

  Future<List<AssociatedHouseholdMember>> getAssociatedMembers(
    String householdId,
  ) async {
    try {
      final rows = await _resolvedRepository.getAssociatedMemberRows(householdId);
      return rows
          .map(
            (row) => AssociatedHouseholdMember(
              id: row['id'] as String,
              email: (row['email'] as String?)?.trim().isNotEmpty == true
                  ? row['email'] as String
                  : '-',
              role: (row['role'] as String?) ?? 'member',
            ),
          )
          .toList();
    } catch (e, stack) {
      if (e is DataException) rethrow;
      LogService.error(
        'Failed to get associated members for $householdId',
        error: e,
        stackTrace: stack,
        category: 'service.household',
      );
      throw DataException(
          'Failed to get associated members for $householdId', e, stack);
    }
  }

  Future<HouseholdProfile> createHousehold(String name) async {
    try {
      final result = await _resolvedRepository.createHousehold(name);
      return HouseholdProfile(
        householdId: result['household_id'] as String,
        householdName: result['name'] as String,
        role: result['role'] as String,
      );
    } catch (e, stack) {
      if (e is DataException) rethrow;
      LogService.error(
        'Failed to create household',
        error: e,
        stackTrace: stack,
        category: 'service.household',
      );
      throw DataException('Failed to create household', e, stack);
    }
  }

  Future<HouseholdProfile> joinHousehold(String inviteCode) async {
    try {
      final result = await _resolvedRepository.joinHousehold(inviteCode);
      return HouseholdProfile(
        householdId: result['household_id'] as String,
        householdName: result['name'] as String,
        role: result['role'] as String,
      );
    } catch (e, stack) {
      if (e is DataException) rethrow;
      LogService.error(
        'Failed to join household',
        error: e,
        stackTrace: stack,
        category: 'service.household',
      );
      throw DataException('Failed to join household', e, stack);
    }
  }

  Future<String> generateInviteCode(String householdId) async {
    final userId = _resolvedAuthRepository.currentUserId;
    if (userId == null) {
      throw StateError('Cannot generate invite code without an authenticated user.');
    }
    try {
      final code = _randomCode();
      final expiresAt = DateTime.now().add(const Duration(days: 7));
      await _resolvedRepository.saveInviteCode(
        householdId: householdId,
        code: code,
        createdBy: userId,
        expiresAt: expiresAt,
      );
      return code;
    } catch (e, stack) {
      if (e is DataException) rethrow;
      LogService.error(
        'Failed to generate invite code for $householdId',
        error: e,
        stackTrace: stack,
        category: 'service.household',
      );
      throw DataException(
          'Failed to generate invite code for $householdId', e, stack);
    }
  }

  String _randomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    final buffer = StringBuffer();
    for (int i = 0; i < 6; i++) {
      buffer.write(chars[rng.nextInt(chars.length)]);
    }
    return buffer.toString();
  }
}
