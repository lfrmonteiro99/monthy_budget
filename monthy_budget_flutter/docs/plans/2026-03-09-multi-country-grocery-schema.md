# Multi-Country Grocery Pricing Schema

**Date:** 2026-03-09
**Issue:** #217

## 1. Goal

Define the concrete schema needed to support multi-country grocery pricing with clean separation between:

- market configuration
- canonical products
- raw/scraped store listings
- freshness metadata
- build outputs consumed by the app

This schema is intentionally country-scoped first.

## 2. Core Entities

### 2.1 MarketConfig

Represents one supported country/market.

| Field | Type | Required | Description |
|---|---|---:|---|
| `countryCode` | `String` | yes | ISO-like country code, e.g. `PT`, `ES` |
| `displayName` | `String` | yes | Human-readable market name |
| `currencyCode` | `String` | yes | `EUR`, `GBP`, etc. |
| `locale` | `String` | yes | e.g. `pt-PT`, `es-ES` |
| `baseWeightUnit` | `String` | yes | e.g. `kg` |
| `baseVolumeUnit` | `String` | yes | e.g. `l` |
| `enabled` | `bool` | yes | Whether market is active |
| `stores` | `List<StoreConfig>` | yes | Supported stores |

### 2.2 StoreConfig

Represents one supermarket configuration inside a market.

| Field | Type | Required | Description |
|---|---|---:|---|
| `storeId` | `String` | yes | Stable internal id, e.g. `continente`, `mercadona` |
| `countryCode` | `String` | yes | Owning market |
| `displayName` | `String` | yes | Human-readable store name |
| `sourceType` | `String` | yes | `scraper`, `feed`, `manual` |
| `enabled` | `bool` | yes | Store active flag |
| `sortOrder` | `int` | no | Preferred ordering in UI |
| `supportsBarcode` | `bool` | no | Whether barcode data is available |
| `supportsPromotions` | `bool` | no | Whether promo fields are expected |

## 3. Canonical Product Layer

### 3.1 CanonicalProduct

Country-scoped normalized product identity.

| Field | Type | Required | Description |
|---|---|---:|---|
| `id` | `String` | yes | Stable canonical id |
| `countryCode` | `String` | yes | Product belongs to one market |
| `categoryId` | `String` | yes | Internal grocery category |
| `subcategoryId` | `String?` | no | Optional subcategory |
| `normalizedName` | `String` | yes | Normalized product display core |
| `displayName` | `String` | yes | Human-readable preferred title |
| `brand` | `String?` | no | Brand if applicable |
| `genericName` | `String?` | no | Generic family name |
| `sizeValue` | `double?` | no | Pack quantity |
| `sizeUnit` | `String?` | no | `kg`, `g`, `l`, `ml`, `unit` |
| `packCount` | `int?` | no | Number of units in multipack |
| `baseQuantity` | `double?` | no | Quantity converted to market base unit |
| `baseUnit` | `String?` | no | Base comparison unit |
| `barcode` | `String?` | no | Trusted barcode if known |
| `keywords` | `List<String>` | no | Search synonyms |
| `isActive` | `bool` | yes | Whether product is active |
| `createdAt` | `DateTime` | yes | Audit field |
| `updatedAt` | `DateTime` | yes | Audit field |

### 3.2 Canonical Product Constraints

- `id` must be stable and not derived from raw title alone.
- `countryCode + normalizedName + sizeValue + sizeUnit + brand` should be highly unique.
- canonical product identity must not be shared cross-country in V1.

## 4. Store Listing Layer

### 4.1 StoreListing

Represents one specific store's product listing.

| Field | Type | Required | Description |
|---|---|---:|---|
| `id` | `String` | yes | Stable listing id |
| `countryCode` | `String` | yes | Owning market |
| `storeId` | `String` | yes | Owning store |
| `canonicalProductId` | `String` | yes | Linked canonical product |
| `storeProductId` | `String` | yes | Native retailer id |
| `productUrl` | `String?` | no | Store product URL |
| `rawTitle` | `String` | yes | Raw scraped title |
| `displayTitle` | `String` | yes | UI-ready title |
| `brand` | `String?` | no | Scraped or normalized brand |
| `sizeValue` | `double?` | no | Parsed size value |
| `sizeUnit` | `String?` | no | Parsed size unit |
| `packCount` | `int?` | no | Parsed pack count |
| `price` | `double` | yes | Current price |
| `currencyCode` | `String` | yes | Usually market currency |
| `pricePerBaseUnit` | `double?` | no | Normalized unit price |
| `baseUnit` | `String?` | no | Unit for normalized comparison |
| `isPromo` | `bool` | no | Promotion flag |
| `promoLabel` | `String?` | no | Raw promo text |
| `imageUrl` | `String?` | no | Optional image |
| `availability` | `String?` | no | `in_stock`, `unknown`, etc. |
| `lastSeenAt` | `DateTime` | yes | Last scrape timestamp |
| `sourceStatus` | `String` | yes | `fresh`, `stale`, `partial`, `failed` |

### 4.2 Listing Constraints

- `storeId + storeProductId` must be unique.
- `canonicalProductId` must exist in the same country.
- `pricePerBaseUnit` must only be populated when normalization is trustworthy.

## 5. Raw Scrape Layer

### 5.1 ScrapedListing

Internal ingestion shape before canonical matching.

