"""EU listing normalization helpers."""

from __future__ import annotations

import re

from .base import ScrapedListing
from .models import NormalizationResult, ParsedSize, StoreListing

_SINGLE_SIZE_RE = re.compile(r"(?<!\d)(\d+(?:[\.,]\d+)?)\s*(kg|g|l|cl|ml)\b", re.IGNORECASE)
_MULTIPACK_SIZE_RE = re.compile(r"(\d+)\s*[xX]\s*(\d+(?:[\.,]\d+)?)\s*(kg|g|l|cl|ml)\b", re.IGNORECASE)
_UNIT_PRICE_RE = re.compile(r"(\d+(?:[\.,]\d+)?)\s*/\s*(kg|g|l|cl|ml)\b", re.IGNORECASE)


def _parse_number(value: str) -> float:
    return float(value.replace(",", "."))


def _normalize_unit(unit: str) -> str:
    return unit.strip().lower()


def _to_base_quantity(value: float, unit: str, pack_count: int) -> tuple[float, str]:
    unit = _normalize_unit(unit)
    if unit == "kg":
        return round(value * pack_count, 3), "kg"
    if unit == "g":
        return round((value * pack_count) / 1000, 3), "kg"
    if unit == "l":
        return round(value * pack_count, 3), "l"
    if unit == "cl":
        return round((value * pack_count) / 100, 3), "l"
    if unit == "ml":
        return round((value * pack_count) / 1000, 3), "l"
    raise ValueError(f"unsupported unit: {unit}")


def parse_size_text(text: str | None) -> ParsedSize:
    if not text:
        return ParsedSize(None, None, None, None, None)

    multipack = _MULTIPACK_SIZE_RE.search(text)
    if multipack:
        pack_count = int(multipack.group(1))
        size_value = _parse_number(multipack.group(2))
        size_unit = _normalize_unit(multipack.group(3))
        base_quantity, base_unit = _to_base_quantity(size_value, size_unit, pack_count)
        return ParsedSize(size_value, size_unit, pack_count, base_quantity, base_unit)

    single = _SINGLE_SIZE_RE.search(text)
    if single:
        size_value = _parse_number(single.group(1))
        size_unit = _normalize_unit(single.group(2))
        base_quantity, base_unit = _to_base_quantity(size_value, size_unit, 1)
        return ParsedSize(size_value, size_unit, 1, base_quantity, base_unit)

    return ParsedSize(None, None, None, None, None)


def _parse_unit_price(unit_price: str | None) -> tuple[float | None, str | None]:
    if not unit_price:
        return None, None

    match = _UNIT_PRICE_RE.search(unit_price)
    if not match:
        return None, None

    value = _parse_number(match.group(1))
    unit = _normalize_unit(match.group(2))
    if unit == "g":
        return round(value * 1000, 2), "kg"
    if unit == "cl":
        return round(value * 100, 2), "l"
    if unit == "ml":
        return round(value * 1000, 2), "l"
    return round(value, 2), unit


def _build_listing_id(listing: ScrapedListing) -> str:
    suffix = listing.product_id or re.sub(r"\s+", "_", listing.product_name.strip().lower())
    return f"{listing.country_code}_{listing.store_id}_{suffix}"


def normalize_eu_listings(
    listings: list[ScrapedListing],
    *,
    currency_code: str = "EUR",
) -> NormalizationResult:
    normalized: list[StoreListing] = []
    warnings: list[str] = []

    for listing in listings:
        if not listing.product_name or listing.price <= 0 or not listing.category:
            warnings.append(
                f"invalid listing for {listing.store_id}: missing required product_name/category or non-positive price"
            )
            continue

        parsed_size = parse_size_text(listing.product_name)
        price_per_base_unit = None
        base_unit = parsed_size.base_unit
        base_quantity = parsed_size.base_quantity

        if parsed_size.base_quantity and parsed_size.base_quantity > 0:
            price_per_base_unit = round(listing.price / parsed_size.base_quantity, 2)
        else:
            unit_price_value, unit_price_unit = _parse_unit_price(listing.unit_price)
            if unit_price_value is not None:
                price_per_base_unit = unit_price_value
                base_unit = unit_price_unit

        normalized.append(
            StoreListing(
                id=_build_listing_id(listing),
                country_code=listing.country_code,
                store_id=listing.store_id,
                canonical_product_id=None,
                store_product_id=listing.product_id,
                product_url=listing.product_url,
                raw_title=listing.product_name,
                display_title=listing.product_name,
                brand=listing.brand,
                size_value=parsed_size.size_value,
                size_unit=parsed_size.size_unit,
                pack_count=parsed_size.pack_count,
                base_quantity=base_quantity,
                base_unit=base_unit,
                price=round(listing.price, 2),
                currency_code=currency_code,
                price_per_base_unit=price_per_base_unit,
                source_status="fresh",
            )
        )

    return NormalizationResult(listings=normalized, warnings=warnings)


def normalize_pt_listings(listings: list[ScrapedListing]) -> NormalizationResult:
    return normalize_eu_listings(listings, currency_code="EUR")


def normalize_es_listings(listings: list[ScrapedListing]) -> NormalizationResult:
    return normalize_eu_listings(listings, currency_code="EUR")
