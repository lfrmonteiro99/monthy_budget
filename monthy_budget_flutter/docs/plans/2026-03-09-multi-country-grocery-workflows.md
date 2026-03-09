# Multi-Country Grocery Scraping Workflow Plan

**Date:** 2026-03-09
**Issue:** #217

## 1. Goal

Define a GitHub Actions plan that evolves the current Portugal-only grocery scraping workflow into a reusable country/store matrix pipeline.

The workflow must:

- run country/store jobs independently
- isolate scraper failures by store
- produce normalized artifacts
- publish freshness metadata
- allow gradual rollout by market

## 2. Current Problem

The existing workflow is effectively optimized for Portuguese sources and assumptions.

That creates these limitations:

- difficult to add new stores cleanly
- difficult to add new countries cleanly
- normalization concerns are mixed into scraping concerns
- failures are harder to isolate per country/store

## 3. Target Workflow Model

Move from:

- one country-specific pricing workflow

To:

- one reusable multi-country workflow
- parameterized by country and store
- driven by a matrix

## 4. Recommended Workflow Split

Use four logical jobs.

### 4.1 `scrape-store`

Runs one scraper adapter for one country/store pair.

Inputs:

- `country`
- `store`
- optional `environment`

Responsibilities:

- fetch raw listings
- validate minimum scrape health
- emit raw artifact for that store
- emit scraper metadata

### 4.2 `normalize-store`

Normalizes one store artifact.

Responsibilities:

- parse units and quantities
- compute normalized price-per-unit
- build `ScrapedListing` outputs
- emit validation warnings

### 4.3 `build-country-bundle`

Aggregates all normalized store outputs for one country.

Responsibilities:

- canonical product matching
- build `CanonicalProduct` + `StoreListing` bundles
- compute store freshness summaries
- emit app-facing country artifacts

### 4.4 `publish-artifacts`

Publishes final country bundles and status metadata.

Responsibilities:

- upload workflow artifacts
- optionally commit generated assets to repo or storage bucket
- publish status summary

## 5. Matrix Strategy

### 5.1 Initial matrix

Start with explicit includes, not generated discovery.

```yaml
strategy:
  fail-fast: false
  matrix:
    include:
      - country: PT
        store: continente
      - country: PT
        store: pingo_doce
      - country: PT
        store: auchan
      - country: ES
        store: mercadona
      - country: ES
        store: carrefour_es
      - country: ES
        store: dia
```

Why explicit `include` is better first:

- easier rollout control
- easier temporary disabling of one store
- easier debugging when one adapter is unstable

### 5.2 Failure behavior

Set:

- `fail-fast: false`

Reason:

- one broken store should not cancel every other store scrape in the matrix

## 6. Workflow Inputs and Secrets

### Inputs

Recommended reusable workflow inputs:

- `country`
- `store`
- `commit_artifacts` (`true/false`)
- `publish_summary` (`true/false`)

### Secrets

Prefer store-specific secrets only when needed.

Examples:

- proxy credentials
- anti-bot tokens if ever required

Do not assume every store requires secrets.

## 7. Suggested Workflow File Layout

### Root workflows

- `.github/workflows/grocery-prices.yml`
  Main scheduled/manual entrypoint

- `.github/workflows/grocery-scrape-reusable.yml`
  Reusable workflow invoked per matrix entry

## 8. Suggested YAML Shape

### 8.1 Entrypoint workflow

```yaml
name: Grocery Prices

on:
  workflow_dispatch:
  schedule:
    - cron: '0 5 * * *'

jobs:
  scrape:
    uses: ./.github/workflows/grocery-scrape-reusable.yml
    strategy:
      fail-fast: false
      matrix:
        include:
          - country: PT
            store: continente
          - country: PT
            store: pingo_doce
          - country: ES
            store: mercadona
          - country: ES
            store: carrefour_es
    with:
      country: ${{ matrix.country }}
      store: ${{ matrix.store }}
```

### 8.2 Reusable workflow

