"""Shared contracts for grocery store scrapers."""

from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import asdict, dataclass
from typing import Any


@dataclass(frozen=True)
class ScrapedListing:
    """Normalized raw listing shape emitted by store scrapers."""

    country_code: str
    store_id: str
    store_name: str
    product_name: str
    price: float
    category: str
    product_id: str = ""
    unit_price: str | None = None
    brand: str | None = None
    product_url: str | None = None

    def to_legacy_product(self) -> dict[str, Any]:
        """Convert to the legacy grocery_prices.json product shape."""
        payload = {
            "name": self.product_name,
            "price": self.price,
            "unit_price": self.unit_price,
            "category": self.category,
            "product_id": self.product_id,
            "store": self.store_name,
        }
        if self.brand:
            payload["brand"] = self.brand
        return payload

    def to_dict(self) -> dict[str, Any]:
        """Expose the shared shape for future country/store pipelines."""
        return asdict(self)


class StoreScraper(ABC):
    """Common interface for country/store grocery sources."""

    country_code: str
    store_id: str
    store_name: str

    @abstractmethod
    def scrape(self) -> list[ScrapedListing]:
        """Return scraped listings for one store."""

