# CI / CD Pipeline & Releases

## Overview

GitHub Actions runs on every push or PR to `main` and on version tags. The main
workflow lives at `.github/workflows/flutter-ci.yml`.

| Trigger | What runs |
|---|---|
| PR to `main` | `flutter analyze` + `flutter test` |
| Push or merge to `main` | analyze + test + signed APK build -> prerelease on GitHub Releases |
| Push tag `v*` (for example `v1.2.0`) | analyze + test + signed APK build -> formal GitHub Release with generated notes |

## Runtime `--dart-define` secrets

The Flutter app reads service configuration from compile-time `--dart-define`
values. CI validates these secrets before Android release builds so a missing
RevenueCat or AdMob identifier fails the workflow early instead of producing a
broken artifact.

### Required GitHub Actions secrets

| Secret | Description |
|---|---|
| `SUPABASE_URL` | Public Supabase project URL |
| `SUPABASE_ANON_KEY` | Public Supabase anon key |
| `REVENUECAT_API_KEY` | RevenueCat SDK public API key |
| `ADMOB_APP_ID` | AdMob application ID used in the Android manifest |
| `ADMOB_BANNER_AD_UNIT_ID` | AdMob production banner ad unit ID |
| `KEYSTORE_BASE64` | Base64-encoded `.jks` keystore file |
| `KEYSTORE_PASSWORD` | Keystore store password |
| `KEY_ALIAS` | Key alias inside the keystore |
| `KEY_PASSWORD` | Key password |

### Setting secrets via GitHub CLI

```bash
echo -n 'https://your-project.supabase.co' | gh secret set SUPABASE_URL
echo -n 'your-public-anon-key' | gh secret set SUPABASE_ANON_KEY
echo -n 'your-revenuecat-sdk-key' | gh secret set REVENUECAT_API_KEY
echo -n 'ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy' | gh secret set ADMOB_APP_ID
echo -n 'ca-app-pub-xxxxxxxxxxxxxxxx/zzzzzzzzzz' | gh secret set ADMOB_BANNER_AD_UNIT_ID

base64 -w 0 my-release-key.jks | gh secret set KEYSTORE_BASE64
echo -n 'your-password' | gh secret set KEYSTORE_PASSWORD
echo -n 'upload' | gh secret set KEY_ALIAS
echo -n 'your-password' | gh secret set KEY_PASSWORD
```

### Local development

Store local values in an untracked JSON file and pass them with
`--dart-define-from-file`:

```json
{
  "SUPABASE_URL": "https://your-project.supabase.co",
  "SUPABASE_ANON_KEY": "your-public-anon-key",
  "REVENUECAT_API_KEY": "your-revenuecat-sdk-key",
  "ADMOB_APP_ID": "ca-app-pub-xxxxxxxxxxxxxxxx~yyyyyyyyyy",
  "ADMOB_BANNER_AD_UNIT_ID": "ca-app-pub-xxxxxxxxxxxxxxxx/zzzzzzzzzz"
}
```

```bash
cd monthy_budget_flutter
flutter run --dart-define-from-file=env.local.json
flutter build apk --release --dart-define-from-file=env.production.json
```

## Creating a Release

### Formal release

```bash
git tag v1.0.0
git push origin v1.0.0
```

The APK appears under GitHub Releases with generated release notes.

### Dev builds

Every push to `main` that touches `monthy_budget_flutter/` creates a prerelease
tagged `dev-<commit-sha>`. These builds are marked as prereleases and do not
become the latest release.

## APK signing

Release APKs are signed with a keystore stored as GitHub secrets. The Android
build uses `android/keystore.jks` when present and falls back to debug signing
locally when the keystore is absent.

### Rotating the keystore

1. Generate a new keystore with `keytool -genkey -v -keystore new-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`.
2. Update the four keystore-related GitHub secrets.
3. Re-run the next Android release build.

## Build artifacts

Every APK or AAB build is also uploaded as a GitHub Actions artifact and kept
for 30 days.

## Running CI locally

```bash
cd monthy_budget_flutter
flutter pub get
flutter gen-l10n
flutter analyze --no-fatal-infos
flutter test
flutter build apk --release --dart-define-from-file=env.production.json
```
