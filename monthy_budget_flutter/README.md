# Monthy Budget Flutter

Flutter client for the Monthy Budget application.

## Local setup

```bash
flutter pub get
flutter gen-l10n
flutter analyze --no-fatal-infos
flutter test
```

## Runtime secrets

Release builds read service configuration from compile-time `--dart-define`
values instead of hardcoded source constants.

Required keys:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `REVENUECAT_API_KEY`
- `ADMOB_APP_ID`
- `ADMOB_BANNER_AD_UNIT_ID`

Tests and analysis can run without these values because the app uses safe
placeholders or empty defaults outside production release builds. Android
release builds should fail fast if any of the monetization or signing secrets
are missing in CI.

### Recommended local workflow

Create an untracked JSON file such as `env.local.json`:

```json
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_ANON_KEY": "your-public-anon-key",
  "REVENUECAT_API_KEY": "your-revenuecat-sdk-key",
  "ADMOB_APP_ID": "ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy",
  "ADMOB_BANNER_AD_UNIT_ID": "ca-app-pub-xxxxxxxxxxxxxxxx/zzzzzzzzzz"
}
```

Run the app with that file:

```bash
flutter run --dart-define-from-file=env.local.json
```

Build a release artifact with the same approach:

```bash
flutter build apk --release --dart-define-from-file=env.production.json
```

Do not commit `env.local.json`, `env.production.json`, or any other secret
material. The repository CI expects the same values to be stored as GitHub
Actions secrets.

## Release pipeline

CI/CD details, required GitHub secrets, and release notes workflow live in
`docs/ci-releases.md`.