| Field | Type | Required | Description |
|---|---|---:|---|
| `storeId` | `String` | yes | Source store |
| `countryCode` | `String` | yes | Source country |
| `storeProductId` | `String` | yes | Native retailer id |
| `rawTitle` | `String` | yes | Raw scraped product title |
| `rawPrice` | `double?` | yes | Raw price if found |
| `rawCurrency` | `String?` | no | Raw currency if exposed |
| `productUrl` | `String?` | no | Product URL |
| `imageUrl` | `String?` | no | Optional image |
| `rawPromoLabel` | `String?` | no | Promotion text |
| `rawSizeText` | `String?` | no | Unparsed quantity text |
| `barcode` | `String?` | no | Raw barcode if available |
| `scrapedAt` | `DateTime` | yes | Scrape timestamp |

This should never be the app-facing model.

## 6. Freshness / Status Layer

### 6.1 StoreDatasetStatus

Tracks scraper quality and freshness for one store snapshot.

| Field | Type | Required | Description |
|---|---|---:|---|
| `countryCode` | `String` | yes | Market |
| `storeId` | `String` | yes | Store |
| `runId` | `String` | yes | Workflow/build id |
| `lastUpdatedAt` | `DateTime` | yes | Snapshot timestamp |
| `scrapeStatus` | `String` | yes | `success`, `partial`, `failed` |
| `listingCount` | `int` | yes | Listings scraped |
| `matchedCount` | `int` | yes | Listings matched to canonical products |
| `unmatchedCount` | `int` | yes | Unmatched listings |
| `validationWarnings` | `List<String>` | no | Warning summaries |
| `sourceVersion` | `String?` | no | Scraper version/hash |

## 7. App-Facing Bundles

### 7.1 CountryCatalogBundle

App bundle loaded for one market.

| Field | Type | Required | Description |
|---|---|---:|---|
| `countryCode` | `String` | yes | Market |
| `currencyCode` | `String` | yes | Market currency |
| `generatedAt` | `DateTime` | yes | Bundle timestamp |
| `products` | `List<CanonicalProduct>` | yes | Market catalog |
| `stores` | `List<StoreSummary>` | yes | Store metadata |
| `listings` | `List<StoreListing>` | yes | Store-specific listings |

### 7.2 StoreSummary

| Field | Type | Required | Description |
|---|---|---:|---|
| `storeId` | `String` | yes | Internal id |
| `displayName` | `String` | yes | Human-readable name |
| `lastUpdatedAt` | `DateTime?` | no | Freshness |
| `status` | `String` | yes | `fresh`, `stale`, `partial`, `failed` |
| `listingCount` | `int` | yes | Count |

## 8. Matching Metadata

### 8.1 ListingMatchResult

Optional internal artifact for diagnostics.

| Field | Type | Required | Description |
|---|---|---:|---|
| `listingId` | `String` | yes | Listing |
| `canonicalProductId` | `String?` | no | Match target |
| `matchMethod` | `String` | yes | `store_id`, `barcode`, `exact`, `heuristic`, `manual` |
| `matchConfidence` | `double` | yes | 0.0 - 1.0 |
| `reviewRequired` | `bool` | yes | Whether manual review needed |

## 9. Example JSON Shapes

### 9.1 CanonicalProduct

```json
{
  "id": "PT_milk_uht_semidesnatado_1l_generic",
  "countryCode": "PT",
  "categoryId": "milk",
  "subcategoryId": "uht",
  "normalizedName": "leite meio gordo uht",
  "displayName": "Leite Meio Gordo UHT 1L",
  "brand": null,
  "genericName": "Leite Meio Gordo",
  "sizeValue": 1.0,
  "sizeUnit": "l",
  "packCount": 1,
  "baseQuantity": 1.0,
  "baseUnit": "l",
  "barcode": null,
  "keywords": ["leite", "meio gordo", "uht"],
  "isActive": true,
  "createdAt": "2026-03-09T00:00:00Z",
  "updatedAt": "2026-03-09T00:00:00Z"
}
```

### 9.2 StoreListing

```json
{
  "id": "PT_continente_123456",
  "countryCode": "PT",
  "storeId": "continente",
  "canonicalProductId": "PT_milk_uht_semidesnatado_1l_generic",
  "storeProductId": "123456",
  "productUrl": "https://www.continente.pt/produto/123456",
  "rawTitle": "Leite Meio Gordo UHT Continente 1 L",
  "displayTitle": "Leite Meio Gordo Continente 1L",
  "brand": "Continente",
  "sizeValue": 1.0,
  "sizeUnit": "l",
  "packCount": 1,
  "price": 0.89,
  "currencyCode": "EUR",
  "pricePerBaseUnit": 0.89,
  "baseUnit": "l",
  "isPromo": false,
  "promoLabel": null,
  "imageUrl": null,
  "availability": "in_stock",
  "lastSeenAt": "2026-03-09T06:00:00Z",
  "sourceStatus": "fresh"
}
```

## 10. Storage Recommendation

### For build artifacts

JSON is acceptable.

### For structured backend storage later

Recommended tables:

- `market_configs`
- `store_configs`
- `canonical_products`
- `store_listings`
- `store_dataset_status`
- optional `listing_match_results`

## 11. Constraints for V1

- country-scoped canonical ids only
- single-currency per market
- no cross-country bundle merge
- no cross-country canonical dedupe

## 12. Bottom Line

The two most important entities are:

- `CanonicalProduct`
- `StoreListing`

If those two are modeled correctly, the rest of the multi-country grocery system becomes composable. If they are not, every added country will increase inconsistency and maintenance cost.
