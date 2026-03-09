import json
import tempfile
import unittest
from pathlib import Path

from scrapers.build_country_bundle import build_country_bundle
from scrapers.validate_bundle import validate_country_bundle


def _write_json(path: Path, payload: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")


class BuildCountryBundleTest(unittest.TestCase):
    def test_build_country_bundle_writes_catalog_summaries_and_legacy_pt(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            generated = root / "generated" / "grocery"
            assets = root / "assets" / "grocery"
            legacy = root / "assets" / "grocery_prices.json"

            _write_json(
                generated / "PT" / "continente" / "raw.json",
                {
                    "country_code": "PT",
                    "store_id": "continente",
                    "store_name": "Continente",
                    "status": "ok",
                    "scraped_at": "2026-03-09T10:00:00Z",
                    "listing_count": 1,
                    "listings": [
                        {
                            "country_code": "PT",
                            "store_id": "continente",
                            "store_name": "Continente",
                            "product_name": "Leite Meio Gordo 1 L",
                            "price": 0.99,
                            "category": "Laticinios",
                            "product_id": "milk-1l",
                            "unit_price": "0.99/L",
                        }
                    ],
                },
            )
            _write_json(
                generated / "PT" / "continente" / "normalized.json",
                {
                    "country_code": "PT",
                    "store_id": "continente",
                    "store_name": "Continente",
                    "generated_at": "2026-03-09T10:00:00Z",
                    "warnings": [],
                    "listings": [
                        {
                            "id": "PT_continente_milk-1l",
                            "country_code": "PT",
                            "store_id": "continente",
                            "canonical_product_id": None,
                            "store_product_id": "milk-1l",
                            "product_url": None,
                            "raw_title": "Leite Meio Gordo 1 L",
                            "display_title": "Leite Meio Gordo 1 L",
                            "brand": None,
                            "size_value": 1.0,
                            "size_unit": "l",
                            "pack_count": 1,
                            "base_quantity": 1.0,
                            "base_unit": "l",
                            "price": 0.99,
                            "currency_code": "EUR",
                            "price_per_base_unit": 0.99,
                            "source_status": "fresh",
                        }
                    ],
                },
            )
            _write_json(
                generated / "PT" / "continente" / "status.json",
                {
                    "dataset_status": {
                        "country_code": "PT",
                        "store_id": "continente",
                        "run_id": "run-1",
                        "last_updated_at": "2026-03-09T10:00:00Z",
                        "scrape_status": "success",
                        "listing_count": 1,
                        "matched_count": 1,
                        "unmatched_count": 0,
                        "validation_warnings": [],
                        "source_version": "2.0.0",
                    },
                    "store_summary": {
                        "store_id": "continente",
                        "display_name": "Continente",
                        "last_updated_at": "2026-03-09T10:00:00Z",
                        "status": "fresh",
                        "listing_count": 1,
                    },
                },
            )

            catalog = build_country_bundle(
                country_code="PT",
                input_root=generated,
                output_root=assets,
                legacy_output_path=legacy,
            )

            self.assertEqual(catalog["country_code"], "PT")
            self.assertEqual(len(catalog["stores"]), 1)
            self.assertEqual(len(catalog["listings"]), 1)
            self.assertTrue((assets / "PT" / "catalog.json").exists())
            self.assertTrue((assets / "PT" / "store_summaries.json").exists())
            self.assertTrue((assets / "PT" / "stores" / "continente.json").exists())
            self.assertTrue(legacy.exists())

            validation = validate_country_bundle(country_code="PT", input_root=assets)
            self.assertEqual(validation["errors"], [])
            self.assertEqual(validation["fresh_count"], 1)

    def test_validate_country_bundle_fails_when_all_stores_failed(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            country_dir = root / "PT"
            _write_json(
                country_dir / "catalog.json",
                {
                    "country_code": "PT",
                    "stores": [{"store_id": "continente", "store_name": "Continente"}],
                    "listings": [],
                },
            )
            _write_json(
                country_dir / "store_summaries.json",
                [
                    {
                        "store_id": "continente",
                        "display_name": "Continente",
                        "status": "failed",
                        "listing_count": 0,
                    }
                ],
            )

            validation = validate_country_bundle(country_code="PT", input_root=root)
            self.assertNotEqual(validation["errors"], [])
            self.assertIn("all stores failed", validation["errors"][0])

    def test_build_country_bundle_supports_es(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            root = Path(tmpdir)
            generated = root / "generated" / "grocery"
            assets = root / "assets" / "grocery"

            _write_json(
                generated / "ES" / "mercadona" / "raw.json",
                {
                    "country_code": "ES",
                    "store_id": "mercadona",
                    "store_name": "Mercadona",
                    "status": "ok",
                    "scraped_at": "2026-03-09T10:00:00Z",
                    "listing_count": 1,
                    "listings": [
                        {
                            "country_code": "ES",
                            "store_id": "mercadona",
                            "store_name": "Mercadona",
                            "product_name": "Leche Entera 1 L",
                            "price": 1.05,
                            "category": "Lacteos y Huevos",
                            "product_id": "milk-es-1",
                            "unit_price": "1,05/L",
                        }
                    ],
                },
            )
            _write_json(
                generated / "ES" / "mercadona" / "normalized.json",
                {
                    "country_code": "ES",
                    "store_id": "mercadona",
                    "store_name": "Mercadona",
                    "generated_at": "2026-03-09T10:00:00Z",
                    "currency_code": "EUR",
                    "warnings": [],
                    "listings": [
                        {
                            "id": "ES_mercadona_milk-es-1",
                            "country_code": "ES",
                            "store_id": "mercadona",
                            "canonical_product_id": None,
                            "store_product_id": "milk-es-1",
                            "product_url": None,
                            "raw_title": "Leche Entera 1 L",
                            "display_title": "Leche Entera 1 L",
                            "brand": None,
                            "size_value": 1.0,
                            "size_unit": "l",
                            "pack_count": 1,
                            "base_quantity": 1.0,
                            "base_unit": "l",
                            "price": 1.05,
                            "currency_code": "EUR",
                            "price_per_base_unit": 1.05,
                            "source_status": "fresh",
                        }
                    ],
                },
            )
            _write_json(
                generated / "ES" / "mercadona" / "status.json",
                {
                    "dataset_status": {
                        "country_code": "ES",
                        "store_id": "mercadona",
                        "run_id": "run-es-1",
                        "last_updated_at": "2026-03-09T10:00:00Z",
                        "scrape_status": "success",
                        "listing_count": 1,
                        "matched_count": 1,
                        "unmatched_count": 0,
                        "validation_warnings": [],
                        "source_version": "2.0.0",
                    },
                    "store_summary": {
                        "store_id": "mercadona",
                        "display_name": "Mercadona",
                        "last_updated_at": "2026-03-09T10:00:00Z",
                        "status": "fresh",
                        "listing_count": 1,
                    },
                },
            )

            catalog = build_country_bundle(
                country_code="ES",
                input_root=generated,
                output_root=assets,
            )

            self.assertEqual(catalog["country_code"], "ES")
            self.assertEqual(catalog["currency_code"], "EUR")
            self.assertTrue((assets / "ES" / "catalog.json").exists())
            self.assertTrue((assets / "ES" / "store_summaries.json").exists())
            validation = validate_country_bundle(country_code="ES", input_root=assets)
            self.assertEqual(validation["errors"], [])


if __name__ == "__main__":
    unittest.main()
