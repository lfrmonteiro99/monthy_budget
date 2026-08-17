import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth_repository.dart';

/// Stand-in identity for QA builds: a fixed, always-signed-in user.
///
/// The types are the real gotrue [User] / [Session] / [AuthState] so callers
/// that already read `user.id`, `user.email` or `user.createdAt` need no
/// changes.
class QaAuthRepository implements AuthRepository {
  QaAuthRepository({
    required String userId,
    required String email,
    required DateTime accountCreatedAt,
  }) : _user = User(
         id: userId,
         appMetadata: const {'provider': 'qa'},
         userMetadata: const {},
         aud: 'authenticated',
         email: email,
         createdAt: accountCreatedAt.toIso8601String(),
         role: 'authenticated',
         emailConfirmedAt: accountCreatedAt.toIso8601String(),
       );

  final User _user;

  late final Session _session = Session(
    accessToken: 'qa-access-token',
    tokenType: 'bearer',
    user: _user,
  );

  @override
  User? get currentUser => _user;

  @override
  String? get currentUserId => _user.id;

  @override
  String? get currentSessionAccessToken => _session.accessToken;

  /// Emits a single signed-in state and never closes, so `StreamBuilder`s that
  /// wait on auth changes settle immediately instead of hanging on a spinner.
  @override
  Stream<AuthState> get onAuthStateChange =>
      Stream<AuthState>.value(
        AuthState(AuthChangeEvent.signedIn, _session),
      ).asBroadcastStream();

  @override
  Future<void> signIn(String email, String password) async {}

  @override
  Future<void> signUp(String email, String password) async {}

  /// No-op: QA has no session to tear down, and throwing here would break the
  /// sign-out button the pipeline exercises on the settings screen.
  @override
  Future<void> signOut() async {}
}
