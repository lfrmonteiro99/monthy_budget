import json
import tempfile
import unittest
from pathlib import Path

from scrapers.bundle_builder import build_pt_country_bundle, write_pt_bundle_artifacts
from scrapers.models import (
    CanonicalProduct,
    MatchingResult,
    ReportingResult,
    StoreDatasetStatus,
    StoreListing,
    StoreSummary,
)


class BuildPTCountryBundleTest(unittest.TestCase):
    def test_builds_country_bundle_shape(self):
        canonical_products = [
            CanonicalProduct(
                id="PT_milk_semidesnatado_1l_generic",
                country_code="PT",
                category_id="milk",
                normalized_name="leite meio gordo uht",
                display_name="Leite Meio Gordo UHT 1L",
                size_value=1.0,
                size_unit="l",
                base_quantity=1.0,
                base_unit="l",
            )
        ]
        matching_result = MatchingResult(
            listings=[
                StoreListing(
                    id="PT_continente_123",
                    country_code="PT",
                    store_id="continente",
                    canonical_product_id="PT_milk_semidesnatado_1l_generic",
                    store_product_id="123",
                    product_url=None,
                    raw_title="Leite Meio Gordo UHT 1 L",
                    display_title="Leite Meio Gordo UHT 1 L",
                    brand=None,
                    size_value=1.0,
                    size_unit="l",
                    pack_count=1,
                    base_quantity=1.0,
                    base_unit="l",
                    price=0.89,
                    currency_code="EUR",
                    price_per_base_unit=0.89,
                    source_status="fresh",
                )
            ],
            match_results=[],
            matched_count=1,
            unmatched_count=0,
            low_confidence_count=0,
        )
        statuses = [
            StoreDatasetStatus(
                country_code="PT",
                store_id="continente",
                run_id="run-123",
                last_updated_at="2026-03-09T10:00:00Z",
                scrape_status="success",
                listing_count=1,
                matched_count=1,
                unmatched_count=0,
                validation_warnings=[],
                source_version="1.0.0",
            )
        ]
        summaries = [
            StoreSummary(
                store_id="continente",
                display_name="Continente",
                last_updated_at="2026-03-09T10:00:00Z",
                status="fresh",
                listing_count=1,
            )
        ]
        reporting = ReportingResult(
            duplicate_groups=[],
            unmatched_listings=[],
            warnings=[],
        )

        bundle = build_pt_country_bundle(
            canonical_products=canonical_products,
            matching_result=matching_result,
            store_statuses=statuses,
            store_summaries=summaries,
            reporting_result=reporting,
            generated_at="2026-03-09T10:00:00Z",
        )

        self.assertEqual(bundle["country_code"], "PT")
        self.assertEqual(bundle["currency_code"], "EUR")
        self.assertEqual(bundle["generated_at"], "2026-03-09T10:00:00Z")
        self.assertEqual(len(bundle["products"]), 1)
        self.assertEqual(len(bundle["stores"]), 1)
        self.assertEqual(len(bundle["listings"]), 1)
        self.assertIn("reporting", bundle)

    def test_writes_agreed_artifact_structure(self):
        canonical_products = [
            CanonicalProduct(
                id="PT_milk_semidesnatado_1l_generic",
                country_code="PT",
                category_id="milk",
                normalized_name="leite meio gordo uht",
                display_name="Leite Meio Gordo UHT 1L",
                size_value=1.0,
                size_unit="l",
                base_quantity=1.0,
                base_unit="l",
            )
        ]
        matching_result = MatchingResult(
            listings=[
                StoreListing(
                    id="PT_continente_123",
                    country_code="PT",
                    store_id="continente",
                    canonical_product_id="PT_milk_semidesnatado_1l_generic",
                    store_product_id="123",
                    product_url=None,
                    raw_title="Leite Meio Gordo UHT 1 L",
                    display_title="Leite Meio Gordo UHT 1 L",
                    brand=None,
                    size_value=1.0,
                    size_unit="l",
                    pack_count=1,
                    base_quantity=1.0,
                    base_unit="l",
                    price=0.89,
                    currency_code="EUR",
                    price_per_base_unit=0.89,
                    source_status="fresh",
                )
            ],
            match_results=[],
            matched_count=1,
            unmatched_count=0,
            low_confidence_count=0,
        )
        statuses = [
            StoreDatasetStatus(
                country_code="PT",
                store_id="continente",
                run_id="run-123",
                last_updated_at="2026-03-09T10:00:00Z",
                scrape_status="success",
                listing_count=1,
                matched_count=1,
                unmatched_count=0,
                validation_warnings=[],
                source_version="1.0.0",
            )
        ]
        summaries = [
            StoreSummary(
                store_id="continente",
                display_name="Continente",
                last_updated_at="2026-03-09T10:00:00Z",
                status="fresh",
                listing_count=1,
            )
        ]
        reporting = ReportingResult(
            duplicate_groups=[],
            unmatched_listings=[],
            warnings=[],
        )

        with tempfile.TemporaryDirectory() as tmpdir:
            output_dir = Path(tmpdir)
            write_pt_bundle_artifacts(
                output_dir=output_dir,
                canonical_products=canonical_products,
                matching_result=matching_result,
                store_statuses=statuses,
                store_summaries=summaries,
                reporting_result=reporting,
                generated_at="2026-03-09T10:00:00Z",
            )

            catalog = json.loads((output_dir / "PT" / "catalog.json").read_text(encoding="utf-8"))
            summaries_payload = json.loads((output_dir / "PT" / "store_summaries.json").read_text(encoding="utf-8"))
            normalized = json.loads((output_dir / "PT" / "stores" / "continente" / "normalized.json").read_text(encoding="utf-8"))
            status = json.loads((output_dir / "PT" / "stores" / "continente" / "status.json").read_text(encoding="utf-8"))

        self.assertEqual(catalog["country_code"], "PT")
        self.assertEqual(len(catalog["products"]), 1)
        self.assertEqual(len(catalog["listings"]), 1)
        self.assertEqual(len(summaries_payload["stores"]), 1)
        self.assertEqual(normalized["store_id"], "continente")
        self.assertEqual(len(normalized["listings"]), 1)
        self.assertEqual(status["store_id"], "continente")
        self.assertEqual(status["scrape_status"], "success")


if __name__ == "__main__":
    unittest.main()
