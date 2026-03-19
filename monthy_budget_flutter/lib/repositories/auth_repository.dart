import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  User? get currentUser;
  String? get currentUserId;
  String? get currentSessionAccessToken;
  Stream<AuthState> get onAuthStateChange;

  Future<void> signIn(String email, String password);
  Future<void> signUp(String email, String password);
  Future<void> signOut();
}

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _client;

  SupabaseAuthRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  String? get currentSessionAccessToken => _client.auth.currentSession?.accessToken;

  @override
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  @override
  Future<void> signIn(String email, String password) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signUp(String email, String password) {
    return _client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: 'orcamentomensal://login-callback/',
    );
  }

  @override
  Future<void> signOut() {
    return _client.auth.signOut();
  }
}
