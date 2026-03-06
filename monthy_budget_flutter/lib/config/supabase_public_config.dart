// Public compile-time config for CI/analyze. Override with --dart-define in real builds.
const supabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://example.supabase.co',
);

const supabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'public-anon-key-placeholder',
);
