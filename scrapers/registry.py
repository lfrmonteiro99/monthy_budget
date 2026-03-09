"""Registry for PT grocery scraper adapters."""

from __future__ import annotations

from collections.abc import Callable

try:  # Script execution from scrapers/
    from base import ScrapedListing, StoreScraper
except ImportError:  # Package execution from repo root/tests
    from .base import ScrapedListing, StoreScraper


class FunctionStoreScraper(StoreScraper):
    """Adapter that wraps legacy scraper functions behind StoreScraper."""

    def __init__(
        self,
        *,
        country_code: str,
        store_id: str,
        store_name: str,
        scrape_fn: Callable[[], list[dict]],
    ) -> None:
        self.country_code = country_code
        self.store_id = store_id
        self.store_name = store_name
        self._scrape_fn = scrape_fn

    def scrape(self) -> list[ScrapedListing]:
        listings: list[ScrapedListing] = []
        for raw in self._scrape_fn():
            listings.append(
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
            )
        return listings


def pt_store_scrapers() -> list[StoreScraper]:
    """Current PT grocery scrapers adapted to the shared interface."""
    try:  # Script execution from scrapers/
        import scraper_auchan
        import scraper_continente
        import scraper_pingo_doce
    except ImportError:  # Package execution from repo root/tests
        from . import scraper_auchan, scraper_continente, scraper_pingo_doce

    return [
        scraper_continente.ContinenteScraper(),
        scraper_pingo_doce.PingoDoceScraper(),
        scraper_auchan.AuchanScraper(),
    ]


def es_store_scrapers() -> list[StoreScraper]:
    try:
        import scraper_carrefour_es
        import scraper_mercadona
    except ImportError:
        from . import scraper_carrefour_es, scraper_mercadona

    return [
        scraper_mercadona.MercadonaScraper(),
        scraper_carrefour_es.CarrefourEsScraper(),
    ]


def store_scrapers_for_country(country_code: str) -> list[StoreScraper]:
    normalized = country_code.strip().upper()
    if normalized == "PT":
        return pt_store_scrapers()
    if normalized == "ES":
        return es_store_scrapers()
    raise ValueError(f"unsupported country_code: {country_code}")


def get_store_scraper(country_code: str, store_id: str) -> StoreScraper:
    normalized_store_id = store_id.strip().lower()
    for scraper in store_scrapers_for_country(country_code):
        if scraper.store_id == normalized_store_id:
            return scraper
    raise ValueError(
        f"unsupported store_id '{store_id}' for country_code '{country_code}'"
    )
