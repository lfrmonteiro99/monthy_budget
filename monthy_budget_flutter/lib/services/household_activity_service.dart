import '../models/household_activity_event.dart';
import '../repositories/auth_repository.dart';
import '../repositories/household_repository.dart';

class HouseholdActivityService {
  final AuthRepository _authRepository;
  final HouseholdActivityRepository _repository;

  HouseholdActivityService({
    AuthRepository? authRepository,
    HouseholdActivityRepository? repository,
  }) : _authRepository = authRepository ?? SupabaseAuthRepository(),
       _repository = repository ?? SupabaseHouseholdActivityRepository();

  Future<void> append({
    required String householdId,
    required ActivityDomain domain,
    required ActivityAction action,
    required String subjectId,
    required String subjectLabel,
    Map<String, dynamic> metadata = const {},
  }) async {
    final user = _authRepository.currentUser;
    if (user == null) return;

    final displayName =
        user.userMetadata?['display_name'] as String? ??
        user.email ??
        'Unknown';

    await _repository.append(
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
    return _repository.getRecent(householdId, limit: limit);
  }

  Future<List<HouseholdActivityEvent>> getByDomain(
    String householdId,
    ActivityDomain domain, {
    int limit = 50,
  }) {
    return _repository.getByDomain(householdId, domain, limit: limit);
  }
}
