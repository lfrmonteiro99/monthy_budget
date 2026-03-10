import unittest
from unittest.mock import patch

from scrapers.base import ScrapedListing
from scrapers.registry import pt_store_scrapers
from scrapers.smoke import SmokeValidationError, validate_smoke_listings


class SmokeValidationTest(unittest.TestCase):
    def test_validate_smoke_listings_accepts_valid_output(self):
        listings = [
            ScrapedListing(
                country_code="PT",
                store_id="continente",
                store_name="Continente",
                product_name="Leite Meio Gordo",
                price=0.89,
                category="Lacticinios e Ovos",
            )
        ]

        validate_smoke_listings(listings, expected_country_code="PT", expected_store_id="continente")

    def test_validate_smoke_listings_rejects_empty_output(self):
        with self.assertRaisesRegex(SmokeValidationError, "empty output"):
            validate_smoke_listings([], expected_country_code="PT", expected_store_id="continente")

    def test_validate_smoke_listings_rejects_malformed_output(self):
        with self.assertRaisesRegex(SmokeValidationError, "product_name"):
            validate_smoke_listings(
                [
                    ScrapedListing(
                        country_code="PT",
                        store_id="continente",
                        store_name="Continente",
                        product_name="",
                        price=0.89,
                        category="Lacticinios e Ovos",
                    )
                ],
                expected_country_code="PT",
                expected_store_id="continente",
            )


class PTScraperSmokeTest(unittest.TestCase):
    def test_pt_scrapers_pass_smoke_validation(self):
        fixture_products = {
            "continente": {
                "name": "Leite Meio Gordo",
                "price": 0.89,
                "unit_price": "0.89/L",
                "category": "Lacticinios e Ovos",
                "product_id": "ct-123",
                "brand": "Continente",
            },
            "pingo_doce": {
                "name": "Iogurte Natural",
                "price": 1.39,
                "unit_price": "3.48/Kg",
                "category": "Lacticinios e Ovos",
                "product_id": "pd-123",
                "brand": "Pingo Doce",
            },
            "auchan": {
                "name": "Pao de Forma",
                "price": 1.99,
                "unit_price": "4.98/Kg",
                "category": "Padaria e Pastelaria",
                "product_id": "au-123",
                "brand": "Auchan",
            },
        }

        with patch("scrapers.scraper_continente._fetch_category_products", return_value=[fixture_products["continente"]]), \
            patch("scrapers.scraper_pingo_doce._fetch_category_products", return_value=[fixture_products["pingo_doce"]]), \
            patch("scrapers.scraper_auchan._fetch_category_products", return_value=[fixture_products["auchan"]]), \
            patch("scrapers.scraper_continente.time.sleep"), \
            patch("scrapers.scraper_pingo_doce.time.sleep"), \
            patch("scrapers.scraper_auchan.time.sleep"):
            for scraper in pt_store_scrapers():
                listings = scraper.scrape()
                validate_smoke_listings(
                    listings,
                    expected_country_code="PT",
                    expected_store_id=scraper.store_id,
                )


if __name__ == "__main__":
    unittest.main()
