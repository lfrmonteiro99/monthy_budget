"""Scraper for Pingo Doce (pingodoce.pt) — extracts product names, prices, and categories."""

import json
import time
import logging
import requests
from bs4 import BeautifulSoup

logger = logging.getLogger(__name__)

BASE_URL = "https://www.pingodoce.pt"
# Search-UpdateGrid returns a server-side rendered product grid (no JS required)
SFCC_URL = f"{BASE_URL}/on/demandware.store/Sites-pingo-doce-Site/pt_PT/Search-UpdateGrid"

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
    """Fetch products from a single Pingo Doce category via SFCC Search-UpdateGrid."""
    products = []
    params = {"cgid": category["id"], "sz": max_products, "start": 0}

    try:
        resp = session.get(SFCC_URL, params=params, headers=HEADERS, timeout=20)
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, "lxml")

        # Containers: <div class="product" data-pid="..."> wrapping <div class="product-tile-pd" data-gtm-info="...">
        product_tiles = soup.select("div.product-tile-pd[data-gtm-info]")
        if not product_tiles:
            product_tiles = soup.select("div.product[data-pid]")

        for tile in product_tiles[:max_products]:
            try:
                # Primary: parse data-gtm-info JSON — has clean name and numeric price
                gtm_raw = tile.get("data-gtm-info", "")
                if gtm_raw:
                    gtm = json.loads(gtm_raw)
                    items = gtm.get("items", [])
                    name = items[0].get("item_name", "") if items else ""
                    price = gtm.get("value")
                else:
                    # Fallback: parse from HTML elements
                    name_el = tile.select_one(".product-name-link a")
                    price_el = tile.select_one(".product-price .sales .value")
                    if not name_el or not price_el:
                        continue
                    name = name_el.get_text(strip=True)
                    price_val = price_el.get("content")
                    price = float(price_val) if price_val else float(
                        price_el.get_text(strip=True)
                        .replace("€", "").replace(",", ".").split("/")[0].strip()
                    )

                if not name or price is None:
                    continue

                # Unit price displayed as "6,49 €/Kg"
                price_el = tile.select_one(".product-price .sales .value")
                unit_price = price_el.get_text(strip=True) if price_el else None

                brand_el = tile.select_one(".product-brand-name")
                brand = brand_el.get_text(strip=True) if brand_el else ""

                pid = tile.get("data-pid", "") or tile.find_parent("[data-pid]", {"data-pid": True})
                if hasattr(pid, "get"):
                    pid = pid.get("data-pid", "")

                products.append({
                    "name": name,
                    "price": float(price),
                    "unit_price": unit_price,
                    "category": category["name"],
                    "product_id": str(pid),
                    "store": "Pingo Doce",
                    "brand": brand,
                })
            except (ValueError, AttributeError, KeyError, json.JSONDecodeError):
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
