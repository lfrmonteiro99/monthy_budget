# CI / CD Pipeline & Releases

## Overview

GitHub Actions runs on every push/PR to `main` and on version tags. The workflow lives at `.github/workflows/flutter-ci.yml`.

| Trigger | What runs |
|---|---|
| PR to `main` | `flutter analyze` + `flutter test` |
| Push/merge to `main` | analyze + test + signed APK build → **prerelease** on GitHub Releases |
| Push tag `v*` (e.g. `v1.2.0`) | analyze + test + signed APK build → **formal GitHub Release** with auto-generated notes |

## Creating a Release

### Formal release (recommended)

```bash
# Tag the current commit
git tag v1.0.0

# Push the tag — CI builds and publishes automatically
git push origin v1.0.0
```

The APK will appear under [GitHub Releases](https://github.com/lfrmonteiro99/monthy_budget/releases) with auto-generated release notes.

### Dev builds

Every push to `main` that touches `monthy_budget_flutter/` creates a prerelease tagged `dev-<commit-sha>`. These are marked as prereleases and won't show as "latest".

## APK Signing

Release APKs are signed with a keystore stored as GitHub secrets. The `build.gradle.kts` detects the keystore at build time:

- **CI**: keystore decoded from `KEYSTORE_BASE64` secret into `android/keystore.jks`
- **Local**: if no `keystore.jks` is found, falls back to debug signing

### Required GitHub Secrets

| Secret | Description |
|---|---|
| `KEYSTORE_BASE64` | Base64-encoded `.jks` keystore file |
| `KEYSTORE_PASSWORD` | Keystore store password |
| `KEY_ALIAS` | Key alias inside the keystore |
| `KEY_PASSWORD` | Key password |

### Setting secrets via CLI

```bash
# Encode and set keystore
base64 -w 0 my-release-key.jks | gh secret set KEYSTORE_BASE64

# Set passwords and alias
echo -n 'your-password' | gh secret set KEYSTORE_PASSWORD
echo -n 'upload' | gh secret set KEY_ALIAS
echo -n 'your-password' | gh secret set KEY_PASSWORD
```

### Rotating the keystore

1. Generate a new keystore: `keytool -genkey -v -keystore new-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. Update the 4 GitHub secrets with the new values
3. No code changes needed

## Build Artifacts

Every APK build is also uploaded as a GitHub Actions artifact (retained 30 days). Download from the Actions tab even if the release is deleted.

## Running CI Locally

```bash
cd monthy_budget_flutter
flutter pub get
flutter gen-l10n
flutter analyze --no-fatal-infos
flutter test
flutter build apk --release   # requires keystore setup
```
