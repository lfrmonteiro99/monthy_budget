"""Normalization models for grocery pipeline artifacts."""

from __future__ import annotations

from dataclasses import asdict, dataclass
from typing import Any


@dataclass(frozen=True)
class ParsedSize:
    size_value: float | None
    size_unit: str | None
    pack_count: int | None
    base_quantity: float | None
    base_unit: str | None


@dataclass(frozen=True)
class StoreListing:
    id: str
    country_code: str
    store_id: str
    canonical_product_id: str | None
    store_product_id: str
    product_url: str | None
    raw_title: str
    display_title: str
    brand: str | None
    size_value: float | None
    size_unit: str | None
    pack_count: int | None
    base_quantity: float | None
    base_unit: str | None
    price: float
    currency_code: str
    price_per_base_unit: float | None
    source_status: str

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass(frozen=True)
class CanonicalProduct:
    id: str
    country_code: str
    category_id: str
    normalized_name: str
    display_name: str
    size_value: float | None
    size_unit: str | None
    base_quantity: float | None
    base_unit: str | None
    brand: str | None = None
    generic_name: str | None = None
    subcategory_id: str | None = None
    pack_count: int | None = None
    barcode: str | None = None
    keywords: tuple[str, ...] = ()
    source_product_ids: dict[str, tuple[str, ...]] | None = None

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass(frozen=True)
class ListingMatchResult:
    listing_id: str
    canonical_product_id: str | None
    match_method: str
    match_confidence: float
    review_required: bool

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass(frozen=True)
class NormalizationResult:
    listings: list[StoreListing]
    warnings: list[str]


@dataclass(frozen=True)
class MatchingResult:
    listings: list[StoreListing]
    match_results: list[ListingMatchResult]
    matched_count: int
    unmatched_count: int
    low_confidence_count: int


@dataclass(frozen=True)
class StoreDatasetStatus:
    country_code: str
    store_id: str
    run_id: str
    last_updated_at: str
    scrape_status: str
    listing_count: int
    matched_count: int
    unmatched_count: int
    validation_warnings: list[str]
    source_version: str | None = None

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)


@dataclass(frozen=True)
class StoreSummary:
    store_id: str
    display_name: str
    last_updated_at: str | None
    status: str
    listing_count: int

    def to_dict(self) -> dict[str, Any]:
        return asdict(self)
