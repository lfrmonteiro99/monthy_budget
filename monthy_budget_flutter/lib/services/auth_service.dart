import 'package:supabase_flutter/supabase_flutter.dart';

import '../exceptions/app_exceptions.dart' as app;
import '../repositories/auth_repository.dart';

class AuthService {
  final AuthRepository _authRepository;

  AuthService({AuthRepository? authRepository})
    : _authRepository = authRepository ?? SupabaseAuthRepository();

  User? get currentUser => _authRepository.currentUser;
  String? get currentUserId => _authRepository.currentUserId;

  Stream<AuthState> get onAuthStateChange => _authRepository.onAuthStateChange;

  Future<void> signIn(String email, String password) async {
    try {
      await _authRepository.signIn(email, password);
    } catch (e, stack) {
      throw app.AuthException('Sign-in failed', e, stack);
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _authRepository.signUp(email, password);
    } catch (e, stack) {
      throw app.AuthException('Sign-up failed', e, stack);
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (e, stack) {
      throw app.AuthException('Sign-out failed', e, stack);
    }
  }
}
