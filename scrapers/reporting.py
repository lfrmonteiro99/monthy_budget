"""Reporting helpers for grocery matching diagnostics."""

from __future__ import annotations

from collections import defaultdict

from .models import MatchingDiagnosticsReport, MatchingResult


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
