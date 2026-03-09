import unittest

from scrapers.models import ListingMatchResult, MatchingResult, StoreDatasetStatus, StoreListing, StoreSummary
from scrapers.status import build_store_status_summary


class BuildStoreStatusSummaryTest(unittest.TestCase):
    def test_builds_success_status_and_summary(self):
        artifact = {
            "country_code": "PT",
            "store_id": "continente",
            "store_name": "Continente",
            "status": "ok",
            "scraped_at": "2026-03-09T10:00:00Z",
            "listing_count": 2,
            "listings": [],
        }
        matching = MatchingResult(
            listings=[
                StoreListing(
                    id="PT_continente_123",
                    country_code="PT",
                    store_id="continente",
                    canonical_product_id="PT_milk_1l",
                    store_product_id="123",
                    product_url=None,
                    raw_title="Leite Meio Gordo 1 L",
                    display_title="Leite Meio Gordo 1 L",
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
                ),
                StoreListing(
                    id="PT_continente_456",
                    country_code="PT",
                    store_id="continente",
                    canonical_product_id=None,
                    store_product_id="456",
                    product_url=None,
                    raw_title="Iogurte Natural",
                    display_title="Iogurte Natural",
                    brand=None,
                    size_value=None,
                    size_unit=None,
                    pack_count=None,
                    base_quantity=None,
                    base_unit=None,
                    price=1.49,
                    currency_code="EUR",
                    price_per_base_unit=None,
                    source_status="fresh",
                ),
            ],
            match_results=[
                ListingMatchResult(
                    listing_id="PT_continente_123",
                    canonical_product_id="PT_milk_1l",
                    match_method="store_product_id",
                    match_confidence=1.0,
                    review_required=False,
                ),
                ListingMatchResult(
                    listing_id="PT_continente_456",
                    canonical_product_id=None,
                    match_method="unmatched",
                    match_confidence=0.0,
                    review_required=False,
                ),
            ],
            matched_count=1,
            unmatched_count=1,
            low_confidence_count=0,
        )

        status, summary = build_store_status_summary(
            artifact=artifact,
            matching_result=matching,
            normalization_warnings=["unit parsing fallback used"],
            run_id="run-123",
            source_version="1.0.0",
        )

        self.assertIsInstance(status, StoreDatasetStatus)
        self.assertEqual(status.country_code, "PT")
        self.assertEqual(status.store_id, "continente")
        self.assertEqual(status.run_id, "run-123")
        self.assertEqual(status.last_updated_at, "2026-03-09T10:00:00Z")
        self.assertEqual(status.scrape_status, "partial")
        self.assertEqual(status.listing_count, 2)
        self.assertEqual(status.matched_count, 1)
        self.assertEqual(status.unmatched_count, 1)
        self.assertEqual(status.validation_warnings, ["unit parsing fallback used"])
        self.assertEqual(status.source_version, "1.0.0")

        self.assertIsInstance(summary, StoreSummary)
        self.assertEqual(summary.store_id, "continente")
        self.assertEqual(summary.display_name, "Continente")
        self.assertEqual(summary.last_updated_at, "2026-03-09T10:00:00Z")
        self.assertEqual(summary.status, "partial")
        self.assertEqual(summary.listing_count, 2)

    def test_failed_artifact_stays_failed_and_preserves_error_warning(self):
        artifact = {
            "country_code": "PT",
            "store_id": "auchan",
            "store_name": "Auchan",
            "status": "error",
            "scraped_at": "2026-03-09T10:00:00Z",
            "listing_count": 0,
            "listings": [],
            "error": "timeout",
        }
        matching = MatchingResult(
            listings=[],
            match_results=[],
            matched_count=0,
            unmatched_count=0,
            low_confidence_count=0,
        )

        status, summary = build_store_status_summary(
            artifact=artifact,
            matching_result=matching,
            normalization_warnings=[],
            run_id="run-999",
        )

        self.assertEqual(status.scrape_status, "failed")
        self.assertIn("timeout", status.validation_warnings[0])
        self.assertEqual(status.listing_count, 0)
        self.assertEqual(summary.status, "failed")
        self.assertEqual(summary.listing_count, 0)


if __name__ == "__main__":
    unittest.main()
