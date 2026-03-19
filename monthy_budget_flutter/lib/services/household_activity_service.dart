import '../models/household_activity_event.dart';
import '../repositories/auth_repository.dart';
import '../repositories/household_repository.dart';

class HouseholdActivityService {
  AuthRepository? _authRepository;
  HouseholdActivityRepository? _repository;

  HouseholdActivityService({
    AuthRepository? authRepository,
    HouseholdActivityRepository? repository,
  }) : _authRepository = authRepository,
       _repository = repository;

  AuthRepository get _resolvedAuthRepository =>
      _authRepository ??= SupabaseAuthRepository();

  HouseholdActivityRepository get _resolvedRepository =>
      _repository ??= SupabaseHouseholdActivityRepository();

  Future<void> append({
    required String householdId,
    required ActivityDomain domain,
    required ActivityAction action,
    required String subjectId,
    required String subjectLabel,
    Map<String, dynamic> metadata = const {},
  }) async {
    final user = _resolvedAuthRepository.currentUser;
    if (user == null) return;

    final displayName =
        user.userMetadata?['display_name'] as String? ??
        user.email ??
        'Unknown';

    await _resolvedRepository.append(
      householdId: householdId,
      actorUserId: user.id,
      actorDisplayName: displayName,
      domain: domain,
      action: action,
      subjectId: subjectId,
      subjectLabel: subjectLabel,
      metadata: metadata,
    );
  }

  Future<List<HouseholdActivityEvent>> getRecent(
    String householdId, {
    int limit = 50,
  }) {
    return _resolvedRepository.getRecent(householdId, limit: limit);
  }

  Future<List<HouseholdActivityEvent>> getByDomain(
    String householdId,
    ActivityDomain domain, {
    int limit = 50,
  }) {
    return _resolvedRepository.getByDomain(householdId, domain, limit: limit);
  }
}
