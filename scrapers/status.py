"""Store freshness and status summaries for PT grocery outputs."""

from __future__ import annotations

from .models import MatchingResult, StoreDatasetStatus, StoreSummary


def build_store_status_summary(
    *,
    artifact: dict,
    matching_result: MatchingResult,
    normalization_warnings: list[str],
    run_id: str,
    source_version: str | None = None,
) -> tuple[StoreDatasetStatus, StoreSummary]:
    warnings = list(normalization_warnings)
    if artifact.get("error"):
        warnings.insert(0, f"scrape error: {artifact['error']}")

    if artifact.get("status") == "error":
        scrape_status = "failed"
    elif matching_result.unmatched_count > 0 or warnings:
        scrape_status = "partial"
    else:
        scrape_status = "success"

    status = StoreDatasetStatus(
        country_code=artifact["country_code"],
        store_id=artifact["store_id"],
        run_id=run_id,
        last_updated_at=artifact["scraped_at"],
        scrape_status=scrape_status,
        listing_count=artifact["listing_count"],
        matched_count=matching_result.matched_count,
        unmatched_count=matching_result.unmatched_count,
        validation_warnings=warnings,
        source_version=source_version,
    )

    summary_status = {
        "success": "fresh",
        "partial": "partial",
        "failed": "failed",
    }[scrape_status]
    summary = StoreSummary(
        store_id=artifact["store_id"],
        display_name=artifact["store_name"],
        last_updated_at=artifact["scraped_at"],
        status=summary_status,
        listing_count=artifact["listing_count"],
    )

    return status, summary
