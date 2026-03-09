# Multi-Country Grocery Pricing Backlog

**Date:** 2026-03-09
**Issue:** #217

## Goal

Translate the multi-country grocery pricing design into a practical implementation backlog with delivery phases, task breakdown, dependencies, and acceptance checkpoints.

## Delivery Principles

- Refactor Portugal first.
- Ship architecture before geography expansion.
- Keep Spain as the first non-PT market.
- Prefer small, validated milestones over one large migration.

## Milestone 0: Baseline Audit and Safety Rails

### Objective

Understand the current PT pipeline end-to-end and add guardrails before refactoring.

### Tasks

1. Inventory current grocery scraping sources and scripts.
2. Inventory current app data loading assumptions for grocery pricing.
3. Identify all code paths that assume a single flat grocery dataset.
4. Add a small validation script for current PT output sanity checks.
5. Document current refresh cadence and failure modes.

### Deliverables

- current-state audit note
- PT output validation checklist
- known coupling list between app and PT dataset

### Acceptance Criteria

- team can describe the existing PT pipeline from scrape to app
- single-country assumptions are explicitly listed

## Milestone 1: Market Configuration Layer

### Objective

Introduce country/store configuration as first-class data.

### Tasks

1. Add `MarketConfig` and `StoreConfig` schema definitions.
2. Create a config file for PT markets/stores.
3. Add a config loader used by scraping/build scripts.
4. Replace hardcoded PT store assumptions with config-based store discovery.
5. Add validation for duplicate `storeId` and invalid `countryCode`.

### Deliverables

- market config file(s)
- config loader
- validation script

### Dependencies

- none

### Acceptance Criteria

- all current PT stores are described by configuration, not hardcoded branches
- scripts can receive `country/store` and resolve metadata from config

## Milestone 2: Canonical Product and Store Listing Models

### Objective

Separate canonical product identity from raw scraped listings.

### Tasks

1. Define `CanonicalProduct`, `StoreListing`, `ScrapedListing`, and `StoreDatasetStatus` models.
2. Create serializers/deserializers for build artifacts.
3. Implement normalized unit-price helpers.
4. Define country-scoped canonical ID strategy.
5. Add validation rules for required fields and uniqueness.

### Deliverables

- schema implementation in code
- normalization helpers
- validation script/tests

### Dependencies

- Milestone 1

### Acceptance Criteria

- raw scraped data no longer acts as app-facing product identity
- store listing outputs can be validated independently from canonical products

## Milestone 3: PT Scraper Adapter Refactor

### Objective

Refactor Portugal scraping into per-store adapters behind a common interface.

### Tasks

1. Define a `StoreScraper` interface.
2. Implement PT adapters:
   - Continente
   - Pingo Doce
   - Auchan
3. Standardize adapter output to `ScrapedListing`.
4. Ensure each adapter emits status metadata even on partial failure.
5. Add per-adapter smoke tests.

### Deliverables

- scraper interface
- PT store adapters
- status artifact generation

### Dependencies

- Milestone 2

### Acceptance Criteria

- each PT store runs independently
- one store failure does not break the others conceptually
- adapters emit the same normalized intermediate shape

## Milestone 4: PT Normalization and Country Bundle Builder

### Objective

Build country-specific PT bundles from store outputs.

### Tasks

1. Implement normalization step from `ScrapedListing` to `StoreListing`.
2. Implement canonical match pipeline for PT.
3. Generate PT `catalog.json` and per-store outputs.
4. Generate PT freshness/status summaries.
5. Add duplicate and unmatched-product reporting.

### Deliverables

- PT country bundle builder
- PT status metadata
- PT validation report

### Dependencies

- Milestone 3

### Acceptance Criteria

- PT app-facing bundle is generated from country/store artifacts
- PT bundle contains canonical products plus store listings
- freshness data is available per store

## Milestone 5: App Loader Refactor

### Objective

Make the app consume country-aware grocery bundles.

### Tasks

1. Refactor grocery asset loader to accept `countryCode`.
2. Add store summary consumption in the app model.
3. Add graceful handling for stale/partial stores.
4. Bind grocery loading to selected user country.
5. Preserve current PT UX while switching to country-aware assets.

