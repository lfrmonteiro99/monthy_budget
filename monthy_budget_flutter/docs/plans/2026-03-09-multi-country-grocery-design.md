# Multi-Country Grocery Pricing Design

**Date:** 2026-03-09
**Issue:** #217

## 1. Goal

Evolve the grocery pricing subsystem from a Portugal-only scraping pipeline into a multi-country architecture that can support:

- country-specific supermarkets
- country-specific product catalogs
- normalized price comparison
- store freshness metadata
- gradual rollout by market

The immediate goal is not to add every country at once. The goal is to refactor the current PT-specific pipeline into an architecture that scales cleanly to additional markets.

## 2. Current Problem

Today the pricing workflow is effectively optimized for Portugal:

- source list is PT-specific
- normalization is PT-specific
- workflow assumptions are PT-specific
- grocery assets are treated as one country dataset

That creates three limits:

1. Scrapers are too tightly coupled to one market.
2. Raw scraped titles are doing too much identity work.
3. The app cannot safely compare or present products from other countries without stronger normalization.

## 3. Design Principles

1. Country-first, not global-first.
   Product matching should be correct inside one country before attempting cross-country generalization.

2. Canonical product model must be separate from raw store listings.
   Raw scraped names are not stable enough to be the product identity layer.

3. Per-store scraping adapters must be isolated.
   Each retailer should be implemented behind a common interface.

4. Comparison must be based on normalized units.
   Ranking by raw pack price is misleading.

5. Freshness and source quality are first-class metadata.
   The UI should know when a store dataset is stale or partial.

6. Roll out market by market.
   Portugal should be refactored into the target architecture first, then Spain should be the second market.

## 4. Target Architecture

### 4.1 Layer 1: Market Configuration Layer

Defines market-specific configuration.

Responsibilities:

- supported countries
- supported currency per country
- supported supermarkets per country
- locale/language defaults
- unit conventions
- category mappings
- scraper registry

This layer answers questions like:

- Which stores are active in Spain?
- What currency and locale should be used?
- Which unit labels need normalization?

### 4.2 Layer 2: Canonical Product Layer

Defines a country-scoped canonical representation of a grocery product.

Responsibilities:

- normalize product identity
- normalize brand and quantity
- normalize package size and unit
- anchor store listings to a canonical product

This is the most important structural change.

Without it, every new country will require fragile title matching and duplicate product identities.

### 4.3 Layer 3: Store Listing Layer

Represents one scraped product record from one retailer.

Responsibilities:

- capture raw title and raw price
- hold store-specific identifiers
- hold promotional flags when available
- compute normalized price-per-unit
- attach freshness metadata

### 4.4 Layer 4: Scraper Adapter Layer

Each retailer scraper implements the same interface.

Responsibilities:

- fetch raw listings from one store
- map raw data into a shared scraped listing shape
- emit store-level scrape metadata
- fail independently from other scrapers

The system should never depend on one giant country scraper.

### 4.5 Layer 5: Country Build Pipeline Layer

Builds country/store outputs into normalized artifacts.

Responsibilities:

- run scrapers by matrix
- normalize and validate outputs
- build country bundles
- publish freshness metadata
- fail one store without breaking all countries if possible

### 4.6 Layer 6: App Consumption Layer

The mobile app loads grocery data according to user country and optionally preferred stores.

Responsibilities:

- load country-specific asset bundle
- display store freshness/status
- compare products within selected country
- preserve UX when some stores are unavailable or stale

## 5. Recommended Country Expansion Strategy

### Phase 1: Refactor Portugal into target architecture

Do not add another country before PT itself is restructured into:

- canonical products
- store listings
- market config
- country/store build pipeline

### Phase 2: Add Spain

Spain is the recommended second market because:

- same currency as PT
- similar grocery comparison behavior
- easier than introducing GBP and a different retailer structure immediately

Suggested initial Spanish stores:

- Mercadona
- Carrefour ES
- DIA

### Phase 3: Add France or UK

Only after PT and ES are stable.

UK introduces more complexity:

- different currency
- broader pack-size patterns
- potentially different retailer site behavior

## 6. Data Flow

```text
Store scraper -> Raw scraped listing -> Normalization -> Canonical product match
-> Store listing output -> Country bundle builder -> App asset / API payload
```

Detailed flow:

1. A store adapter fetches raw products.
2. Raw records are transformed into `ScrapedListing` objects.
3. Text, size, unit, and brand are normalized.
4. Each listing is linked to a country-scoped canonical product.
5. Unit price and freshness metadata are computed.
6. Country bundles are generated for app consumption.

## 7. Product Matching Rules

Matching should happen within a country first.

Suggested precedence:

1. store-native product ID match if already mapped
2. barcode match if available and trusted
3. normalized brand + normalized name + pack size + unit
4. fallback fuzzy match under review threshold

Never default to cross-country matching in the first implementation.

## 8. Normalization Requirements

Normalization pipeline should standardize:

- accents and casing
- punctuation and separators
- decimal separators
- unit labels
- size extraction from titles
- package count patterns
- common retailer-specific naming noise

Examples of units to normalize:

- `kg`
- `g`
- `l`
- `ml`
- `un`
- `pack`

Derived values should include:

- normalized quantity
- normalized unit
- normalized price per base unit

## 9. Freshness and Quality Model

Every store dataset should carry metadata:

- `lastUpdatedAt`
- `scrapeStatus`
- `listingCount`
- `normalizationCoverage`
- `matchCoverage`
- `validationWarnings`

This is necessary because country expansion will increase variability in source quality.

## 10. App Impact

The app should evolve from a single grocery dataset assumption to country-aware loading.

Recommended asset structure:

```text
assets/grocery/PT/catalog.json
assets/grocery/PT/stores/continente.json
assets/grocery/PT/stores/pingo_doce.json
assets/grocery/ES/catalog.json
assets/grocery/ES/stores/mercadona.json
assets/grocery/ES/stores/carrefour_es.json
```

The app should load based on:

1. user country setting
2. optional preferred store filters
3. store freshness availability

## 11. Risks

### 11.1 Identity drift

If canonical matching is weak, duplicate products will explode.

### 11.2 Unit comparison errors

If price-per-unit normalization is inconsistent, rankings become misleading.

### 11.3 Scraper maintenance load

Every added store increases breakage surface.

### 11.4 UX inconsistency

Some countries may have fewer stores or weaker freshness. The app must reflect that honestly.

## 12. Non-Goals for V1

- cross-country grocery comparison
- automatic substitution suggestions across countries
- fully global canonical product graph
- real-time live API price sync in the mobile app

## 13. Recommended Implementation Order

1. Introduce market configuration layer
2. Introduce canonical product and store listing schema
3. Refactor PT scrapers into adapter interface
4. Split PT output into country/store artifacts
5. Add validation and freshness metadata
6. Update app loader to be country-aware
7. Add Spain

## 14. Bottom Line

The key design move is this:

- stop treating scraped product titles as your product system
- start treating them as store listings linked to canonical country-scoped products

That is the foundation that makes multi-country grocery pricing feasible without the system collapsing into duplicated, inconsistent product data.
