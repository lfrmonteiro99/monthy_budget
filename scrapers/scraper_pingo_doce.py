"""Scraper for Pingo Doce (via mercadao.pt) — extracts product names, prices, and categories."""

import time
import logging
import requests

logger = logging.getLogger(__name__)

# Pingo Doce's online store (Mercadão) exposes a JSON API for product listings
BASE_URL = "https://mercadao.pt"
API_URL = f"{BASE_URL}/api/catalogues/6107d29d164f510d1189cbc0/products/search"

CATEGORIES = [
    {"id": "lacticinios-e-ovos", "name": "Lacticínios e Ovos"},
    {"id": "carne", "name": "Carne"},
    {"id": "peixe-e-marisco", "name": "Peixe e Marisco"},
    {"id": "frutas-e-legumes", "name": "Frutas e Legumes"},
    {"id": "padaria-e-pastelaria", "name": "Padaria e Pastelaria"},
    {"id": "mercearia", "name": "Mercearia"},
    {"id": "bebidas", "name": "Bebidas"},
    {"id": "congelados", "name": "Congelados"},
    {"id": "higiene-e-beleza", "name": "Higiene e Beleza"},
    {"id": "limpeza", "name": "Limpeza"},
]

HEADERS = {
    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
                  "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "application/json, text/plain, */*",
    "Accept-Language": "pt-PT,pt;q=0.9",
}


def _fetch_category_api(session: requests.Session, category: dict, max_products: int = 50) -> list[dict]:
    """Attempt to fetch products from Mercadão/Pingo Doce JSON API."""
    products = []

    # Try the known Mercadão API endpoint
    params = {
        "query": category["id"],
        "from": 0,
        "size": max_products,
        "espirito-santo": "false",
    }

    try:
        resp = session.get(API_URL, params=params, headers=HEADERS, timeout=20)
        if resp.status_code == 200:
            data = resp.json()
            sections = data.get("sections", [])
            for section in sections:
                for product in section.get("products", []):
                    try:
                        name = product.get("name", "")
                        price_info = product.get("price", {})
                        price = price_info.get("value") or price_info.get("current")

                        if not name or price is None:
                            continue

                        products.append({
                            "name": name,
                            "price": float(price),
                            "unit_price": product.get("unitPrice"),
                            "category": category["name"],
                            "product_id": product.get("sku", product.get("id", "")),
                            "store": "Pingo Doce",
                            "brand": product.get("brand", ""),
                        })
                    except (ValueError, TypeError):
                        continue
            return products
    except (requests.RequestException, ValueError) as e:
        logger.debug(f"Mercadão API failed for {category['id']}: {e}")

    # Fallback: scrape the HTML category page
    return _fetch_category_html(session, category, max_products)


def _fetch_category_html(session: requests.Session, category: dict, max_products: int = 50) -> list[dict]:
    """Fallback HTML scraper for Pingo Doce."""
    from bs4 import BeautifulSoup

    products = []
    url = f"{BASE_URL}/store/pingo-doce/{category['id']}"

    try:
        resp = session.get(url, headers=HEADERS, timeout=20)
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, "lxml")

        product_cards = soup.select(
            "[class*='product-card'], [class*='ProductCard'], "
            "[class*='product-tile'], [data-product-id]"
        )

        for card in product_cards[:max_products]:
            try:
                name_el = card.select_one(
                    "[class*='product-name'], [class*='ProductName'], h3, h2, [class*='title']"
                )
                price_el = card.select_one(
                    "[class*='product-price'], [class*='Price'], [class*='price'], [data-price]"
                )

                if not name_el or not price_el:
                    continue

                name = name_el.get_text(strip=True)
                price_text = price_el.get_text(strip=True).replace("€", "").replace(",", ".").strip()
                price = float(price_text)

                products.append({
                    "name": name,
                    "price": price,
                    "unit_price": None,
                    "category": category["name"],
                    "product_id": card.get("data-product-id", ""),
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
        products = _fetch_category_api(session, cat)
        all_products.extend(products)
        logger.info(f"  Found {len(products)} products")
        time.sleep(2)

    logger.info(f"Pingo Doce total: {len(all_products)} products")
    return all_products
