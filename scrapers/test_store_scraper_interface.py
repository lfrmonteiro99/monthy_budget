import unittest
from types import SimpleNamespace
from unittest.mock import patch

from scrapers.base import ScrapedListing
from scrapers.registry import FunctionStoreScraper, pt_store_scrapers


class ScrapedListingTest(unittest.TestCase):
    def test_to_legacy_product_keeps_expected_shape(self):
        listing = ScrapedListing(
            country_code="PT",
            store_id="continente",
            store_name="Continente",
            product_name="Leite Meio Gordo",
            price=0.89,
            category="Lacticinios e Ovos",
            product_id="123",
            unit_price="0.89/L",
            brand="Continente",
        )

        legacy = listing.to_legacy_product()

        self.assertEqual(legacy["name"], "Leite Meio Gordo")
        self.assertEqual(legacy["price"], 0.89)
        self.assertEqual(legacy["store"], "Continente")
        self.assertEqual(legacy["product_id"], "123")
        self.assertEqual(legacy["brand"], "Continente")


class FunctionStoreScraperTest(unittest.TestCase):
    def test_function_adapter_wraps_legacy_scraper_output(self):
        scraper = FunctionStoreScraper(
            country_code="PT",
            store_id="continente",
            store_name="Continente",
            scrape_fn=lambda: [
                {
                    "name": "Leite",
                    "price": 0.99,
                    "category": "Lacticinios e Ovos",
                    "product_id": "abc",
                }
            ],
        )

        listings = scraper.scrape()

        self.assertEqual(len(listings), 1)
        self.assertEqual(listings[0].country_code, "PT")
        self.assertEqual(listings[0].store_id, "continente")
        self.assertEqual(listings[0].product_name, "Leite")
        self.assertEqual(listings[0].price, 0.99)


class RegistryTest(unittest.TestCase):
    def test_pt_registry_exposes_expected_store_ids(self):
        fake_modules = {
            "scraper_continente": SimpleNamespace(scrape=lambda: []),
            "scraper_pingo_doce": SimpleNamespace(scrape=lambda: []),
            "scraper_auchan": SimpleNamespace(scrape=lambda: []),
        }
        with patch.dict("sys.modules", fake_modules):
            scrapers = pt_store_scrapers()

        self.assertEqual([scraper.store_id for scraper in scrapers], [
            "continente",
            "pingo_doce",
            "auchan",
        ])
        self.assertTrue(all(scraper.country_code == "PT" for scraper in scrapers))


if __name__ == "__main__":
    unittest.main()
