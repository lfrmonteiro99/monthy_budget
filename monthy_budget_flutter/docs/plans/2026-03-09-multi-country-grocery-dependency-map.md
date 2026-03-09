# Multi-Country Grocery Dependency Map

**Date:** 2026-03-09
**Issue:** #217

## Goal

Provide an execution map for the multi-country grocery work so implementation can proceed in dependency order without guessing what blocks what.

## Legend

- `Blocks`: work that should wait for this issue
- `Blocked by`: work that should land first

## Core Sequence

| Order | Issue | Summary | Blocks | Blocked by |
|---|---:|---|---|---|
| 1 | #220 | Define reusable StoreScraper interface for grocery sources | #221, #222, #223, #236 | - |
| 2 | #221 | Implement PT scraper adapter for Continente | #223, #224 | #220 |
| 3 | #222 | Implement PT scraper adapters for Pingo Doce and Auchan | #223, #224 | #220 |
| 4 | #223 | Standardize PT scraper output to ScrapedListing and store status artifacts | #224, #226, #229, #236, #238 | #221, #222 |
| 5 | #224 | Add smoke tests for PT grocery scraper adapters | confidence for #226 and later refactors | #223 |
| 6 | #226 | Implement PT normalization pipeline from ScrapedListing to StoreListing | #227, #228, #230, #239 | #223 |
| 7 | #227 | Implement PT canonical product matching pipeline | #228, #230 | #226 |
| 8 | #229 | Generate PT freshness and store status summaries | #228, #232, #233 | #223 |
| 9 | #230 | Add duplicate and unmatched product reporting for PT bundle builds | #228, #239 | #226, #227 |
| 10 | #228 | Build PT country bundle artifacts from normalized store outputs | #231, #232, #237, #239 | #226, #227, #229, #230 |
| 11 | #231 | Refactor grocery asset loader to accept countryCode | #232, #233, #234, #235 | #228 |
| 12 | #232 | Add store summary consumption to grocery app models | #233 | #228, #231, #229 |
| 13 | #234 | Bind grocery country loading to user country settings | production-ready app switching | #231 |
| 14 | #233 | Handle stale and partial grocery stores gracefully in the app | robust multi-country UX | #232, #229 |
| 15 | #235 | Preserve PT grocery UX during country-aware loader migration | release confidence for loader migration | #231, #232, #234 |
| 16 | #236 | Create reusable grocery scrape workflow for country/store jobs | #237, #238, #240 | #220, #223 |
| 17 | #237 | Create matrix-driven grocery prices entry workflow | full PT workflow migration | #236 |
| 18 | #238 | Upload raw, normalized, and status grocery artifacts per store | #239, diagnostics, bundle inspection | #223, #236 |
| 19 | #239 | Add per-store and per-country grocery bundle validation steps | safer rollout and CI confidence | #226, #228, #230, #236, #238 |
| 20 | #240 | Add failure-tolerant reporting for grocery scrape matrix runs | resilient multi-store operations | #236 |

## Practical Implementation Batches

### Batch A: Scraper Contract

Ship together if possible:

- #220
- #221
- #222
- #223
- #224

### Batch B: PT Normalization and Bundle Quality

Ship after Batch A:

- #226
- #227
- #229
- #230
- #228

### Batch C: App Loader Refactor

Ship after PT bundle exists:

- #231
- #232
- #234
- #233
- #235

### Batch D: Workflow Refactor

Can begin once the PT artifact shape is stable enough:

- #236
- #237
- #238
- #239
- #240

## Fastest Safe Path

If the goal is fastest progress with least rework, the order should be:

1. #220
2. #221
3. #222
4. #223
5. #224
6. #226
7. #227
8. #229
9. #230
10. #228
11. #231
12. #232
13. #234
14. #233
15. #235
16. #236
17. #238
18. #239
19. #237
20. #240

Why this ordering:

- workflow refactor should not happen before the output contract is stable
- app loader should not migrate before PT country bundles exist
- diagnostics are more valuable before wider workflow rollout

## Parallelism Opportunities

Safe parallel work:

- #221 and #222 can run in parallel after #220
- #229 can run in parallel with #227 once #223 is done
- #236 can begin after #223 even while #226/#227 are progressing, but it should not be finalized until bundle outputs stabilize

Avoid parallelizing:

- #231 before #228
- #237 before #236
- #233 before #232

## Bottom Line

The main dependency backbone is:

- scraper contract
- standardized PT output
- PT normalization
- PT canonical matching
- PT country bundle
- app loader migration
- workflow matrix rollout

That is the sequence least likely to create rework.
