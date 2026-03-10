"""Reporting helpers for grocery matching diagnostics and bundle quality."""

from __future__ import annotations

from collections import defaultdict

from .models import (
    CanonicalProduct,
    DuplicateCanonicalGroup,
    MatchingDiagnosticsReport,
    MatchingResult,
    ReportingResult,
    UnmatchedListingReport,
)


def _duplicate_signature(product: CanonicalProduct) -> str:
    brand = (product.brand or "").lower()
    size_value = "" if product.size_value is None else str(product.size_value)
    size_unit = product.size_unit or ""
    return "|".join(
        [
            product.country_code,
            product.normalized_name,
            size_value,
            size_unit,
            brand,
        ]
    )


def build_pt_reporting(
    *,
    canonical_products: list[CanonicalProduct],
    matching_result: MatchingResult,
    duplicate_threshold: int,
    unmatched_threshold: int,
) -> ReportingResult:
    grouped: dict[str, list[str]] = defaultdict(list)
    for product in canonical_products:
        grouped[_duplicate_signature(product)].append(product.id)

    duplicate_groups = [
        DuplicateCanonicalGroup(signature=signature, canonical_ids=sorted(ids))
        for signature, ids in grouped.items()
        if len(ids) > 1
    ]
    duplicate_groups.sort(key=lambda item: item.signature)

    unmatched_listings = [
        UnmatchedListingReport(
            listing_id=listing.id,
            store_id=listing.store_id,
            raw_title=listing.raw_title,
        )
        for listing in matching_result.listings
        if listing.canonical_product_id is None
    ]

    warnings: list[str] = []
    if len(duplicate_groups) > duplicate_threshold:
        warnings.append(
            f"duplicate canonical groups above threshold: {len(duplicate_groups)} > {duplicate_threshold}"
        )
    if len(unmatched_listings) > unmatched_threshold:
        warnings.append(
            f"unmatched listings above threshold: {len(unmatched_listings)} > {unmatched_threshold}"
        )

    return ReportingResult(
        duplicate_groups=duplicate_groups,
        unmatched_listings=unmatched_listings,
        warnings=warnings,
    )


def build_matching_diagnostics_report(
    matching: MatchingResult,
    *,
    review_threshold: float,
    unmatched_warning_threshold: int,
    low_confidence_warning_threshold: int,
) -> MatchingDiagnosticsReport:
    listing_by_id = {listing.id: listing for listing in matching.listings}
    unmatched_by_store: dict[str, list[str]] = defaultdict(list)
    low_confidence_listing_ids: list[str] = []
    warnings: list[str] = []

    for result in matching.match_results:
        listing = listing_by_id[result.listing_id]
        if result.review_required:
            low_confidence_listing_ids.append(result.listing_id)
        if result.canonical_product_id is None or result.review_required:
            unmatched_by_store[listing.store_id].append(result.listing_id)

    if matching.unmatched_count >= unmatched_warning_threshold:
        warnings.append(
            f"unmatched threshold reached: {matching.unmatched_count} >= {unmatched_warning_threshold}"
        )
    if matching.low_confidence_count >= low_confidence_warning_threshold:
        warnings.append(
            "low-confidence threshold reached: "
            f"{matching.low_confidence_count} >= {low_confidence_warning_threshold}"
        )
    if low_confidence_listing_ids:
        warnings.append(f"review threshold applied at confidence < {review_threshold:.2f}")

    return MatchingDiagnosticsReport(
        unmatched_by_store=dict(unmatched_by_store),
        low_confidence_listing_ids=low_confidence_listing_ids,
        warnings=warnings,
    )
