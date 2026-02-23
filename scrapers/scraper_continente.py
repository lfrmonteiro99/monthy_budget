"""Scraper for Continente.pt — extracts product names, prices, and categories."""

import time
import logging
import requests
from bs4 import BeautifulSoup

logger = logging.getLogger(__name__)

BASE_URL = "https://www.continente.pt"
SEARCH_URL = f"{BASE_URL}/pesquisa"

CATEGORIES = [
    {"slug": "lacticinios-e-ovos", "name": "Lacticínios e Ovos"},
    {"slug": "carne", "name": "Carne"},
    {"slug": "peixe", "name": "Peixe"},
    {"slug": "frutas-e-legumes", "name": "Frutas e Legumes"},
    {"slug": "padaria-e-pastelaria", "name": "Padaria e Pastelaria"},
    {"slug": "mercearia", "name": "Mercearia"},
    {"slug": "bebidas", "name": "Bebidas"},
    {"slug": "congelados", "name": "Congelados"},
    {"slug": "higiene-e-beleza", "name": "Higiene e Beleza"},
    {"slug": "limpeza-e-arrumacao", "name": "Limpeza e Arrumação"},
]

HEADERS = {
    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
                  "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "pt-PT,pt;q=0.9,en;q=0.5",
}

# Continente exposes a product listing API used by their frontend
PRODUCT_API = f"{BASE_URL}/on/demandware.store/Sites-continente-Site/default/Search-UpdateGrid"


def _fetch_category_products(session: requests.Session, category: dict, max_products: int = 50) -> list[dict]:
    """Fetch products from a single Continente category via their internal API."""
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
                name_el = tile.select_one(
                    ".product-tile-name, .ct-tile-name, .pwc-tile--description, "
                    "[class*='product-name'], [class*='tile-name'], h3, h2"
                )
                price_el = tile.select_one(
                    ".product-price .value, .ct-price-value, .pwc-tile--price-primary, "
                    "[class*='sales-price'], [class*='price-value'], [data-price]"
                )
                unit_price_el = tile.select_one(
                    ".product-price-per-unit, .ct-price-unit, .pwc-tile--price-secondary, "
                    "[class*='unit-price']"
                )

                if not name_el or not price_el:
                    continue

                name = name_el.get_text(strip=True)
                price_text = price_el.get_text(strip=True).replace("€", "").replace(",", ".").strip()

                # Try data attributes first
                price_val = tile.get("data-price") or price_el.get("data-price")
                if price_val:
                    price = float(price_val)
                else:
                    # Parse from text, handle "desde X" patterns
                    price_text = price_text.replace("desde", "").strip()
                    price = float(price_text)

                unit_price = None
                if unit_price_el:
                    up_text = unit_price_el.get_text(strip=True)
                    unit_price = up_text

                product_id = tile.get("data-pid", "")

                products.append({
                    "name": name,
                    "price": price,
                    "unit_price": unit_price,
                    "category": category["name"],
                    "product_id": product_id,
                    "store": "Continente",
                })
            except (ValueError, AttributeError):
                continue

    except requests.RequestException as e:
        logger.warning(f"Failed to fetch Continente category {category['slug']}: {e}")

    return products


def scrape() -> list[dict]:
    """Scrape products from Continente across all categories."""
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
