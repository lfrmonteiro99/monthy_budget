# Changelog

All notable changes to this project will be documented in this file.

## v2026.3.5 - 2026-03-06



### Bug Fixes

- Align release build with Supabase dart-defines (#77) (#85) ([object], [object], [object], [object])


### Other Changes

- Claude/new-session-HsuIN (#79)

* fix: show user-friendly auth error messages instead of raw exceptions

Map Supabase auth exceptions (network errors, invalid credentials,
unconfirmed email, rate limits) to localized user-facing messages
in EN, PT, ES, and FR.

https://claude.ai/code/session_01B5gGgK1EpvMvLPgMR1Qt2o

* fix: fail CI build when Supabase secrets are missing

Instead of silently falling back to placeholder values when
SUPABASE_URL or SUPABASE_ANON_KEY secrets are not configured,
the build job now fails immediately with a clear error message.
This prevents releasing APKs with broken Supabase configuration.

https://claude.ai/code/session_01B5gGgK1EpvMvLPgMR1Qt2o

* fix: restore authError getters dropped during merge

The merge from origin/main overwrote the generated l10n files,
dropping 5 authError* getters that were added on this branch.
Re-added them to all locale files.

https://claude.ai/code/session_01B5gGgK1EpvMvLPgMR1Qt2o

---------

Co-authored-by: lfrmonteiro99 <lfrmonteiro99@gmail.com>
Co-authored-by: Claude <noreply@anthropic.com> ([object])