### Deliverables

- updated grocery loader/service
- country-aware app asset paths
- UI fallback for stale stores

### Dependencies

- Milestone 4

### Acceptance Criteria

- PT users still see correct data
- app no longer assumes one flat grocery dataset
- stale stores can be surfaced without breaking grocery browsing

## Milestone 6: Reusable GitHub Actions Workflow

### Objective

Replace the PT-only workflow with a reusable country/store matrix pipeline.

### Tasks

1. Create reusable scraping workflow.
2. Create main entrypoint workflow with explicit matrix include.
3. Add artifact upload for raw, normalized, and status outputs.
4. Add validation steps per store and per country bundle.
5. Add failure-tolerant reporting (`fail-fast: false`).

### Deliverables

- reusable workflow
- matrix entry workflow
- artifact layout
- validation steps

### Dependencies

- Milestone 4

### Acceptance Criteria

- PT can run through the new reusable workflow path
- workflows can address stores individually by matrix entry

## Milestone 7: Spain Initial Rollout

### Objective

Add Spain as the second supported market.

### Tasks

1. Add ES market config.
2. Implement first ES adapters:
   - Mercadona
   - Carrefour ES
   - optionally DIA
3. Build ES canonical matching and country bundle.
4. Validate ES unit and naming normalization.
5. Add ES to workflow matrix behind explicit includes.

### Deliverables

- ES market config
- ES adapters
- ES app-facing bundle

### Dependencies

- Milestone 6

### Acceptance Criteria

- ES artifacts are built independently from PT
- app can load ES grocery data based on selected country

## Milestone 8: Freshness and Quality UI

### Objective

Expose store quality and freshness in the app so users can trust what they see.

### Tasks

1. Add freshness metadata to grocery service models.
2. Add store freshness/status chips or summary row in grocery UI.
3. Add stale-store fallback text.
4. Optionally let users filter out stale stores.

### Deliverables

- freshness-aware grocery UI
- store status display

### Dependencies

- Milestone 5
- Milestone 7 for non-PT usage, though PT can ship first

### Acceptance Criteria

- users can see when store data is stale or partial
- app does not present all stores as equally fresh by default

## Milestone 9: Matching Quality and Review Tooling

### Objective

Reduce duplicate products and poor canonical matches over time.

### Tasks

1. Add `match_method` and `match_confidence` diagnostics.
2. Produce unmatched product reports by store.
3. Add review thresholds for fuzzy matches.
4. Add manual override mapping file or table.

### Deliverables

- matching diagnostics artifacts
- override mechanism

### Dependencies

- Milestone 4

### Acceptance Criteria

- low-confidence matches are measurable
- manual overrides can improve bundle quality without scraper changes

## Milestone 10: Scale-Out Preparation

### Objective

Prepare for additional countries after PT and ES are stable.

### Tasks

1. Review currency assumptions.
2. Add category mapping extension points.
3. Review runtime/cost of matrix scaling.
4. Decide whether generated artifacts should remain in repo or move to storage.

### Deliverables

- scale-out decision memo
- list of next candidate markets

### Dependencies

- PT and ES stable in production-like usage

## Suggested Issue Breakdown

### Epic / umbrella

- `#217` Multi-country grocery pricing architecture

### Child issues to create later

1. Add market/store configuration layer
2. Add canonical product + store listing schemas
3. Refactor PT scrapers into store adapters
4. Build PT country bundle artifacts
5. Make grocery loader country-aware in the app
6. Add reusable country/store scraping workflow
7. Add Spain grocery market support
8. Surface store freshness and quality in UI
9. Add matching diagnostics and override tooling

## Recommended Execution Order

1. Milestone 1
2. Milestone 2
3. Milestone 3
4. Milestone 4
5. Milestone 5
6. Milestone 6
7. Milestone 7
8. Milestone 8
9. Milestone 9
10. Milestone 10

## Bottom Line

The key implementation sequence is:

- config layer
- schema layer
- PT refactor
- app loader refactor
- workflow refactor
- Spain rollout

Anything else risks adding a second country on top of an architecture that is still PT-hardcoded.
