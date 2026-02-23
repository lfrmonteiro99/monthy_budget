"""Scraper for Auchan.pt — extracts product names, prices, and categories."""

import time
import logging
import requests
from bs4 import BeautifulSoup

logger = logging.getLogger(__name__)

BASE_URL = "https://www.auchan.pt"

CATEGORIES = [
    {"slug": "pt/alimentacao/produtos-lacteos", "name": "Lacticínios e Ovos"},
    {"slug": "pt/produtos-frescos/talho", "name": "Carne"},
    {"slug": "pt/produtos-frescos/peixaria", "name": "Peixe"},
    {"slug": "pt/produtos-frescos/fruta", "name": "Frutas"},
    {"slug": "pt/produtos-frescos/legumes", "name": "Legumes"},
    {"slug": "pt/produtos-frescos/padaria", "name": "Padaria e Pastelaria"},
    {"slug": "pt/alimentacao/mercearia", "name": "Mercearia"},
    {"slug": "pt/alimentacao/bebidas", "name": "Bebidas"},
    {"slug": "pt/alimentacao/congelados", "name": "Congelados"},
    {"slug": "pt/beleza-e-higiene", "name": "Higiene e Beleza"},
    {"slug": "pt/casa-e-jardim/limpeza", "name": "Limpeza"},
]

HEADERS = {
    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
                  "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "pt-PT,pt;q=0.9,en;q=0.5",
}

# Auchan uses an Algolia-powered search API on the frontend
ALGOLIA_URL = "https://www.auchan.pt/on/demandware.store/Sites-AuchanPT-Site/default/Search-Show"


def _fetch_category_products(session: requests.Session, category: dict, max_products: int = 50) -> list[dict]:
    """Fetch products from a single Auchan category."""
    products = []
    url = f"{BASE_URL}/{category['slug']}"

    try:
        resp = session.get(url, headers=HEADERS, timeout=20)
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, "lxml")

        product_tiles = soup.select(
            ".product-tile, [data-pid], [class*='product-card'], "
            "[class*='auc-product'], .product"
        )

        for tile in product_tiles[:max_products]:
            try:
                name_el = tile.select_one(
                    ".product-tile-name, [class*='product-name'], "
                    "[class*='tile-name'], .auc-product__title, h3, h2"
                )
                price_el = tile.select_one(
                    ".product-price .value, [class*='sales-price'], "
                    "[class*='price-value'], [data-price], .auc-product__price"
                )
                unit_price_el = tile.select_one(
                    "[class*='unit-price'], [class*='price-per-unit'], "
                    ".auc-product__unit-price"
                )
                promo_el = tile.select_one(
                    "[class*='promotion'], [class*='discount'], [class*='promo']"
                )

                if not name_el or not price_el:
                    continue

                name = name_el.get_text(strip=True)

                # Try data attribute first
                price_val = tile.get("data-price") or price_el.get("data-price")
                if price_val:
                    price = float(price_val)
                else:
                    price_text = price_el.get_text(strip=True).replace("€", "").replace(",", ".").strip()
                    price = float(price_text)

                unit_price = None
                if unit_price_el:
                    unit_price = unit_price_el.get_text(strip=True)

                promo = None
                if promo_el:
                    promo = promo_el.get_text(strip=True)

                products.append({
                    "name": name,
                    "price": price,
                    "unit_price": unit_price,
                    "category": category["name"],
                    "product_id": tile.get("data-pid", ""),
                    "store": "Auchan",
                    "promotion": promo,
                })
            except (ValueError, AttributeError):
                continue

    except requests.RequestException as e:
        logger.warning(f"Failed to fetch Auchan category {category['slug']}: {e}")

    return products


def scrape() -> list[dict]:
    """Scrape products from Auchan across all categories."""
    all_products = []
    session = requests.Session()

    for cat in CATEGORIES:
        logger.info(f"Scraping Auchan: {cat['name']}...")
        products = _fetch_category_products(session, cat)
        all_products.extend(products)
        logger.info(f"  Found {len(products)} products")
        time.sleep(2)

    logger.info(f"Auchan total: {len(all_products)} products")
    return all_products
