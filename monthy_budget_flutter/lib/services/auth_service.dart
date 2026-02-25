import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  String? get currentUserId => _client.auth.currentUser?.id;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  Future<void> signIn(String email, String password) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signUp(String email, String password) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: 'orcamentomensal://login-callback/',
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
