import unittest

from scrapers.market_config import (
    load_market_config,
    load_market_index,
    store_ids_for_market,
)


class MarketConfigTest(unittest.TestCase):
    def test_market_index_includes_pt_and_es(self):
        index = load_market_index()
        self.assertEqual(
            [entry["countryCode"] for entry in index["markets"]],
            ["PT", "ES"],
        )

    def test_es_market_config_exposes_expected_metadata(self):
        config = load_market_config("ES")
        self.assertEqual(config["currencyCode"], "EUR")
        self.assertEqual(config["locale"], "es-ES")
        self.assertEqual(
            [store["storeId"] for store in config["stores"]],
            ["mercadona", "carrefour_es"],
        )

    def test_store_ids_for_market_only_returns_enabled_stores(self):
        self.assertEqual(
            store_ids_for_market("PT"),
            ["continente", "pingo_doce", "auchan"],
        )
        self.assertEqual(
            store_ids_for_market("ES"),
            ["mercadona", "carrefour_es"],
        )


if __name__ == "__main__":
    unittest.main()
