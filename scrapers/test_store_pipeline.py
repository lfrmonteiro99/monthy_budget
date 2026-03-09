import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from scrapers.base import ScrapedListing
from scrapers.store_pipeline import write_store_outputs


class _FakeScraper:
    def __init__(
        self,
        *,
        fail: bool = False,
        country_code: str = "PT",
        store_id: str = "continente",
        store_name: str = "Continente",
        product_name: str = "Leite Meio Gordo 1 L",
        category: str = "Laticinios",
    ):
        self.country_code = country_code
        self.store_id = store_id
        self.store_name = store_name
        self._fail = fail
        self._product_name = product_name
        self._category = category

    def scrape(self):
        if self._fail:
            raise RuntimeError("timeout")
        return [
            ScrapedListing(
                country_code=self.country_code,
                store_id=self.store_id,
                store_name=self.store_name,
                product_name=self._product_name,
                price=0.99,
                category=self._category,
                product_id="milk-1l",
                unit_price="0.99/L",
            )
        ]


class StorePipelineTest(unittest.TestCase):
    def test_write_store_outputs_emits_raw_normalized_and_status(self):
        with tempfile.TemporaryDirectory() as tmpdir, patch(
            "scrapers.store_pipeline.get_store_scraper",
            return_value=_FakeScraper(),
        ):
            paths = write_store_outputs(
                country_code="PT",
                store_id="continente",
                output_root=Path(tmpdir),
                run_id="run-1",
            )

            raw = json.loads(paths["raw"].read_text(encoding="utf-8"))
            normalized = json.loads(paths["normalized"].read_text(encoding="utf-8"))
            status = json.loads(paths["status"].read_text(encoding="utf-8"))

        self.assertEqual(raw["status"], "ok")
        self.assertEqual(raw["listing_count"], 1)
        self.assertEqual(normalized["store_id"], "continente")
        self.assertEqual(len(normalized["listings"]), 1)
        self.assertEqual(status["dataset_status"]["scrape_status"], "success")
        self.assertEqual(status["store_summary"]["status"], "fresh")

    def test_write_store_outputs_keeps_failed_store_artifact(self):
        with tempfile.TemporaryDirectory() as tmpdir, patch(
            "scrapers.store_pipeline.get_store_scraper",
            return_value=_FakeScraper(fail=True),
        ):
            paths = write_store_outputs(
                country_code="PT",
                store_id="continente",
                output_root=Path(tmpdir),
                run_id="run-2",
            )
            raw = json.loads(paths["raw"].read_text(encoding="utf-8"))
            normalized = json.loads(paths["normalized"].read_text(encoding="utf-8"))
            status = json.loads(paths["status"].read_text(encoding="utf-8"))

        self.assertEqual(raw["status"], "error")
        self.assertEqual(raw["error"], "timeout")
        self.assertEqual(normalized["listings"], [])
        self.assertEqual(status["dataset_status"]["scrape_status"], "failed")
        self.assertEqual(status["store_summary"]["status"], "failed")

    def test_write_store_outputs_supports_es_market(self):
        with tempfile.TemporaryDirectory() as tmpdir, patch(
            "scrapers.store_pipeline.get_store_scraper",
            return_value=_FakeScraper(
                country_code="ES",
                store_id="mercadona",
                store_name="Mercadona",
                product_name="Leche Entera 1 L",
                category="Lacteos y Huevos",
            ),
        ):
            paths = write_store_outputs(
                country_code="ES",
                store_id="mercadona",
                output_root=Path(tmpdir),
                run_id="run-es-1",
            )
            normalized = json.loads(paths["normalized"].read_text(encoding="utf-8"))
            status = json.loads(paths["status"].read_text(encoding="utf-8"))

        self.assertEqual(normalized["country_code"], "ES")
        self.assertEqual(normalized["currency_code"], "EUR")
        self.assertEqual(status["store_summary"]["status"], "fresh")


if __name__ == "__main__":
    unittest.main()
