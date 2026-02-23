"""Scraper for Pingo Doce (pingodoce.pt) — extracts product names, prices, and categories."""

import time
import logging
import requests
from bs4 import BeautifulSoup

logger = logging.getLogger(__name__)

# Pingo Doce migrated from mercadao.pt to pingodoce.pt (Salesforce Commerce Cloud)
BASE_URL = "https://www.pingodoce.pt"
SFCC_URL = f"{BASE_URL}/on/demandware.store/Sites-pingo-doce-Site/pt_PT/Search-Show"

# cgid values discovered from the pingodoce.pt SFCC navigation
CATEGORIES = [
    {"id": "ec_leitebebidasvegetais_900", "name": "Lacticínios e Ovos"},
    {"id": "ec_talho_200", "name": "Carne"},
    {"id": "ec_peixe_300_100", "name": "Peixe e Marisco"},
    {"id": "ec_frutasvegetais_1000_300", "name": "Frutas e Legumes"},
    {"id": "ec_paonossapadaria_400_100", "name": "Padaria e Pastelaria"},
    {"id": "ec_mercearia_1300", "name": "Mercearia"},
    {"id": "ec_aguassumosrefrigerantes_1400", "name": "Bebidas"},
    {"id": "ec_congelados_1000", "name": "Congelados"},
    {"id": "ec_higienepessoalbeleza_2100", "name": "Higiene e Beleza"},
    {"id": "ec_limpeza_1800", "name": "Limpeza"},
]

HEADERS = {
    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
                  "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "pt-PT,pt;q=0.9,en;q=0.5",
    "Referer": BASE_URL,
}


def _fetch_category_products(session: requests.Session, category: dict, max_products: int = 50) -> list[dict]:
    """Fetch products from a single Pingo Doce category via SFCC Search-Show."""
    products = []
    params = {
        "cgid": category["id"],
        "sz": max_products,
        "start": 0,
    }

    try:
        resp = session.get(SFCC_URL, params=params, headers=HEADERS, timeout=20)
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, "lxml")

        # SFCC standard product tile selectors
        product_tiles = soup.select("[data-pid]")
        if not product_tiles:
            product_tiles = soup.select(".product-tile, .pd-tile, [class*='product-card']")

        for tile in product_tiles[:max_products]:
            try:
                name_el = tile.select_one(
                    ".pdp-link a, .product-name, .pd-tile__name, "
                    "[class*='product-name'], [class*='tile-name'], h3, h2"
                )
                price_el = tile.select_one(
                    ".sales .value, .price .value, .pd-tile__price, "
                    "[class*='sales-price'], [class*='price-value'], [data-price]"
                )

                if not name_el or not price_el:
                    continue

                name = name_el.get_text(strip=True)
                price_val = price_el.get("content") or price_el.get("data-price")
                if price_val:
                    price = float(price_val)
                else:
                    price_text = price_el.get_text(strip=True).replace("€", "").replace(",", ".").strip()
                    price = float(price_text)

                unit_price_el = tile.select_one("[class*='unit-price'], [class*='price-per']")
                unit_price = unit_price_el.get_text(strip=True) if unit_price_el else None

                products.append({
                    "name": name,
                    "price": price,
                    "unit_price": unit_price,
                    "category": category["name"],
                    "product_id": tile.get("data-pid", ""),
                    "store": "Pingo Doce",
                })
            except (ValueError, AttributeError):
                continue

    except requests.RequestException as e:
        logger.warning(f"Failed to fetch Pingo Doce category {category['id']}: {e}")

    return products


def scrape() -> list[dict]:
    """Scrape products from Pingo Doce across all categories."""
    all_products = []
    session = requests.Session()

    for cat in CATEGORIES:
        logger.info(f"Scraping Pingo Doce: {cat['name']}...")
        products = _fetch_category_products(session, cat)
        all_products.extend(products)
        logger.info(f"  Found {len(products)} products")
        time.sleep(2)

    logger.info(f"Pingo Doce total: {len(all_products)} products")
    return all_products
