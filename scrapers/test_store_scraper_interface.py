import unittest
from types import SimpleNamespace
from unittest.mock import patch

from scrapers.base import ScrapedListing
from scrapers.registry import (
    FunctionStoreScraper,
    es_store_scrapers,
    pt_store_scrapers,
)
from scrapers.scraper_auchan import AuchanScraper
from scrapers.scraper_carrefour_es import CarrefourEsScraper
from scrapers.scraper_continente import ContinenteScraper
from scrapers.scraper_mercadona import MercadonaScraper
from scrapers.scraper_pingo_doce import PingoDoceScraper


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
        class FakeContinenteScraper:
            country_code = "PT"
            store_id = "continente"
            store_name = "Continente"

            def scrape(self):
                return []

        class FakePingoDoceScraper:
            country_code = "PT"
            store_id = "pingo_doce"
            store_name = "Pingo Doce"

            def scrape(self):
                return []

        class FakeAuchanScraper:
            country_code = "PT"
            store_id = "auchan"
            store_name = "Auchan"

            def scrape(self):
                return []

        fake_modules = {
            "scraper_continente": SimpleNamespace(
                scrape=lambda: [],
                ContinenteScraper=FakeContinenteScraper,
            ),
            "scraper_pingo_doce": SimpleNamespace(
                scrape=lambda: [],
                PingoDoceScraper=FakePingoDoceScraper,
            ),
            "scraper_auchan": SimpleNamespace(
                scrape=lambda: [],
                AuchanScraper=FakeAuchanScraper,
            ),
        }
        with patch.dict("sys.modules", fake_modules):
            scrapers = pt_store_scrapers()

        self.assertEqual([scraper.store_id for scraper in scrapers], [
            "continente",
            "pingo_doce",
            "auchan",
        ])
        self.assertTrue(all(scraper.country_code == "PT" for scraper in scrapers))

    def test_es_registry_exposes_expected_store_ids(self):
        class FakeMercadonaScraper:
            country_code = "ES"
            store_id = "mercadona"
            store_name = "Mercadona"

            def scrape(self):
                return []

        class FakeCarrefourEsScraper:
            country_code = "ES"
            store_id = "carrefour_es"
            store_name = "Carrefour"

            def scrape(self):
                return []

        fake_modules = {
            "scraper_mercadona": SimpleNamespace(
                MercadonaScraper=FakeMercadonaScraper,
            ),
            "scraper_carrefour_es": SimpleNamespace(
                CarrefourEsScraper=FakeCarrefourEsScraper,
            ),
        }
        with patch.dict("sys.modules", fake_modules):
            scrapers = es_store_scrapers()

        self.assertEqual([scraper.store_id for scraper in scrapers], [
            "mercadona",
            "carrefour_es",
        ])
        self.assertTrue(all(scraper.country_code == "ES" for scraper in scrapers))


class ContinenteScraperTest(unittest.TestCase):
    def test_continente_scraper_exposes_stable_identity(self):
        scraper = ContinenteScraper()

        self.assertEqual(scraper.country_code, "PT")
        self.assertEqual(scraper.store_id, "continente")
        self.assertEqual(scraper.store_name, "Continente")

    def test_continente_scraper_returns_scraped_listing_objects(self):
        scraper = ContinenteScraper()

        with patch(
            "scrapers.scraper_continente._fetch_category_products",
            return_value=[
                {
                    "name": "Leite Meio Gordo",
                    "price": 0.89,
                    "unit_price": "0.89/L",
                    "category": "Lacticinios e Ovos",
                    "product_id": "123",
                    "brand": "Continente",
                }
            ],
        ), patch("scrapers.scraper_continente.time.sleep"):
            listings = scraper.scrape()

        self.assertEqual(len(listings), len(scraper.categories))
        first = listings[0]
        self.assertIsInstance(first, ScrapedListing)
        self.assertEqual(first.country_code, "PT")
        self.assertEqual(first.store_id, "continente")
        self.assertEqual(first.store_name, "Continente")
        self.assertEqual(first.product_name, "Leite Meio Gordo")
        self.assertEqual(first.price, 0.89)


