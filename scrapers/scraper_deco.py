"""Scraper for DECO PROteste supermarket price index data.

DECO publishes aggregate price indices (not individual product prices) comparing
the cost of a ~250-product basket across 9 Portuguese online supermarkets.
This scraper extracts the latest index rankings.
"""

import logging
import requests
from bs4 import BeautifulSoup

logger = logging.getLogger(__name__)

DECO_URL = "https://www.deco.proteste.pt/familia-consumo/supermercado/supermercados-online-qual-vende-mais-barato"
DECO_NEWS_URL = "https://www.deco.proteste.pt/familia-consumo/supermercado/noticias/supermercado-online-lidera-ranking-precos-baixos"

HEADERS = {
    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
                  "(KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
    "Accept-Language": "pt-PT,pt;q=0.9,en;q=0.5",
}

# Known indices from DECO PROteste 2025 annual ranking (fallback if scraping fails)
FALLBACK_INDICES = {
    "period": "2025-annual",
    "source": "DECO PROteste (fallback - cached data)",
    "basket_size": 250,
    "rankings": [
        {"store": "Continente", "index": 100, "rank": 1},
        {"store": "Pingo Doce", "index": 101, "rank": 2},
        {"store": "Froiz", "index": 101, "rank": 2},
        {"store": "Auchan", "index": 102, "rank": 4},
        {"store": "360Hyper", "index": 102, "rank": 4},
        {"store": "Intermarché", "index": 103, "rank": 6},
        {"store": "Minipreço", "index": 104, "rank": 7},
        {"store": "Apolónia", "index": 108, "rank": 8},
        {"store": "El Corte Inglés", "index": 110, "rank": 9},
    ],
}


def _parse_index_table(soup: BeautifulSoup) -> list[dict] | None:
    """Try to extract ranking table from DECO page."""
    tables = soup.select("table")
    for table in tables:
        rows = table.select("tr")
        rankings = []
        for row in rows[1:]:  # Skip header
            cells = row.select("td, th")
            if len(cells) >= 2:
                store_name = cells[0].get_text(strip=True)
                try:
                    index_val = int(cells[-1].get_text(strip=True))
                    rankings.append({"store": store_name, "index": index_val})
                except ValueError:
                    continue
        if len(rankings) >= 3:
            # Sort and assign ranks
            rankings.sort(key=lambda x: x["index"])
            for i, r in enumerate(rankings):
                r["rank"] = i + 1
            return rankings
    return None


def _parse_from_text(soup: BeautifulSoup) -> list[dict] | None:
    """Try to extract rankings from article text when no table is present."""
    text = soup.get_text()
    known_stores = [
        "Continente", "Pingo Doce", "Auchan", "Froiz", "360Hyper",
        "Intermarché", "Minipreço", "Apolónia", "El Corte Inglés",
    ]
    rankings = []
    for store in known_stores:
        # Look for patterns like "Continente (100)" or "Continente: índice 100"
        import re
        patterns = [
            rf"{re.escape(store)}[^0-9]*?(\d{{2,3}})",
            rf"índice\s+(\d{{2,3}})[^0-9]*?{re.escape(store)}",
        ]
        for pattern in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                index_val = int(match.group(1))
                if 90 <= index_val <= 130:  # Sanity check
                    rankings.append({"store": store, "index": index_val})
                    break

    if len(rankings) >= 3:
        rankings.sort(key=lambda x: x["index"])
        for i, r in enumerate(rankings):
            r["rank"] = i + 1
        return rankings
    return None


def scrape() -> dict:
    """Scrape DECO PROteste price index data. Returns aggregate rankings, not individual products."""
    session = requests.Session()

    for url in [DECO_URL, DECO_NEWS_URL]:
        try:
            resp = session.get(url, headers=HEADERS, timeout=20)
            if resp.status_code != 200:
                continue

            soup = BeautifulSoup(resp.text, "lxml")

            # Try table extraction first
            rankings = _parse_index_table(soup)
            if rankings:
                logger.info(f"DECO: extracted {len(rankings)} store rankings from table")
                return {
                    "period": "latest",
                    "source": "DECO PROteste",
                    "source_url": url,
                    "basket_size": 250,
                    "rankings": rankings,
                }

            # Try text extraction
            rankings = _parse_from_text(soup)
            if rankings:
                logger.info(f"DECO: extracted {len(rankings)} store rankings from text")
                return {
                    "period": "latest",
                    "source": "DECO PROteste",
                    "source_url": url,
                    "basket_size": 250,
                    "rankings": rankings,
                }

        except requests.RequestException as e:
            logger.warning(f"Failed to fetch DECO page {url}: {e}")
            continue

    logger.warning("DECO: using fallback cached data")
    return FALLBACK_INDICES
