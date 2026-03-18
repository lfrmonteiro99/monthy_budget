import 'package:supabase_flutter/supabase_flutter.dart';
import '../exceptions/app_exceptions.dart' as app;

class AuthService {
  final _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  String? get currentUserId => _client.auth.currentUser?.id;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<void> signIn(String email, String password) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } catch (e, stack) {
      throw app.AuthException('Sign-in failed', e, stack);
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'orcamentomensal://login-callback/',
      );
    } catch (e, stack) {
      throw app.AuthException('Sign-up failed', e, stack);
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e, stack) {
      throw app.AuthException('Sign-out failed', e, stack);
    }
  }
}
