"""Country/store pipeline helpers for reusable grocery workflow jobs."""

from __future__ import annotations

import json
from dataclasses import asdict
from datetime import datetime, timezone
from pathlib import Path

from .base import ScrapedListing, StoreScraper
from .models import ListingMatchResult, MatchingResult
from .normalizer import normalize_pt_listings
from .registry import get_store_scraper
from .status import build_store_status_summary

SOURCE_VERSION = "2.0.0"


def _store_artifact(
    *,
    scraper: StoreScraper,
    scraped_at: str,
    status: str,
    listings: list[ScrapedListing] | None = None,
    error: str | None = None,
) -> dict:
    payload = {
        "country_code": scraper.country_code,
        "store_id": scraper.store_id,
        "store_name": scraper.store_name,
        "status": status,
        "scraped_at": scraped_at,
        "listing_count": len(listings or []),
        "listings": [listing.to_dict() for listing in listings or []],
    }
    if error:
        payload["error"] = error
    return payload


def scrape_store(country_code: str, store_id: str) -> dict:
    scraper = get_store_scraper(country_code, store_id)
    scraped_at = datetime.now(timezone.utc).isoformat()
    try:
        listings = scraper.scrape()
        return _store_artifact(
            scraper=scraper,
            scraped_at=scraped_at,
            status="ok",
            listings=listings,
        )
    except Exception as exc:  # pragma: no cover - exercised by tests via patch
        return _store_artifact(
            scraper=scraper,
            scraped_at=scraped_at,
            status="error",
            error=str(exc),
        )


def _matching_result_for_normalized(artifact: dict, listing_ids: list[str]) -> MatchingResult:
    failed = artifact.get("status") == "error"
    return MatchingResult(
        listings=[],
        match_results=[
            ListingMatchResult(
                listing_id=listing_id,
                canonical_product_id=None,
                match_method="workflow_placeholder",
                match_confidence=0.0,
                review_required=False,
            )
            for listing_id in listing_ids
        ],
        matched_count=0 if failed else len(listing_ids),
        unmatched_count=0,
        low_confidence_count=0,
    )


def normalize_store_artifact(artifact: dict, run_id: str) -> tuple[dict, dict]:
    if artifact.get("status") == "error":
        matching_result = _matching_result_for_normalized(artifact, [])
        dataset_status, store_summary = build_store_status_summary(
            artifact=artifact,
            matching_result=matching_result,
            normalization_warnings=[],
            run_id=run_id,
            source_version=SOURCE_VERSION,
        )
        return (
            {
                "country_code": artifact["country_code"],
                "store_id": artifact["store_id"],
                "store_name": artifact["store_name"],
                "generated_at": artifact["scraped_at"],
                "warnings": [],
                "listings": [],
            },
            {
                "dataset_status": dataset_status.to_dict(),
                "store_summary": store_summary.to_dict(),
            },
        )

    listings = [
        ScrapedListing(**listing)
        for listing in artifact.get("listings", [])
    ]

    if artifact["country_code"] != "PT":
        raise ValueError(
            f"normalize_store_artifact only supports PT for now, got {artifact['country_code']}"
        )

    normalized_result = normalize_pt_listings(listings)
    matching_result = _matching_result_for_normalized(
        artifact,
        [listing.id for listing in normalized_result.listings],
    )
    dataset_status, store_summary = build_store_status_summary(
        artifact=artifact,
        matching_result=matching_result,
        normalization_warnings=normalized_result.warnings,
        run_id=run_id,
        source_version=SOURCE_VERSION,
    )
    normalized_payload = {
        "country_code": artifact["country_code"],
        "store_id": artifact["store_id"],
        "store_name": artifact["store_name"],
        "generated_at": artifact["scraped_at"],
        "warnings": normalized_result.warnings,
        "listings": [listing.to_dict() for listing in normalized_result.listings],
    }
    status_payload = {
        "dataset_status": dataset_status.to_dict(),
        "store_summary": store_summary.to_dict(),
    }
    return normalized_payload, status_payload


def write_store_outputs(
    *,
    country_code: str,
    store_id: str,
    output_root: Path,
    run_id: str,
) -> dict[str, Path]:
    artifact = scrape_store(country_code, store_id)
    normalized_payload, status_payload = normalize_store_artifact(artifact, run_id)

    target_dir = output_root / country_code.upper() / store_id.lower()
    target_dir.mkdir(parents=True, exist_ok=True)

    raw_path = target_dir / "raw.json"
    normalized_path = target_dir / "normalized.json"
    status_path = target_dir / "status.json"

    raw_path.write_text(json.dumps(artifact, ensure_ascii=False, indent=2), encoding="utf-8")
    normalized_path.write_text(
        json.dumps(normalized_payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    status_path.write_text(
        json.dumps(status_payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    return {
        "raw": raw_path,
        "normalized": normalized_path,
        "status": status_path,
    }


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(description="Write grocery scrape artifacts for one country/store")
    parser.add_argument("--country", required=True)
    parser.add_argument("--store", required=True)
    parser.add_argument("--output-root", type=Path, required=True)
    parser.add_argument("--run-id", required=False, default="local")
    args = parser.parse_args()

    write_store_outputs(
        country_code=args.country,
        store_id=args.store,
        output_root=args.output_root,
        run_id=args.run_id,
    )


if __name__ == "__main__":
    main()
