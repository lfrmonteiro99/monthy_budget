import 'package:supabase_flutter/supabase_flutter.dart';

import '../exceptions/app_exceptions.dart' as app;
import '../repositories/auth_repository.dart';

class AuthService {
  AuthRepository? _authRepository;

  AuthService({AuthRepository? authRepository})
    : _authRepository = authRepository;

  AuthRepository get _resolvedAuthRepository =>
      _authRepository ??= SupabaseAuthRepository();

  User? get currentUser => _resolvedAuthRepository.currentUser;
  String? get currentUserId => _resolvedAuthRepository.currentUserId;

  Stream<AuthState> get onAuthStateChange =>
      _resolvedAuthRepository.onAuthStateChange;

  Future<void> signIn(String email, String password) async {
    try {
      await _resolvedAuthRepository.signIn(email, password);
    } catch (e, stack) {
      throw app.AuthException('Sign-in failed', e, stack);
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _resolvedAuthRepository.signUp(email, password);
    } catch (e, stack) {
      throw app.AuthException('Sign-up failed', e, stack);
    }
  }

  Future<void> signOut() async {
    try {
      await _resolvedAuthRepository.signOut();
    } catch (e, stack) {
      throw app.AuthException('Sign-out failed', e, stack);
    }
  }
}