class PingoDoceScraperTest(unittest.TestCase):
    def test_pingo_doce_scraper_exposes_stable_identity(self):
        scraper = PingoDoceScraper()

        self.assertEqual(scraper.country_code, "PT")
        self.assertEqual(scraper.store_id, "pingo_doce")
        self.assertEqual(scraper.store_name, "Pingo Doce")

    def test_pingo_doce_scraper_returns_scraped_listing_objects(self):
        scraper = PingoDoceScraper()

        with patch(
            "scrapers.scraper_pingo_doce._fetch_category_products",
            return_value=[
                {
                    "name": "Iogurte Natural",
                    "price": 1.39,
                    "unit_price": "3.48/Kg",
                    "category": "Lacticinios e Ovos",
                    "product_id": "pd-123",
                    "brand": "Pingo Doce",
                }
            ],
        ), patch("scrapers.scraper_pingo_doce.time.sleep"):
            listings = scraper.scrape()

        self.assertEqual(len(listings), len(scraper.categories))
        first = listings[0]
        self.assertIsInstance(first, ScrapedListing)
        self.assertEqual(first.country_code, "PT")
        self.assertEqual(first.store_id, "pingo_doce")
        self.assertEqual(first.store_name, "Pingo Doce")
        self.assertEqual(first.product_name, "Iogurte Natural")
        self.assertEqual(first.price, 1.39)


class AuchanScraperTest(unittest.TestCase):
    def test_auchan_scraper_exposes_stable_identity(self):
        scraper = AuchanScraper()

        self.assertEqual(scraper.country_code, "PT")
        self.assertEqual(scraper.store_id, "auchan")
        self.assertEqual(scraper.store_name, "Auchan")

    def test_auchan_scraper_returns_scraped_listing_objects(self):
        scraper = AuchanScraper()

        with patch(
            "scrapers.scraper_auchan._fetch_category_products",
            return_value=[
                {
                    "name": "Pao de Forma",
                    "price": 1.99,
                    "unit_price": "4.98/Kg",
                    "category": "Padaria e Pastelaria",
                    "product_id": "au-123",
                    "brand": "Auchan",
                }
            ],
        ), patch("scrapers.scraper_auchan.time.sleep"):
            listings = scraper.scrape()

        self.assertEqual(len(listings), len(scraper.categories))
        first = listings[0]
        self.assertIsInstance(first, ScrapedListing)
        self.assertEqual(first.country_code, "PT")
        self.assertEqual(first.store_id, "auchan")
        self.assertEqual(first.store_name, "Auchan")
        self.assertEqual(first.product_name, "Pao de Forma")
        self.assertEqual(first.price, 1.99)


class MercadonaScraperTest(unittest.TestCase):
    def test_mercadona_scraper_exposes_stable_identity(self):
        scraper = MercadonaScraper()

        self.assertEqual(scraper.country_code, "ES")
        self.assertEqual(scraper.store_id, "mercadona")
        self.assertEqual(scraper.store_name, "Mercadona")

    def test_mercadona_scraper_returns_scraped_listing_objects(self):
        scraper = MercadonaScraper()

        with patch(
            "scrapers.scraper_mercadona._fetch_category_products",
            return_value=[
                {
                    "name": "Leche Entera",
                    "price": 1.05,
                    "unit_price": "1,05/L",
                    "category": "Lacteos y Huevos",
                    "product_id": "es-1",
                    "brand": "Hacendado",
                }
            ],
        ), patch("scrapers.scraper_mercadona.time.sleep"):
            listings = scraper.scrape()

        self.assertEqual(len(listings), len(scraper.categories))
        first = listings[0]
        self.assertIsInstance(first, ScrapedListing)
        self.assertEqual(first.country_code, "ES")
        self.assertEqual(first.store_id, "mercadona")
        self.assertEqual(first.store_name, "Mercadona")
        self.assertEqual(first.product_name, "Leche Entera")
        self.assertEqual(first.price, 1.05)


class CarrefourEsScraperTest(unittest.TestCase):
    def test_carrefour_es_scraper_exposes_stable_identity(self):
        scraper = CarrefourEsScraper()

        self.assertEqual(scraper.country_code, "ES")
        self.assertEqual(scraper.store_id, "carrefour_es")
        self.assertEqual(scraper.store_name, "Carrefour")

    def test_carrefour_es_scraper_returns_scraped_listing_objects(self):
        scraper = CarrefourEsScraper()

        with patch(
            "scrapers.scraper_carrefour_es._fetch_category_products",
            return_value=[
                {
                    "name": "Huevos Camperos",
                    "price": 2.49,
                    "unit_price": "4,98/Kg",
                    "category": "Lacteos y Huevos",
                    "product_id": "es-2",
                    "brand": "Carrefour",
                }
            ],
        ), patch("scrapers.scraper_carrefour_es.time.sleep"):
            listings = scraper.scrape()

        self.assertEqual(len(listings), len(scraper.categories))
        first = listings[0]
        self.assertIsInstance(first, ScrapedListing)
        self.assertEqual(first.country_code, "ES")
        self.assertEqual(first.store_id, "carrefour_es")
        self.assertEqual(first.store_name, "Carrefour")
        self.assertEqual(first.product_name, "Huevos Camperos")
        self.assertEqual(first.price, 2.49)


if __name__ == "__main__":
    unittest.main()

