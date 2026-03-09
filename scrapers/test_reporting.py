import unittest

from scrapers.models import CanonicalProduct, ListingMatchResult, MatchingResult, StoreListing
from scrapers.reporting import build_pt_reporting


class BuildPTReportingTest(unittest.TestCase):
    def test_reports_duplicate_canonical_products_and_unmatched_listings(self):
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
                brand=None,
            ),
            CanonicalProduct(
                id="PT_milk_semidesnatado_1l_storebrand",
                country_code="PT",
                category_id="milk",
                normalized_name="leite meio gordo uht",
                display_name="Leite Meio Gordo UHT 1L",
                size_value=1.0,
                size_unit="l",
                base_quantity=1.0,
                base_unit="l",
                brand=None,
            ),
        ]
        matching = MatchingResult(
            listings=[
                StoreListing(
                    id="PT_auchan_au-999",
                    country_code="PT",
                    store_id="auchan",
                    canonical_product_id=None,
                    store_product_id="au-999",
                    product_url=None,
                    raw_title="Bolo de Chocolate 500 g",
                    display_title="Bolo de Chocolate 500 g",
                    brand=None,
                    size_value=500,
                    size_unit="g",
                    pack_count=1,
                    base_quantity=0.5,
                    base_unit="kg",
                    price=3.49,
                    currency_code="EUR",
                    price_per_base_unit=6.98,
                    source_status="fresh",
                )
            ],
            match_results=[
                ListingMatchResult(
                    listing_id="PT_auchan_au-999",
                    canonical_product_id=None,
                    match_method="unmatched",
                    match_confidence=0.0,
                    review_required=False,
                )
            ],
            matched_count=0,
            unmatched_count=1,
            low_confidence_count=0,
        )

        report = build_pt_reporting(
            canonical_products=canonical_products,
            matching_result=matching,
            duplicate_threshold=0,
            unmatched_threshold=0,
        )

        self.assertEqual(len(report.duplicate_groups), 1)
        self.assertEqual(report.duplicate_groups[0].canonical_ids, [
            "PT_milk_semidesnatado_1l_generic",
            "PT_milk_semidesnatado_1l_storebrand",
        ])
        self.assertEqual(len(report.unmatched_listings), 1)
        self.assertEqual(report.unmatched_listings[0].listing_id, "PT_auchan_au-999")
        self.assertEqual(report.unmatched_listings[0].store_id, "auchan")
        self.assertEqual(report.unmatched_listings[0].raw_title, "Bolo de Chocolate 500 g")
        self.assertGreaterEqual(len(report.warnings), 2)

    def test_does_not_emit_threshold_warnings_when_below_limits(self):
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
        matching = MatchingResult(
            listings=[],
            match_results=[],
            matched_count=1,
            unmatched_count=0,
            low_confidence_count=0,
        )

        report = build_pt_reporting(
            canonical_products=canonical_products,
            matching_result=matching,
            duplicate_threshold=1,
            unmatched_threshold=1,
        )

        self.assertEqual(report.duplicate_groups, [])
        self.assertEqual(report.unmatched_listings, [])
        self.assertEqual(report.warnings, [])


if __name__ == "__main__":
    unittest.main()
