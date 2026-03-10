"""Scraper for Continente.pt — extracts product names, prices, and categories."""

import json
import time
import logging
from typing import TYPE_CHECKING

try:  # Script execution from scrapers/
    from base import ScrapedListing, StoreScraper
except ImportError:  # Package execution from repo root/tests
    from .base import ScrapedListing, StoreScraper

if TYPE_CHECKING:
    import requests

logger = logging.getLogger(__name__)

BASE_URL = "https://www.continente.pt"
SEARCH_URL = f"{BASE_URL}/pesquisa"

CATEGORIES = [
    {"slug": "laticinios-e-ovos", "name": "Lacticínios e Ovos"},
    {"slug": "frescos/talho", "name": "Carne"},
    {"slug": "frescos/peixaria", "name": "Peixe"},
    {"slug": "frescos/frutas", "name": "Frutas"},
    {"slug": "frescos/legumes", "name": "Legumes"},
    {"slug": "frescos/padaria-e-pastelaria", "name": "Padaria e Pastelaria"},
    {"slug": "mercearia", "name": "Mercearia"},
    {"slug": "bebidas-e-garrafeira", "name": "Bebidas"},
    {"slug": "congelados", "name": "Congelados"},
    {"slug": "higiene-e-beleza", "name": "Higiene e Beleza"},
    {"slug": "limpeza", "name": "Limpeza"},
]

HEADERS = {
    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
                  "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "pt-PT,pt;q=0.9,en;q=0.5",
}

# Continente exposes a product listing API used by their frontend
PRODUCT_API = f"{BASE_URL}/on/demandware.store/Sites-continente-Site/default/Search-UpdateGrid"


def _fetch_category_products(session: "requests.Session", category: dict, max_products: int = 50) -> list[dict]:
    """Fetch products from a single Continente category via their internal API."""
    import requests
    from bs4 import BeautifulSoup

    products = []
    url = f"{BASE_URL}/{category['slug']}"

    try:
        resp = session.get(url, headers=HEADERS, timeout=20)
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, "lxml")

        product_tiles = soup.select("[data-pid]")
        if not product_tiles:
            product_tiles = soup.select(".product-tile, .ct-product-tile, .product")

        for tile in product_tiles[:max_products]:
            try:
                # Primary: data-product-tile-impression JSON has clean name, price, brand
                impression_raw = tile.get("data-product-tile-impression", "")
                if impression_raw:
                    imp = json.loads(impression_raw)
                    name = imp.get("name", "")
                    price = imp.get("price")
                    brand = imp.get("brand", "")
                    product_id = str(imp.get("id", tile.get("data-pid", "")))
                else:
                    # Fallback: parse from HTML elements
                    name_el = tile.select_one(".pwc-tile--description, h2, h3")
                    price_el = tile.select_one(".pwc-tile--price-primary")
                    if not name_el or not price_el:
                        continue
                    name = name_el.get_text(strip=True)
                    price_text = price_el.get_text(strip=True).replace("€", "").replace(",", ".").strip()
                    price_text = price_text.replace("desde", "").strip()
                    price = float(price_text)
                    brand = ""
                    product_id = tile.get("data-pid", "")

                if not name or price is None:
                    continue

                unit_price_el = tile.select_one(".pwc-tile--price-secondary")
                unit_price = unit_price_el.get_text(strip=True) if unit_price_el else None

                products.append({
                    "name": name,
                    "price": float(price),
                    "unit_price": unit_price,
                    "category": category["name"],
                    "product_id": product_id,
                    "store": "Continente",
                    "brand": brand,
                })
            except (ValueError, AttributeError, KeyError, json.JSONDecodeError):
                continue

    except requests.RequestException as e:
        logger.warning(f"Failed to fetch Continente category {category['slug']}: {e}")

    return products


def scrape() -> list[dict]:
    """Scrape products from Continente across all categories."""
    import requests

    all_products = []
    session = requests.Session()

    for cat in CATEGORIES:
        logger.info(f"Scraping Continente: {cat['name']}...")
        products = _fetch_category_products(session, cat)
        all_products.extend(products)
        logger.info(f"  Found {len(products)} products")
        time.sleep(2)  # Rate limiting

    logger.info(f"Continente total: {len(all_products)} products")
    return all_products


class ContinenteScraper(StoreScraper):
    country_code = "PT"
    store_id = "continente"
    store_name = "Continente"
    categories = CATEGORIES

    def scrape(self) -> list[ScrapedListing]:
        import requests

        listings: list[ScrapedListing] = []
        session = requests.Session()

        for category in self.categories:
            logger.info(f"Scraping {self.store_name}: {category['name']}...")
            products = _fetch_category_products(session, category)
            listings.extend(
                ScrapedListing(
                    country_code=self.country_code,
                    store_id=self.store_id,
                    store_name=self.store_name,
                    product_name=product.get("name", ""),
                    price=float(product.get("price", 0)),
                    category=product.get("category", ""),
                    product_id=str(product.get("product_id", "")),
                    unit_price=product.get("unit_price"),
                    brand=product.get("brand"),
                    product_url=product.get("product_url"),
                )
                for product in products
            )
            logger.info(f"  Found {len(products)} products")
            time.sleep(2)

        logger.info(f"{self.store_name} total: {len(listings)} products")
        return listings
