"""Integration with Open Food Facts / Open Prices API.

Enriches scraped products with nutritional data (NutriScore, categories)
and fetches crowdsourced price data for Portuguese stores.
"""

import logging
import time
import requests

logger = logging.getLogger(__name__)

OFF_API = "https://world.openfoodfacts.org/api/v2"
OPEN_PRICES_API = "https://prices.openfoodfacts.org/api/v1"

HEADERS = {
    "User-Agent": "MonthyBudget/1.0 (https://github.com/lfrmonteiro99/monthy_budget)",
}

# Portuguese store location IDs known to Open Prices
PT_STORE_TAGS = [
    "Continente",
    "Pingo Doce",
    "Auchan",
    "Intermarché",
    "Minipreço",
    "Lidl",
]


def fetch_open_prices_portugal(max_results: int = 200) -> list[dict]:
    """Fetch crowdsourced price data for Portuguese stores from Open Prices API."""
    prices = []

    try:
        # Fetch recent prices from Portugal
        params = {
            "location_osm_address_country__like": "Portugal",
            "order_by": "-date",
            "size": min(max_results, 100),
        }
        resp = requests.get(
            f"{OPEN_PRICES_API}/prices",
            params=params,
            headers=HEADERS,
            timeout=30,
        )

        if resp.status_code == 200:
            data = resp.json()
            items = data.get("items", data.get("results", []))
            for item in items:
                try:
                    price_entry = {
                        "product_name": item.get("product", {}).get("product_name", ""),
                        "product_code": item.get("product_code", ""),
                        "price": item.get("price"),
                        "currency": item.get("currency", "EUR"),
                        "store": item.get("location", {}).get("osm_name", ""),
                        "city": item.get("location", {}).get("osm_address_city", ""),
                        "date": item.get("date", ""),
                        "source": "Open Prices (crowdsourced)",
                        "nutriscore": item.get("product", {}).get("nutriscore_grade"),
                        "categories": item.get("product", {}).get("categories_tags", []),
                    }
                    if price_entry["price"] is not None and price_entry["product_name"]:
                        prices.append(price_entry)
                except (KeyError, TypeError):
                    continue

            logger.info(f"Open Prices: fetched {len(prices)} Portuguese price entries")
        else:
            logger.warning(f"Open Prices API returned {resp.status_code}")

    except requests.RequestException as e:
        logger.warning(f"Open Prices API request failed: {e}")

    return prices


def enrich_product_with_nutrition(product_code: str) -> dict | None:
    """Look up a product by barcode on Open Food Facts for nutritional data."""
    try:
        resp = requests.get(
            f"{OFF_API}/product/{product_code}.json",
            headers=HEADERS,
            timeout=10,
        )
        if resp.status_code == 200:
            data = resp.json()
            product = data.get("product", {})
            if product:
                return {
                    "nutriscore_grade": product.get("nutriscore_grade"),
                    "nutriscore_score": product.get("nutriscore_score"),
                    "nova_group": product.get("nova_group"),
                    "ecoscore_grade": product.get("ecoscore_grade"),
                    "energy_kcal_100g": product.get("nutriments", {}).get("energy-kcal_100g"),
                    "fat_100g": product.get("nutriments", {}).get("fat_100g"),
                    "sugars_100g": product.get("nutriments", {}).get("sugars_100g"),
                    "salt_100g": product.get("nutriments", {}).get("salt_100g"),
                    "categories": product.get("categories", ""),
                    "brands": product.get("brands", ""),
                    "image_url": product.get("image_front_small_url"),
                }
    except requests.RequestException:
        pass
    return None


def fetch_all(enrich_nutrition: bool = False) -> dict:
    """Fetch all Open Food Facts data for Portugal.

    Returns a dict with:
      - open_prices: list of crowdsourced price entries
      - nutrition: dict of product_code -> nutrition data (if enrich_nutrition=True)
    """
    result = {
        "open_prices": fetch_open_prices_portugal(),
    }

    # Optionally enrich with nutrition data (slow — one API call per product)
    if enrich_nutrition and result["open_prices"]:
        nutrition = {}
        codes = set(p["product_code"] for p in result["open_prices"] if p.get("product_code"))
        for code in list(codes)[:50]:  # Limit to avoid rate limiting
            data = enrich_product_with_nutrition(code)
            if data:
                nutrition[code] = data
            time.sleep(0.5)
        result["nutrition"] = nutrition
        logger.info(f"Open Food Facts: enriched {len(nutrition)} products with nutrition data")

    return result
