import unittest

from scrapers.matcher import match_pt_store_listings
from scrapers.models import CanonicalProduct, StoreListing
from scrapers.reporting import build_matching_diagnostics_report


class MatchPTStoreListingsTest(unittest.TestCase):
    def test_matches_by_store_product_id_with_full_confidence(self):
        canonical = CanonicalProduct(
            id="PT_milk_semidesnatado_1l_generic",
            country_code="PT",
            category_id="milk",
            normalized_name="leite meio gordo uht",
            display_name="Leite Meio Gordo UHT 1L",
            size_value=1.0,
            size_unit="l",
            base_quantity=1.0,
            base_unit="l",
            source_product_ids={"continente": ("123",)},
        )
        listing = StoreListing(
            id="PT_continente_123",
            country_code="PT",
            store_id="continente",
            canonical_product_id=None,
            store_product_id="123",
            product_url=None,
            raw_title="Leite Meio Gordo UHT 1 L",
            display_title="Leite Meio Gordo UHT 1 L",
            brand="Continente",
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

        result = match_pt_store_listings([listing], [canonical])

        self.assertEqual(result.matched_count, 1)
        self.assertEqual(result.unmatched_count, 0)
        self.assertEqual(result.low_confidence_count, 0)
        self.assertEqual(result.listings[0].canonical_product_id, canonical.id)
        self.assertEqual(result.match_results[0].match_method, "store_product_id")
        self.assertEqual(result.match_results[0].match_confidence, 1.0)
        self.assertFalse(result.match_results[0].review_required)

    def test_manual_override_takes_precedence_over_heuristics(self):
        milk = CanonicalProduct(
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
        oat = CanonicalProduct(
            id="PT_oat_drink_1l_generic",
            country_code="PT",
            category_id="plant_milk",
            normalized_name="bebida aveia",
            display_name="Bebida de Aveia 1L",
            size_value=1.0,
            size_unit="l",
            base_quantity=1.0,
            base_unit="l",
        )
        listing = StoreListing(
            id="PT_continente_456",
            country_code="PT",
            store_id="continente",
            canonical_product_id=None,
            store_product_id="456",
            product_url=None,
            raw_title="Leite Meio Gordo UHT 1 L",
            display_title="Leite Meio Gordo UHT 1 L",
            brand="Continente",
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

        result = match_pt_store_listings(
            [listing],
            [milk, oat],
            override_mappings={"continente:456": oat.id},
        )

        self.assertEqual(result.matched_count, 1)
        self.assertEqual(result.listings[0].canonical_product_id, oat.id)
        self.assertEqual(result.match_results[0].match_method, "manual_override")
        self.assertEqual(result.match_results[0].match_confidence, 1.0)
        self.assertFalse(result.match_results[0].review_required)

    def test_matches_by_normalized_title_and_size(self):
        canonical = CanonicalProduct(
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
        listing = StoreListing(
            id="PT_pingo_doce_pd-123",
            country_code="PT",
            store_id="pingo_doce",
            canonical_product_id=None,
            store_product_id="pd-123",
            product_url=None,
            raw_title="Leite Meio Gordo UHT Mimosa 1 L",
            display_title="Leite Meio Gordo UHT Mimosa 1 L",
            brand="Mimosa",
            size_value=1.0,
            size_unit="l",
            pack_count=1,
            base_quantity=1.0,
            base_unit="l",
            price=0.95,
            currency_code="EUR",
            price_per_base_unit=0.95,
            source_status="fresh",
        )

        result = match_pt_store_listings([listing], [canonical])

        self.assertEqual(result.matched_count, 1)
        self.assertEqual(result.unmatched_count, 0)
        self.assertEqual(result.listings[0].canonical_product_id, canonical.id)
        self.assertEqual(result.match_results[0].match_method, "normalized_title")
        self.assertGreaterEqual(result.match_results[0].match_confidence, 0.9)
        self.assertFalse(result.match_results[0].review_required)

    def test_respects_configurable_review_thresholds(self):
        canonical = CanonicalProduct(
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
        listing = StoreListing(
            id="PT_auchan_au-123",
            country_code="PT",
            store_id="auchan",
            canonical_product_id=None,
            store_product_id="au-123",
            product_url=None,
            raw_title="Leite Meio 1 L",
            display_title="Leite Meio 1 L",
            brand=None,
            size_value=1.0,
            size_unit="l",
            pack_count=1,
            base_quantity=1.0,
            base_unit="l",
            price=0.99,
            currency_code="EUR",
            price_per_base_unit=0.99,
            source_status="fresh",
        )

        result = match_pt_store_listings([listing], [canonical], review_threshold=0.6)

        self.assertEqual(result.matched_count, 1)
        self.assertEqual(result.unmatched_count, 0)
        self.assertEqual(result.low_confidence_count, 0)
        self.assertFalse(result.match_results[0].review_required)


class MatchingDiagnosticsReportTest(unittest.TestCase):
    def test_reports_low_confidence_and_unmatched_by_store(self):
        canonical = CanonicalProduct(
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
        low_confidence_listing = StoreListing(
            id="PT_auchan_au-123",
            country_code="PT",
            store_id="auchan",
            canonical_product_id=None,
            store_product_id="au-123",
            product_url=None,
            raw_title="Leite Meio 1 L",
            display_title="Leite Meio 1 L",
            brand=None,
            size_value=1.0,
            size_unit="l",
            pack_count=1,
            base_quantity=1.0,
            base_unit="l",
            price=0.99,
            currency_code="EUR",
            price_per_base_unit=0.99,
            source_status="fresh",
        )
        unmatched_listing = StoreListing(
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

        matching = match_pt_store_listings([low_confidence_listing, unmatched_listing], [canonical])
        report = build_matching_diagnostics_report(
            matching,
            review_threshold=0.9,
            unmatched_warning_threshold=1,
            low_confidence_warning_threshold=1,
        )

        self.assertEqual(report.unmatched_by_store['auchan'], ['PT_auchan_au-123', 'PT_auchan_au-999'])
        self.assertEqual(report.low_confidence_listing_ids, ['PT_auchan_au-123'])
        self.assertTrue(any('unmatched threshold' in warning for warning in report.warnings))
        self.assertTrue(any('low-confidence threshold' in warning for warning in report.warnings))


if __name__ == "__main__":
    unittest.main()
