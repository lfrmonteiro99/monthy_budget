# PT + ES Grocery File and Script Layout

**Date:** 2026-03-09
**Issue:** #217

## Goal

Define a concrete file, asset, and script structure for the first multi-country grocery implementation covering:

- Portugal (`PT`)
- Spain (`ES`)

The structure should support:

- per-country configuration
- per-store scrapers
- normalized intermediate artifacts
- app-facing country bundles
- GitHub Actions matrix execution

## 1. Recommended Repository Layout

```text
monthy_budget_flutter/
|-- assets/
|   `-- grocery/
|       |-- PT/
|       |   |-- catalog.json
|       |   |-- store_summaries.json
|       |   `-- stores/
|       |       |-- continente.json
|       |       |-- pingo_doce.json
|       |       `-- auchan.json
|       `-- ES/
|           |-- catalog.json
|           |-- store_summaries.json
|           `-- stores/
|               |-- mercadona.json
|               |-- carrefour_es.json
|               `-- dia.json
|-- generated/
|   `-- grocery/
|       |-- PT/
|       |   |-- catalog.json
|       |   |-- store_summaries.json
|       |   `-- stores/
|       |       |-- continente/
|       |       |   |-- raw.json
|       |       |   |-- normalized.json
|       |       |   `-- status.json
|       |       |-- pingo_doce/
|       |       `-- auchan/
|       `-- ES/
|           |-- catalog.json
|           |-- store_summaries.json
|           `-- stores/
|               |-- mercadona/
|               |-- carrefour_es/
|               `-- dia/
|-- scripts/
|   `-- grocery/
|       |-- config/
|       |   |-- markets.json
|       |   |-- PT.json
|       |   `-- ES.json
|       |-- core/
|       |   |-- models.py
|       |   |-- units.py
|       |   |-- normalizer.py
|       |   |-- matcher.py
|       |   |-- validators.py
|       |   `-- bundle_builder.py
|       |-- scrapers/
|       |   |-- base.py
|       |   |-- pt/
|       |   |   |-- continente.py
|       |   |   |-- pingo_doce.py
|       |   |   `-- auchan.py
|       |   `-- es/
|       |       |-- mercadona.py
|       |       |-- carrefour_es.py
|       |       `-- dia.py
|       |-- scrape.py
|       |-- normalize.py
|       |-- build_country_bundle.py
|       `-- validate_bundle.py
`-- .github/
    `-- workflows/
        |-- grocery-prices.yml
        `-- grocery-scrape-reusable.yml
