"""Build app-facing country bundles from per-store workflow artifacts."""

from __future__ import annotations

import json
import re
import unicodedata
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

try:
    from run_scrapers import _build_category_summary, _build_comparison_index, _normalize_products
except ImportError:
    from .run_scrapers import _build_category_summary, _build_comparison_index, _normalize_products


def _strip_accents(value: str) -> str:
    normalized = unicodedata.normalize("NFD", value)
    return "".join(char for char in normalized if unicodedata.category(char) != "Mn")


def _normalize_key(title: str) -> str:
    value = _strip_accents(title.lower())
    value = re.sub(r"[^a-z0-9\s]", " ", value)
    value = re.sub(r"\s+", " ", value).strip()
    return value


def _load_json(path: Path) -> dict:
    return json.loads(path.read_text(encoding="utf-8"))


def _collect_store_artifacts(country_dir: Path) -> list[tuple[dict, dict, dict]]:
    collected: list[tuple[dict, dict, dict]] = []
    if not country_dir.exists():
        return collected
    for store_dir in sorted(path for path in country_dir.iterdir() if path.is_dir()):
        raw_path = store_dir / "raw.json"
        normalized_path = store_dir / "normalized.json"
        status_path = store_dir / "status.json"
        if not raw_path.exists() or not normalized_path.exists() or not status_path.exists():
            continue
        collected.append(
            (
                _load_json(raw_path),
                _load_json(normalized_path),
                _load_json(status_path),
            )
        )
    return collected


def _canonicalize_products(
    normalized_payloads: list[dict],
    raw_payloads: list[dict],
) -> tuple[list[dict], list[dict]]:
    canonical_products: dict[str, dict] = {}
    listings: list[dict] = []
    raw_meta = {
        (raw["store_id"], item.get("product_id", "")): item
        for raw in raw_payloads
        for item in raw.get("listings", [])
    }

    for normalized in normalized_payloads:
        for listing in normalized.get("listings", []):
            base_quantity = listing.get("base_quantity")
            base_unit = listing.get("base_unit")
            normalized_name = _normalize_key(listing.get("display_title", ""))
            product_key = "|".join(
                [
                    listing["country_code"],
                    normalized_name,
                    "" if base_quantity is None else str(base_quantity),
                    base_unit or "",
                    (listing.get("brand") or "").lower(),
                ]
            )
            canonical_id = canonical_products.get(product_key, {}).get("id")
            if canonical_id is None:
                source_raw = raw_meta.get(
                    (listing["store_id"], listing.get("store_product_id", "")),
                    {},
                )
                canonical_id = f"{listing['country_code'].lower()}_{len(canonical_products) + 1}"
                canonical_products[product_key] = {
                    "id": canonical_id,
                    "display_name": listing["display_title"],
                    "normalized_name": normalized_name,
                    "category": source_raw.get("category", "Outros"),
                    "brand": listing.get("brand") or source_raw.get("brand"),
                    "size_unit": listing.get("size_unit") or base_unit,
                    "base_unit": base_unit,
                    "base_quantity": base_quantity,
                }

            source_raw = raw_meta.get(
                (listing["store_id"], listing.get("store_product_id", "")),
                {},
            )
            listings.append(
                {
                    "canonical_product_id": canonical_id,
                    "product_name": listing["display_title"],
                    "store_id": listing["store_id"],
                    "price": listing["price"],
                    "price_per_base_unit": listing.get("price_per_base_unit"),
                    "base_unit": base_unit,
                    "brand": listing.get("brand") or source_raw.get("brand"),
                    "category": source_raw.get("category", "Outros"),
                }
            )

    return list(canonical_products.values()), listings


