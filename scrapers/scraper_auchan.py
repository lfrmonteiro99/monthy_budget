"""Scraper for Auchan.pt extracts product data."""

from __future__ import annotations

import logging
import time

try:  # Script execution from scrapers/
    from base import ScrapedListing, StoreScraper
except ImportError:  # Package execution from repo root/tests
    from .base import ScrapedListing, StoreScraper

logger = logging.getLogger(__name__)

BASE_URL = "https://www.auchan.pt"

CATEGORIES = [
    {"slug": "pt/alimentacao/produtos-lacteos", "name": "Lacticinios e Ovos"},
    {"slug": "pt/produtos-frescos/talho", "name": "Carne"},
    {"slug": "pt/produtos-frescos/peixaria", "name": "Peixe"},
    {"slug": "pt/produtos-frescos/fruta", "name": "Frutas"},
    {"slug": "pt/produtos-frescos/legumes", "name": "Legumes"},
    {"slug": "pt/produtos-frescos/padaria", "name": "Padaria e Pastelaria"},
    {"slug": "pt/alimentacao/mercearia", "name": "Mercearia"},
    {"slug": "pt/bebidas-e-garrafeira", "name": "Bebidas"},
    {"slug": "pt/alimentacao/congelados", "name": "Congelados"},
    {"slug": "pt/beleza-e-higiene", "name": "Higiene e Beleza"},
]

HEADERS = {
    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "pt-PT,pt;q=0.9,en;q=0.5",
}

ALGOLIA_URL = "https://www.auchan.pt/on/demandware.store/Sites-AuchanPT-Site/default/Search-Show"


def _fetch_category_products(session, category: dict, max_products: int = 50) -> list[dict]:
    """Fetch products from a single Auchan category."""
    import requests
    from bs4 import BeautifulSoup

    products = []
    url = f"{BASE_URL}/{category['slug']}"

    try:
        resp = session.get(url, headers=HEADERS, timeout=20)
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, "lxml")

        product_tiles = soup.select(".auc-product")
        if not product_tiles:
            product_tiles = soup.select("[data-pid]")

        for tile in product_tiles[:max_products]:
            try:
                name_el = tile.select_one(".auc-product-tile__name .link, .pdp-link h3 a.link, .pdp-link a")
                price_el = tile.select_one(".price .sales .value")

                if not name_el or not price_el:
                    continue

                name = name_el.get_text(strip=True)
                price_val = price_el.get("content")
                if price_val:
                    price = float(price_val)
                else:
                    price_text = (
                        price_el.get_text(strip=True)
                        .replace("EUR", "")
                        .replace("€", "")
                        .replace(",", ".")
                        .strip()
                    )
                    price = float(price_text)

                unit_price_el = tile.select_one(".auc-measures--price-per-unit")
                unit_price = unit_price_el.get_text(strip=True) if unit_price_el else None

                products.append({
                    "name": name,
                    "price": price,
                    "unit_price": unit_price,
                    "category": category["name"],
                    "product_id": tile.get("data-pid", ""),
                    "store": "Auchan",
                })
            except (ValueError, AttributeError):
                continue

    except requests.RequestException as exc:
        logger.warning("Failed to fetch Auchan category %s: %s", category["slug"], exc)

    return products


def scrape() -> list[dict]:
    """Scrape products from Auchan across all categories."""
    import requests

    all_products = []
    session = requests.Session()

    for cat in CATEGORIES:
        logger.info("Scraping Auchan: %s...", cat["name"])
        products = _fetch_category_products(session, cat)
        all_products.extend(products)
        logger.info("  Found %s products", len(products))
        time.sleep(2)

    logger.info("Auchan total: %s products", len(all_products))
    return all_products


class AuchanScraper(StoreScraper):
    country_code = "PT"
    store_id = "auchan"
    store_name = "Auchan"
    categories = CATEGORIES

    def scrape(self) -> list[ScrapedListing]:
        import requests

        listings: list[ScrapedListing] = []
        session = requests.Session()

        for category in self.categories:
            logger.info("Scraping %s: %s...", self.store_name, category["name"])
            products = _fetch_category_products(session, category)
            listings.extend(
                ScrapedListing(
                    country_code=self.country_code,
                    store_id=self.store_id,
                    store_name=self.store_name,
                    product_name=raw.get("name", ""),
                    price=float(raw.get("price", 0)),
                    category=raw.get("category", ""),
                    product_id=str(raw.get("product_id", "")),
                    unit_price=raw.get("unit_price"),
                    brand=raw.get("brand"),
                    product_url=raw.get("product_url"),
                )
                for raw in products
            )
            logger.info("  Found %s products", len(products))
            time.sleep(2)

        logger.info("%s total: %s products", self.store_name, len(listings))
        return listings

