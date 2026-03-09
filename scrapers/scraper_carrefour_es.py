"""Scraper adapter for Carrefour Spain."""

from __future__ import annotations

import json
import logging
import time

try:
    from base import ScrapedListing, StoreScraper
except ImportError:
    from .base import ScrapedListing, StoreScraper

logger = logging.getLogger(__name__)

BASE_URL = "https://www.carrefour.es"
CATEGORIES = [
    {"slug": "supermercado/lacteos-y-huevos", "name": "Lacteos y Huevos"},
    {"slug": "supermercado/carniceria", "name": "Carne"},
    {"slug": "supermercado/pescaderia", "name": "Pescado y Marisco"},
    {"slug": "supermercado/frutas-y-verduras", "name": "Frutas y Verduras"},
    {"slug": "supermercado/despensa", "name": "Despensa"},
    {"slug": "supermercado/bebidas", "name": "Bebidas"},
    {"slug": "supermercado/congelados", "name": "Congelados"},
    {"slug": "supermercado/drogueria", "name": "Limpieza"},
]
HEADERS = {
    "User-Agent": "Mozilla/5.0",
    "Accept": "application/json,text/html;q=0.9,*/*;q=0.8",
    "Accept-Language": "es-ES,es;q=0.9,en;q=0.5",
}


def _fetch_category_products(session, category: dict, max_products: int = 50) -> list[dict]:
    from bs4 import BeautifulSoup

    url = f"{BASE_URL}/{category['slug']}"
    response = session.get(url, headers=HEADERS, timeout=20)
    response.raise_for_status()

    content_type = response.headers.get("content-type", "")
    if "application/json" in content_type:
        payload = response.json()
        items = payload.get("products", []) or payload.get("results", [])
    else:
        soup = BeautifulSoup(response.text, "lxml")
        script = soup.find("script", {"id": "__NEXT_DATA__"})
        if not script or not script.string:
            return []
        data = json.loads(script.string)
        items = (
            data.get("props", {})
            .get("pageProps", {})
            .get("products", [])
        )

    products = []
    for item in items[:max_products]:
        name = item.get("displayName") or item.get("name") or item.get("title") or ""
        price = item.get("price") or item.get("salePrice")
        if not name or price in (None, ""):
            continue
        products.append(
            {
                "name": name,
                "price": float(price),
                "unit_price": item.get("pricePerUnit") or item.get("unit_price"),
                "category": category["name"],
                "product_id": str(item.get("id") or item.get("productId") or ""),
                "brand": item.get("brand"),
            }
        )
    return products


class CarrefourEsScraper(StoreScraper):
    country_code = "ES"
    store_id = "carrefour_es"
    store_name = "Carrefour"
    categories = CATEGORIES

    def scrape(self) -> list[ScrapedListing]:
        import requests

        session = requests.Session()
        listings: list[ScrapedListing] = []
        for category in self.categories:
            logger.info("Scraping Carrefour ES: %s...", category["name"])
            products = _fetch_category_products(session, category)
            logger.info("  Found %s products", len(products))
            for product in products:
                listings.append(
                    ScrapedListing(
                        country_code=self.country_code,
                        store_id=self.store_id,
                        store_name=self.store_name,
                        product_name=product["name"],
                        price=float(product["price"]),
                        category=product.get("category", category["name"]),
                        product_id=str(product.get("product_id", "")),
                        unit_price=product.get("unit_price"),
                        brand=product.get("brand"),
                    )
                )
            time.sleep(0.1)
        return listings
