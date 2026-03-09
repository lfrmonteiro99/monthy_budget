"""Smoke validation helpers for grocery scraper adapters."""

from __future__ import annotations

from collections.abc import Iterable

from .base import ScrapedListing


class SmokeValidationError(ValueError):
    """Raised when a scraper fails the minimum smoke contract."""


def validate_smoke_listings(
    listings: Iterable[ScrapedListing],
    *,
    expected_country_code: str,
    expected_store_id: str,
) -> None:
    materialized = list(listings)
    if not materialized:
        raise SmokeValidationError("empty output")

    for index, listing in enumerate(materialized):
        if not isinstance(listing, ScrapedListing):
            raise SmokeValidationError(f"listing {index} is not a ScrapedListing")
        if listing.country_code != expected_country_code:
            raise SmokeValidationError(
                f"listing {index} has wrong country_code: {listing.country_code}"
            )
        if listing.store_id != expected_store_id:
            raise SmokeValidationError(
                f"listing {index} has wrong store_id: {listing.store_id}"
            )
        if not listing.store_name:
            raise SmokeValidationError(f"listing {index} is missing store_name")
        if not listing.product_name:
            raise SmokeValidationError(f"listing {index} is missing product_name")
        if not listing.category:
            raise SmokeValidationError(f"listing {index} is missing category")
        if listing.price <= 0:
            raise SmokeValidationError(f"listing {index} has invalid price: {listing.price}")
