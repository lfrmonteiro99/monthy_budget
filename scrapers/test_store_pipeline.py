import json
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

from scrapers.base import ScrapedListing
from scrapers.store_pipeline import write_store_outputs


class _FakeScraper:
    def __init__(self, *, fail: bool = False):
        self.country_code = "PT"
        self.store_id = "continente"
        self.store_name = "Continente"
        self._fail = fail

    def scrape(self):
        if self._fail:
            raise RuntimeError("timeout")
        return [
            ScrapedListing(
                country_code="PT",
                store_id="continente",
                store_name="Continente",
                product_name="Leite Meio Gordo 1 L",
                price=0.99,
                category="Laticinios",
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


if __name__ == "__main__":
    unittest.main()
