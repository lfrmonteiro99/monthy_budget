import unittest

from scrapers.base import ScrapedListing
from scrapers.normalizer import (
    normalize_es_listings,
    normalize_pt_listings,
    parse_size_text,
)


class ParseSizeTextTest(unittest.TestCase):
    def test_parse_size_text_from_title_volume(self):
        parsed = parse_size_text("Leite Meio Gordo UHT 1 L")

        self.assertEqual(parsed.size_value, 1.0)
        self.assertEqual(parsed.size_unit, "l")
        self.assertEqual(parsed.pack_count, 1)
        self.assertEqual(parsed.base_quantity, 1.0)
        self.assertEqual(parsed.base_unit, "l")

    def test_parse_size_text_from_multipack(self):
        parsed = parse_size_text("Cerveja Lager 6x33 cl")

        self.assertEqual(parsed.size_value, 33.0)
        self.assertEqual(parsed.size_unit, "cl")
        self.assertEqual(parsed.pack_count, 6)
        self.assertEqual(parsed.base_quantity, 1.98)
        self.assertEqual(parsed.base_unit, "l")


class NormalizePTListingsTest(unittest.TestCase):
    def test_normalize_pt_listings_builds_store_listing(self):
        listing = ScrapedListing(
            country_code="PT",
            store_id="continente",
            store_name="Continente",
            product_name="Leite Meio Gordo UHT 1 L",
            price=0.89,
            category="Lacticinios e Ovos",
            product_id="123",
            unit_price="0,89 /L",
            brand="Continente",
            product_url="https://example.com/leite",
        )

        result = normalize_pt_listings([listing])

        self.assertEqual(result.warnings, [])
        self.assertEqual(len(result.listings), 1)

        normalized = result.listings[0]
        self.assertEqual(normalized.id, "PT_continente_123")
        self.assertEqual(normalized.country_code, "PT")
        self.assertEqual(normalized.store_id, "continente")
        self.assertEqual(normalized.store_product_id, "123")
        self.assertEqual(normalized.raw_title, "Leite Meio Gordo UHT 1 L")
        self.assertEqual(normalized.display_title, "Leite Meio Gordo UHT 1 L")
        self.assertEqual(normalized.brand, "Continente")
        self.assertEqual(normalized.size_value, 1.0)
        self.assertEqual(normalized.size_unit, "l")
        self.assertEqual(normalized.pack_count, 1)
        self.assertEqual(normalized.base_quantity, 1.0)
        self.assertEqual(normalized.base_unit, "l")
        self.assertEqual(normalized.price, 0.89)
        self.assertEqual(normalized.currency_code, "EUR")
        self.assertEqual(normalized.price_per_base_unit, 0.89)
        self.assertEqual(normalized.source_status, "fresh")

    def test_normalize_pt_listings_uses_unit_price_when_title_has_no_size(self):
        listing = ScrapedListing(
            country_code="PT",
            store_id="pingo_doce",
            store_name="Pingo Doce",
            product_name="Arroz Carolino",
            price=2.79,
            category="Mercearia",
            product_id="pd-456",
            unit_price="2,79 /Kg",
        )

        result = normalize_pt_listings([listing])

        self.assertEqual(result.warnings, [])
        normalized = result.listings[0]
        self.assertIsNone(normalized.size_value)
        self.assertIsNone(normalized.size_unit)
        self.assertIsNone(normalized.pack_count)
        self.assertIsNone(normalized.base_quantity)
        self.assertEqual(normalized.base_unit, "kg")
        self.assertEqual(normalized.price_per_base_unit, 2.79)

    def test_normalize_pt_listings_warns_and_skips_invalid_records(self):
        bad = ScrapedListing(
            country_code="PT",
            store_id="auchan",
            store_name="Auchan",
            product_name="",
            price=0,
            category="Mercearia",
            product_id="",
        )

        result = normalize_pt_listings([bad])

        self.assertEqual(result.listings, [])
        self.assertEqual(len(result.warnings), 1)
        self.assertIn("invalid listing", result.warnings[0])


class NormalizeESListingsTest(unittest.TestCase):
    def test_normalize_es_listings_supports_spanish_titles(self):
        listing = ScrapedListing(
            country_code="ES",
            store_id="mercadona",
            store_name="Mercadona",
            product_name="Leche Entera 6x1 L",
            price=5.34,
            category="Lacteos y Huevos",
            product_id="es-123",
            unit_price="0,89 /L",
        )

        result = normalize_es_listings([listing])

        self.assertEqual(result.warnings, [])
        normalized = result.listings[0]
        self.assertEqual(normalized.country_code, "ES")
        self.assertEqual(normalized.store_id, "mercadona")
        self.assertEqual(normalized.pack_count, 6)
        self.assertEqual(normalized.base_quantity, 6.0)
        self.assertEqual(normalized.base_unit, "l")
        self.assertEqual(normalized.currency_code, "EUR")


if __name__ == "__main__":
    unittest.main()
