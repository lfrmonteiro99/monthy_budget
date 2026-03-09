"""Validate generated grocery country bundles for workflow use."""

from __future__ import annotations

import json
from pathlib import Path


def validate_country_bundle(*, country_code: str, input_root: Path) -> dict:
    normalized_country = country_code.upper()
    country_dir = input_root / normalized_country
    catalog_path = country_dir / "catalog.json"
    summaries_path = country_dir / "store_summaries.json"

    errors: list[str] = []
    warnings: list[str] = []

    if not catalog_path.exists():
        errors.append(f"missing catalog.json for {normalized_country}")
        return {"errors": errors, "warnings": warnings}
    if not summaries_path.exists():
        errors.append(f"missing store_summaries.json for {normalized_country}")
        return {"errors": errors, "warnings": warnings}

    catalog = json.loads(catalog_path.read_text(encoding="utf-8"))
    summaries = json.loads(summaries_path.read_text(encoding="utf-8"))

    if not summaries:
        errors.append(f"no store summaries for {normalized_country}")
    if not catalog.get("stores"):
        errors.append(f"no stores in catalog for {normalized_country}")
    if not catalog.get("listings"):
        warnings.append(f"no listings in catalog for {normalized_country}")

    fresh = [summary for summary in summaries if summary.get("status") == "fresh"]
    partial = [summary for summary in summaries if summary.get("status") == "partial"]
    failed = [summary for summary in summaries if summary.get("status") == "failed"]

    if not fresh and not partial:
        errors.append(f"all stores failed for {normalized_country}")
    if failed:
        warnings.append(
            f"{len(failed)} store(s) failed for {normalized_country}: "
            + ", ".join(summary.get("store_id", "?") for summary in failed)
        )
    if partial:
        warnings.append(
            f"{len(partial)} store(s) partial for {normalized_country}: "
            + ", ".join(summary.get("store_id", "?") for summary in partial)
        )

    return {
        "errors": errors,
        "warnings": warnings,
        "fresh_count": len(fresh),
        "partial_count": len(partial),
        "failed_count": len(failed),
        "listing_count": len(catalog.get("listings", [])),
    }


def main() -> None:
    import argparse
    import sys

    parser = argparse.ArgumentParser(description="Validate one country grocery bundle")
    parser.add_argument("--country", required=True)
    parser.add_argument("--input-root", type=Path, required=True)
    args = parser.parse_args()

    result = validate_country_bundle(
        country_code=args.country,
        input_root=args.input_root,
    )
    print(json.dumps(result, ensure_ascii=False, indent=2))
    if result["errors"]:
        sys.exit(1)


if __name__ == "__main__":
    main()
