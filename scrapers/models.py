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
class NormalizationResult:
    listings: list[StoreListing]
    warnings: list[str]