```yaml
name: Grocery Scrape Reusable

on:
  workflow_call:
    inputs:
      country:
        required: true
        type: string
      store:
        required: true
        type: string

jobs:
  scrape-store:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup runtime
        run: ./scripts/setup-grocery-env.sh
      - name: Scrape store
        run: python scripts/grocery/scrape.py --country ${{ inputs.country }} --store ${{ inputs.store }}
      - name: Normalize store
        run: python scripts/grocery/normalize.py --country ${{ inputs.country }} --store ${{ inputs.store }}
      - name: Upload store artifact
        uses: actions/upload-artifact@v4
        with:
          name: grocery-${{ inputs.country }}-${{ inputs.store }}
          path: generated/grocery/${{ inputs.country }}/${{ inputs.store }}/*.json
```

## 9. Artifact Layout

Recommended generated path layout:

```text
generated/grocery/PT/continente/raw.json
generated/grocery/PT/continente/normalized.json
generated/grocery/PT/continente/status.json
generated/grocery/PT/catalog.json
generated/grocery/PT/store_summaries.json
generated/grocery/ES/mercadona/raw.json
generated/grocery/ES/mercadona/normalized.json
generated/grocery/ES/catalog.json
```

## 10. Build / Validation Steps

### 10.1 Scrape validation

At the end of each store job, validate:

- listing count above minimum threshold
- required fields present
- parse success above threshold

### 10.2 Normalize validation

Validate:

- unit normalization coverage
- price-per-unit coverage
- duplicate `storeProductId` rate
- malformed quantity/title rate

### 10.3 Country bundle validation

Validate:

- canonical match coverage
- duplicate canonical product rate
- stale store summary generation
- JSON schema validity

## 11. Scheduling Strategy

### Phase 1

Run PT only on schedule.

### Phase 2

Add ES on schedule after PT bundle builder is stable.

### Phase 3

If store runtimes get too long:

- split schedule by country
- or run PT and ES in separate workflow schedules

## 12. Publishing Strategy

Three viable options:

### Option A: Commit generated assets to repo

Pros:

- simple visibility
- easy rollback

Cons:

- repo noise
- large JSON churn

### Option B: Store artifacts in GitHub Actions artifacts only

Pros:

- easy to implement

Cons:

- poor for app consumption

### Option C: Publish to remote storage and keep app bundles curated

Pros:

- best long-term separation

Cons:

- more infrastructure work

Recommendation:

- short term: commit curated app-facing bundles or publish them in a controlled artifact step
- long term: move large generated datasets to remote storage

## 13. Failure Handling

Each store run should produce a `status.json` even when scrape quality is poor.

Example status payload:

```json
{
  "countryCode": "ES",
  "storeId": "mercadona",
  "scrapeStatus": "partial",
  "lastUpdatedAt": "2026-03-09T05:10:00Z",
  "listingCount": 812,
  "matchedCount": 730,
  "unmatchedCount": 82,
  "validationWarnings": [
    "unit normalization coverage below threshold",
    "promotion parsing partially failed"
  ]
}
```

This avoids silent failure.

## 14. App Contract

The mobile app should never assume:

- every store in a country is fresh
- every country has the same store set
- every listing has normalized unit price

It should consume store summaries and degrade gracefully.

## 15. Rollout Plan

### Step 1

Refactor PT workflow into reusable country/store job.

### Step 2

Split PT outputs by store and country.

### Step 3

Build PT country bundle from store artifacts.

### Step 4

Add ES stores to matrix behind explicit `include`.

### Step 5

Expose freshness/status in app UI.

## 16. Recommended Initial Matrix

Start with:

- PT / continente
- PT / pingo_doce
- PT / auchan
- ES / mercadona
- ES / carrefour_es

Keep the first ES rollout intentionally small.

## 17. Bottom Line

The workflow change should not just add more scrapers.

It should formalize a pipeline where:

- each store runs independently
- normalization is explicit
- country bundles are built intentionally
- app-facing data is validated and freshness-aware

That is what makes multi-country pricing maintainable instead of becoming a copy-paste scraper mess.
