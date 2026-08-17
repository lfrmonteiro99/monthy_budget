/// Compile-time switch for the automated QA pipeline (`--dart-define=QA_MODE=true`).
///
/// Because this is a `const` read of `bool.fromEnvironment`, every `if (kQaMode)`
/// branch is a compile-time constant condition: in a normal build the QA
/// repositories, seed data and auth bypass are tree-shaken out entirely and
/// production behaviour is untouched.
const bool kQaMode = bool.fromEnvironment('QA_MODE', defaultValue: false);

/// Stable household id the QA seed writes every document under.
///
/// Fixed (not generated) so screenshots and assertions stay reproducible
/// across pipeline runs.
const String kQaHouseholdId = 'qa-household-0001';

/// Stable auth identity used wherever production reads the Supabase user.
const String kQaUserId = 'qa-user-0001';
const String kQaUserEmail = 'qa.tester@example.com';