```

## 2. Config Files

### 2.1 `scripts/grocery/config/markets.json`

Top-level market index.

Example:

```json
{
  "markets": ["PT", "ES"]
}
```

### 2.2 `scripts/grocery/config/PT.json`

Portugal market definition.

Example:

```json
{
  "countryCode": "PT",
  "displayName": "Portugal",
  "currencyCode": "EUR",
  "locale": "pt-PT",
  "baseWeightUnit": "kg",
  "baseVolumeUnit": "l",
  "stores": [
    { "storeId": "continente", "displayName": "Continente", "enabled": true },
    { "storeId": "pingo_doce", "displayName": "Pingo Doce", "enabled": true },
    { "storeId": "auchan", "displayName": "Auchan", "enabled": true }
  ]
}
```

### 2.3 `scripts/grocery/config/ES.json`

Spain market definition.

Example:

```json
{
  "countryCode": "ES",
  "displayName": "Spain",
  "currencyCode": "EUR",
  "locale": "es-ES",
  "baseWeightUnit": "kg",
  "baseVolumeUnit": "l",
  "stores": [
    { "storeId": "mercadona", "displayName": "Mercadona", "enabled": true },
    { "storeId": "carrefour_es", "displayName": "Carrefour", "enabled": true },
    { "storeId": "dia", "displayName": "DIA", "enabled": false }
  ]
}
```

## 3. Script Responsibilities

### 3.1 `scrape.py`

CLI entrypoint for one country/store scrape.

Example usage:

```bash
python scripts/grocery/scrape.py --country PT --store continente
python scripts/grocery/scrape.py --country ES --store mercadona
```

Responsibilities:

- load market/store config
- instantiate correct scraper adapter
- write `raw.json`
- write initial `status.json`

### 3.2 `normalize.py`

CLI entrypoint for one country/store normalization.

Example usage:

```bash
python scripts/grocery/normalize.py --country PT --store continente
```

Responsibilities:

- read `raw.json`
- normalize quantities and units
- compute price-per-unit
- write `normalized.json`
- update `status.json`

### 3.3 `build_country_bundle.py`

CLI entrypoint for one country bundle.

Example usage:

```bash
python scripts/grocery/build_country_bundle.py --country PT
python scripts/grocery/build_country_bundle.py --country ES
```

Responsibilities:

- aggregate all normalized store outputs in the country
- canonical product matching
- emit `catalog.json`
- emit `store_summaries.json`
- emit per-store app-facing outputs if needed

### 3.4 `validate_bundle.py`

CLI entrypoint for bundle validation.

Example usage:

```bash
python scripts/grocery/validate_bundle.py --country PT
```

Responsibilities:

- schema validation
- duplicate detection
- low-match-rate warnings
- stale-store warnings

## 4. Core Python Modules

### 4.1 `core/models.py`

Should contain:

- `MarketConfig`
- `StoreConfig`
- `ScrapedListing`
- `CanonicalProduct`
- `StoreListing`
- `StoreDatasetStatus`

### 4.2 `core/units.py`

Should contain:

- country/unit normalization maps
- quantity parsing helpers
- base-unit conversion helpers

### 4.3 `core/normalizer.py`

Should contain:

- title cleanup
- size extraction
- brand extraction
- normalized display title builders
- unit price computation helpers

### 4.4 `core/matcher.py`

Should contain:

- canonical matching logic
- match confidence scoring
- fallback heuristics
- optional override support

### 4.5 `core/validators.py`

Should contain:

- raw listing validation
- normalized listing validation
- bundle validation
- thresholds and warnings

### 4.6 `core/bundle_builder.py`

Should contain:

- country bundle assembly logic
- store summaries generation
- app-facing serialization

## 5. Scraper Base Interface

### `scripts/grocery/scrapers/base.py`

Define:

```python
class StoreScraper:
    country_code: str
    store_id: str

    def fetch(self) -> list[dict]:
        raise NotImplementedError
```

Adapters should return raw records that are then transformed into `ScrapedListing`.

## 6. PT Initial Store Set

Recommended first PT adapters:

- `continente.py`
- `pingo_doce.py`
- `auchan.py`

Reason:

- enough store diversity
- meaningful PT market coverage
- manageable first refactor scope

## 7. ES Initial Store Set

Recommended initial ES adapters:

- `mercadona.py`
- `carrefour_es.py`
- `dia.py` optional after first two are stable

Reason:

- strong consumer relevance
- same-currency market as PT
- good second-market validation

## 8. App Asset Consumption

The Flutter app should stop assuming a single `grocery_prices.json` file and move toward a country-aware loader.

Suggested loader rules:

1. read current user country
2. load `assets/grocery/<COUNTRY>/catalog.json`
3. load `assets/grocery/<COUNTRY>/store_summaries.json`
4. optionally lazy-load per-store files

## 9. Suggested Country Bundle Shape

### `assets/grocery/PT/catalog.json`

Contains:

- canonical products
- store listings or compact product comparisons

### `assets/grocery/PT/store_summaries.json`

Contains:

- freshness by store
- listing counts
- validation status

### `assets/grocery/PT/stores/continente.json`

Contains:

- detailed PT/Continente store listing data if the app needs store-specific drilldown

## 10. GitHub Actions Mapping

### Workflow files

- `.github/workflows/grocery-prices.yml`
- `.github/workflows/grocery-scrape-reusable.yml`

### Matrix example

```yaml
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
```

### Job mapping

- `scrape.py` per matrix store
- `normalize.py` per matrix store
- `build_country_bundle.py` once per country after store jobs
- `validate_bundle.py` once per country after build

## 11. Minimal V1 Implementation Scope

If you want the smallest credible first version:

### In code

- config loader
- PT adapters behind interface
- canonical/store listing schema
- country-aware bundle builder
- app loader updated for PT bundles only

### In workflow

- PT matrix only at first
- ES config and folder layout prepared but disabled

### Then

- add ES adapters and activate ES matrix entries

## 12. Bottom Line

The concrete structure should optimize for one thing:

- adding a new store should mean adding one adapter and one config entry
- adding a new country should mean adding one market config, store configs, and country bundle generation

If directory layout, scripts, and assets reflect that principle, the system will scale cleanly. If they do not, country expansion will become copy-paste debt very quickly.
