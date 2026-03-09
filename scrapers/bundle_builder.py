"""PT country bundle assembly helpers."""

from __future__ import annotations

import json
from pathlib import Path

from .models import CanonicalProduct, MatchingResult, ReportingResult, StoreDatasetStatus, StoreSummary


def build_pt_country_bundle(
    *,
    canonical_products: list[CanonicalProduct],
    matching_result: MatchingResult,
    store_statuses: list[StoreDatasetStatus],
    store_summaries: list[StoreSummary],
    reporting_result: ReportingResult,
    generated_at: str,
) -> dict:
    return {
        "country_code": "PT",
        "currency_code": "EUR",
        "generated_at": generated_at,
        "products": [product.to_dict() for product in canonical_products],
        "stores": [summary.to_dict() for summary in store_summaries],
        "listings": [listing.to_dict() for listing in matching_result.listings],
        "store_statuses": [status.to_dict() for status in store_statuses],
        "reporting": reporting_result.to_dict(),
    }



def write_pt_bundle_artifacts(
    *,
    output_dir: Path,
    canonical_products: list[CanonicalProduct],
    matching_result: MatchingResult,
    store_statuses: list[StoreDatasetStatus],
    store_summaries: list[StoreSummary],
    reporting_result: ReportingResult,
    generated_at: str,
) -> None:
    pt_dir = output_dir / "PT"
    stores_dir = pt_dir / "stores"
    stores_dir.mkdir(parents=True, exist_ok=True)

    bundle = build_pt_country_bundle(
        canonical_products=canonical_products,
        matching_result=matching_result,
        store_statuses=store_statuses,
        store_summaries=store_summaries,
        reporting_result=reporting_result,
        generated_at=generated_at,
    )

    catalog_payload = {
        "country_code": bundle["country_code"],
        "currency_code": bundle["currency_code"],
        "generated_at": bundle["generated_at"],
        "products": bundle["products"],
        "listings": bundle["listings"],
        "reporting": bundle["reporting"],
    }
    (pt_dir / "catalog.json").write_text(
        json.dumps(catalog_payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    store_summaries_payload = {
        "country_code": bundle["country_code"],
        "generated_at": bundle["generated_at"],
        "stores": bundle["stores"],
    }
    (pt_dir / "store_summaries.json").write_text(
        json.dumps(store_summaries_payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    listings_by_store: dict[str, list[dict]] = {}
    for listing in bundle["listings"]:
        listings_by_store.setdefault(listing["store_id"], []).append(listing)

    status_by_store = {status.store_id: status for status in store_statuses}
    for summary in store_summaries:
        store_dir = stores_dir / summary.store_id
        store_dir.mkdir(parents=True, exist_ok=True)

        normalized_payload = {
            "country_code": bundle["country_code"],
            "store_id": summary.store_id,
            "generated_at": bundle["generated_at"],
            "listings": listings_by_store.get(summary.store_id, []),
        }
        (store_dir / "normalized.json").write_text(
            json.dumps(normalized_payload, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )

        status = status_by_store[summary.store_id]
        (store_dir / "status.json").write_text(
            json.dumps(status.to_dict(), ensure_ascii=False, indent=2),
            encoding="utf-8",
        )
