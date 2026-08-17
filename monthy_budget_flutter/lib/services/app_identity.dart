import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/qa_mode.dart';
import '../repositories/repository_factory.dart';

/// Single seam for the handful of UI call sites that read the signed-in user
/// directly from Supabase rather than through a repository.
///
/// In QA mode there is no Supabase session, so these would all return `null`
/// (or throw, since `Supabase.instance` asserts when uninitialised). Each getter
/// therefore branches on the compile-time [kQaMode] constant: production keeps
/// the exact expression it had before — including its throw-on-uninitialised
/// behaviour, which the existing call-site `try/catch`es rely on — and the QA
/// branch is tree-shaken out of a normal build.
class AppIdentity {
  AppIdentity._();

  static User? get currentUser => kQaMode
      ? RepositoryFactory.instance.auth.currentUser
      : Supabase.instance.client.auth.currentUser;

  static String? get currentUserId => kQaMode
      ? RepositoryFactory.instance.auth.currentUserId
      : Supabase.instance.client.auth.currentUser?.id;

  static String? get currentUserEmail => kQaMode
      ? RepositoryFactory.instance.auth.currentUser?.email
      : Supabase.instance.client.auth.currentUser?.email;

  static Future<void> signOut() => kQaMode
      ? RepositoryFactory.instance.auth.signOut()
      : Supabase.instance.client.auth.signOut();
}
