# Changelog

All notable changes to this project will be documented in this file.

## v2026.3.2 - 2026-03-05

- fix(ci): enforce validate-pr on push with PR-aware resolution (#60) (#63)
- chore(ci): trigger non-interference pipeline status run (#60) (#62)
- fix(ci): read PR metadata from event payload in governance check (#58) (#61)
- chore(ci): run end-to-end automation smoke test (#58) (#59)
- fix(ci): harden agent delivery merge flow for stale pipelines (#54) (#56)
- feat(coach): wire eco/plus/pro fallback UX (#53)
- feat(coach): add memory/credits architecture foundation (#52)
- fix(ai): enforce jwt auth for openai-chat invocations (#49)

## v2026.3.0 - 2026-03-05

### Migration
- Start CalVer-based releases from `v2026.3.0`.
- Previous tags from `v0.0.x` are retained for historical reference.
- Versioning now follows `YYYY.M.PATCH` with Play Store-compatible `versionCode`.
