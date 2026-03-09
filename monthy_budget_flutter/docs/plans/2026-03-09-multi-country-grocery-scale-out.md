# Multi-Country Grocery Scale-Out Preparation

Date: 2026-03-09
Issue: #346

## Scope
This document closes the planning work for:
- #269 Review currency assumptions for multi-country grocery pricing
- #270 Add category mapping extension points for future grocery markets
- #271 Assess runtime and cost scaling for grocery workflow matrix expansion
- #272 Decide long-term storage strategy for generated grocery artifacts

## Current Baseline
The grocery pipeline now assumes a per-country layout and per-store scrape jobs. PT is the reference market. ES is the next rollout target. The current architecture already separates:
- store scrapers
- normalization
- matching
- bundle building
- validation
- workflow execution

That separation is enough for additional markets, but only if scaling decisions are made explicitly now instead of being buried inside PT assumptions.

## 1. Currency Assumptions

### Current safe assumptions
- PT and ES use `EUR`.
- Most existing normalization, ranking, and UI code can stay simple while PT and ES are the only live markets.
- `price` and `price_per_base_unit` comparisons are valid only within the same currency.

### Required rule going forward
- Never compare prices across markets unless currency is identical and tax/display rules are known compatible.
- The country bundle must carry `currency_code` as first-class metadata.
- Every store summary must inherit the market currency, not guess it from the UI locale.

### Near-term implementation rule
- Country bundle builder remains country-local.
- Any ranking, cheapest-store logic, or comparison table is scoped to one `country_code` only.
- App services must refuse cross-country merge logic unless a future FX layer is explicitly introduced.

### Non-EUR markets
For UK or other future markets:
- treat `GBP`, `CHF`, etc. as hard boundaries
- do not convert in the scraper pipeline
- if conversion is ever introduced, do it only in analytics/reporting layers, never in canonical product matching

### Decision
- `currency_code` stays required on bundle metadata and store listing artifacts
- cross-country price comparison is out of scope for phase 1
- FX conversion is a future analytics concern, not a scraping concern

## 2. Category Mapping Extension Points

### Current problem
PT-first category naming will not scale cleanly. Stores expose different taxonomies, naming styles, and depth.

### Required model
Split category handling into three layers:
- `store_category_raw`: whatever the scraper saw
- `market_category_id`: normalized category for one country
- `global_category_family`: optional cross-market umbrella for analytics and UX grouping

### Example
- Mercadona `Lacteos y Huevos`
- Continente `Lacticinios e Ovos`
- both can map to market-level dairy/eggs buckets
- later, both can map to a global `dairy_eggs` family if needed

### Extension points to add
- per-market mapping files under `scrapers/config/<COUNTRY>.json`
- optional global family mapping file under `scrapers/config/category_families.json`
- normalization code should consume mapping tables, not hardcode category names in matcher/builder logic

### Decision
- canonical product matching must not depend on localized category display labels
- bundle outputs should expose normalized category ids, with display labels derived later
- UI can localize labels separately from the pipeline ids

## 3. Workflow Runtime and Cost Scaling

### Current state
The matrix workflow is fine for PT and manageable for ES preview runs. It will become expensive and noisy if every store in every market runs on the same cadence.

### Main scaling risks
- total GitHub Actions minutes grow linearly with stores and markets
- scraper flakiness multiplies with matrix width
- artifact download/upload overhead grows with every stage
- daily schedules create unnecessary work for low-value or unstable stores

### Required guardrails
- schedule only stable markets by default
- keep new markets behind manual dispatch or explicit includes until validated
- allow per-store opt-in, not per-country blanket enablement
- classify stores by freshness SLA:
  - daily
  - 3x weekly
  - weekly
  - manual preview only

### Practical workflow structure
- reusable per-store workflow remains the unit of execution
- parent matrix workflow should accept an include list, not infer every market automatically
- bundle aggregation should tolerate partial country completion and mark failed stores explicitly
- nightly PT can remain automatic
- ES should stay preview-only until scrape reliability and coverage are stable

### Cost control rules
- cap products per category for preview markets
- keep smoke validation lightweight
- only publish gh-pages bundles for markets that pass validation
- keep full debug/raw artifacts for short retention only

### Decision
- no global always-on matrix across all markets
- rollout order stays: PT stable -> ES preview -> ES scheduled -> next market preview
- workflow dispatch includes are the control plane for expansion

## 4. Artifact Storage Strategy

### Current short-term storage
- generated bundles published to `gh-pages`
- CI artifacts retained by Actions for inspection
- bundled fallback assets committed only when needed for app resilience

### What works well
- `gh-pages` is simple and already integrated with the app fetch path
- Actions artifacts are good for debugging transient failures

### What will break later
- large raw artifacts do not belong in git long-term
- `gh-pages` is fine for publishable bundle outputs, but not for every intermediate file forever
- manual debugging becomes painful without retention rules

### Recommended split
- publishable assets:
  - keep on `gh-pages`
  - country bundle, store summaries, normalized store outputs that the app may fetch
- transient debug artifacts:
  - keep as GitHub Actions artifacts with short retention
  - raw scrape payloads, validation dumps, unmatched reports
- durable operator data:
  - if scale grows beyond GitHub convenience, move raw/intermediate artifacts to object storage
  - examples: Cloudflare R2, Supabase Storage, S3-compatible bucket

### Decision
Short term:
- keep final country bundles on `gh-pages`
- keep CI debug artifacts in Actions with explicit retention limits

Medium term:
- move raw and intermediate artifacts to object storage when more than two live markets exist or artifact volume becomes operationally annoying

## 5. Concrete Next Steps
- Add explicit `currency_code` validation in bundle validation scripts.
- Add category mapping indirection to market config before a non-Iberian market is introduced.
- Keep ES behind preview dispatch until two conditions are met:
  - stable scraper success rate
  - acceptable unmatched/low-confidence thresholds
- Add retention and naming conventions for debug artifacts in workflow docs.
- Revisit object storage once PT+ES are both live and a third market is being prepared.

## Final Decisions
- Comparisons remain country-local.
- Currency conversion is not part of scraping or matching.
- Category ids must become config-driven instead of PT-label-driven.
- Workflow expansion must be explicit and cost-aware.
- `gh-pages` remains the published asset channel; raw/intermediate storage can graduate later.
