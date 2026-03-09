import json
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace
from unittest.mock import patch

from scrapers.base import ScrapedListing
from scrapers.run_scrapers import run


class _FakeStoreScraper:
    def __init__(self, *, store_id: str, store_name: str, listings=None, error: Exception | None = None):
        self.country_code = "PT"
        self.store_id = store_id
        self.store_name = store_name
        self._listings = listings or []
        self._error = error

    def scrape(self):
        if self._error is not None:
            raise self._error
        return self._listings


class RunScrapersArtifactsTest(unittest.TestCase):
    def test_run_emits_store_artifacts_with_standard_listing_shape(self):
        fake_scraper = _FakeStoreScraper(
            store_id="continente",
            store_name="Continente",
            listings=[
                ScrapedListing(
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
            ],
        )

        with tempfile.TemporaryDirectory() as tmpdir, \
            patch("scrapers.run_scrapers.pt_store_scrapers", return_value=[fake_scraper]), \
            patch(
                "scrapers.run_scrapers._load_external_scrapers",
                return_value=(
                    SimpleNamespace(scrape=lambda: {}, FALLBACK_INDICES={}),
                    SimpleNamespace(fetch_all=lambda enrich_nutrition=False: {"open_prices": [], "nutrition": {}}),
                ),
            ):
            output_path = Path(tmpdir) / "grocery_prices.json"
            run(output_path)
            payload = json.loads(output_path.read_text(encoding="utf-8"))

        self.assertIn("store_artifacts", payload)
        self.assertEqual(len(payload["store_artifacts"]), 1)

        artifact = payload["store_artifacts"][0]
        self.assertEqual(artifact["store_id"], "continente")
        self.assertEqual(artifact["store_name"], "Continente")
        self.assertEqual(artifact["status"], "ok")
        self.assertEqual(artifact["listing_count"], 1)
        self.assertIn("scraped_at", artifact)

        listing = artifact["listings"][0]
        self.assertEqual(listing["country_code"], "PT")
        self.assertEqual(listing["store_id"], "continente")
        self.assertEqual(listing["store_name"], "Continente")
        self.assertEqual(listing["product_name"], "Leite Meio Gordo")
        self.assertEqual(listing["price"], 0.89)
        self.assertEqual(listing["category"], "Lacticinios e Ovos")

        self.assertEqual(payload["metadata"]["scraper_results"]["Continente"]["status"], "ok")
        self.assertEqual(payload["metadata"]["scraper_results"]["Continente"]["count"], 1)

    def test_run_emits_error_store_artifact_on_partial_failure(self):
        ok_scraper = _FakeStoreScraper(
            store_id="continente",
            store_name="Continente",
            listings=[
                ScrapedListing(
                    country_code="PT",
                    store_id="continente",
                    store_name="Continente",
                    product_name="Leite Meio Gordo",
                    price=0.89,
                    category="Lacticinios e Ovos",
                )
            ],
        )
        failing_scraper = _FakeStoreScraper(
            store_id="auchan",
            store_name="Auchan",
            error=RuntimeError("timeout"),
        )

        with tempfile.TemporaryDirectory() as tmpdir, \
            patch("scrapers.run_scrapers.pt_store_scrapers", return_value=[ok_scraper, failing_scraper]), \
            patch(
                "scrapers.run_scrapers._load_external_scrapers",
                return_value=(
                    SimpleNamespace(scrape=lambda: {}, FALLBACK_INDICES={}),
                    SimpleNamespace(fetch_all=lambda enrich_nutrition=False: {"open_prices": [], "nutrition": {}}),
                ),
            ):
            output_path = Path(tmpdir) / "grocery_prices.json"
            run(output_path)
            payload = json.loads(output_path.read_text(encoding="utf-8"))

        artifacts = {artifact["store_id"]: artifact for artifact in payload["store_artifacts"]}

        self.assertEqual(artifacts["continente"]["status"], "ok")
        self.assertEqual(artifacts["auchan"]["status"], "error")
        self.assertEqual(artifacts["auchan"]["listing_count"], 0)
        self.assertEqual(artifacts["auchan"]["listings"], [])
        self.assertEqual(artifacts["auchan"]["error"], "timeout")

        self.assertEqual(payload["metadata"]["scraper_results"]["Auchan"]["status"], "error")
        self.assertEqual(payload["metadata"]["total_products"], 1)
        self.assertEqual(len(payload["products"]), 1)


if __name__ == "__main__":
    unittest.main()