def build_country_bundle(
    *,
    country_code: str,
    input_root: Path,
    output_root: Path,
    legacy_output_path: Path | None = None,
) -> dict:
    normalized_country = country_code.upper()
    source_dir = input_root / normalized_country
    store_sets = _collect_store_artifacts(source_dir)
    raw_payloads = [item[0] for item in store_sets]
    normalized_payloads = [item[1] for item in store_sets]
    status_payloads = [item[2] for item in store_sets]

    canonical_products, bundle_listings = _canonicalize_products(
        normalized_payloads,
        raw_payloads,
    )
    stores = [
        {
            "store_id": raw["store_id"],
            "store_name": raw["store_name"],
        }
        for raw in raw_payloads
    ]
    store_summaries = [
        {
            "store_id": payload["store_summary"]["store_id"],
            "store_name": payload["store_summary"].get(
                "display_name",
                payload["store_summary"]["store_id"],
            ),
            "display_name": payload["store_summary"].get(
                "display_name",
                payload["store_summary"]["store_id"],
            ),
            "last_updated_at": payload["store_summary"].get("last_updated_at"),
            "status": payload["store_summary"]["status"],
            "listing_count": payload["store_summary"]["listing_count"],
        }
        for payload in status_payloads
    ]

    generated_at = datetime.now(timezone.utc).isoformat()
    output_dir = output_root / normalized_country
    stores_dir = output_dir / "stores"
    stores_dir.mkdir(parents=True, exist_ok=True)

    catalog_payload = {
        "country_code": normalized_country,
        "currency_code": "EUR",
        "generated_at": generated_at,
        "products": canonical_products,
        "stores": stores,
        "listings": bundle_listings,
        "store_statuses": store_summaries,
    }

    (output_dir / "catalog.json").write_text(
        json.dumps(catalog_payload, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    (output_dir / "store_summaries.json").write_text(
        json.dumps(store_summaries, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )

    for normalized in normalized_payloads:
        (stores_dir / f"{normalized['store_id']}.json").write_text(
            json.dumps(normalized, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )

    if legacy_output_path is not None and normalized_country == "PT":
        legacy_products = []
        scraper_results = {}
        store_artifacts = []
        for raw in raw_payloads:
            store_artifacts.append(raw)
            scraper_results[raw["store_name"]] = {
                "status": raw["status"],
                "count": raw["listing_count"],
                "country_code": raw["country_code"],
                "store_id": raw["store_id"],
                **({"error": raw["error"]} if "error" in raw else {}),
            }
            legacy_products.extend(
                ScrapedListing_legacy_product(raw_listing, raw["store_name"])
                for raw_listing in raw.get("listings", [])
            )

        legacy_products = _normalize_products(legacy_products)
        legacy_payload = {
            "metadata": {
                "scraped_at": generated_at,
                "scraper_version": "2.0.0",
                "scraper_results": scraper_results,
                "total_products": len(legacy_products),
                "total_comparisons": len(_build_comparison_index(legacy_products)),
            },
            "store_artifacts": store_artifacts,
            "deco_index": {},
            "products": legacy_products,
            "comparisons": _build_comparison_index(legacy_products),
            "category_summary": _build_category_summary(legacy_products),
            "open_prices": [],
            "nutrition": {},
        }
        legacy_output_path.parent.mkdir(parents=True, exist_ok=True)
        legacy_output_path.write_text(
            json.dumps(legacy_payload, ensure_ascii=False, indent=2),
            encoding="utf-8",
        )

    return catalog_payload


def ScrapedListing_legacy_product(raw_listing: dict, store_name: str) -> dict:
    payload = {
        "name": raw_listing.get("product_name", ""),
        "price": raw_listing.get("price", 0),
        "unit_price": raw_listing.get("unit_price"),
        "category": raw_listing.get("category", ""),
        "product_id": raw_listing.get("product_id", ""),
        "store": store_name,
    }
    if raw_listing.get("brand"):
        payload["brand"] = raw_listing["brand"]
    return payload


def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(description="Build one country grocery bundle from store artifacts")
    parser.add_argument("--country", required=True)
    parser.add_argument("--input-root", type=Path, required=True)
    parser.add_argument("--output-root", type=Path, required=True)
    parser.add_argument("--legacy-output", type=Path)
    args = parser.parse_args()

    build_country_bundle(
        country_code=args.country,
        input_root=args.input_root,
        output_root=args.output_root,
        legacy_output_path=args.legacy_output,
    )


if __name__ == "__main__":
    main()
