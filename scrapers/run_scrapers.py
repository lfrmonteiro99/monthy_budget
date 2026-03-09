#!/usr/bin/env python3
"""Main orchestrator — runs all scrapers and outputs grocery_prices.json.

Usage:
    python run_scrapers.py                    # Output to default path
    python run_scrapers.py -o /path/to.json   # Custom output path
    python run_scrapers.py --enrich           # Include nutritional data (slower)
"""

import argparse
import json
import logging
import sys
from datetime import datetime, timezone
from pathlib import Path

import scraper_deco
import scraper_openfoodfacts

try:  # Script execution from scrapers/
    from registry import pt_store_scrapers
except ImportError:  # Package execution from repo root/tests
    from .registry import pt_store_scrapers

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("run_scrapers")

DEFAULT_OUTPUT = Path(__file__).parent.parent / "monthy_budget_flutter" / "assets" / "grocery_prices.json"


def _normalize_products(products: list[dict]) -> list[dict]:
    """Deduplicate and normalize product entries."""
    seen = set()
    unique = []
    for p in products:
        key = (p.get("store", ""), p.get("name", "").lower(), p.get("category", ""))
        if key not in seen and p.get("price") and p["price"] > 0:
            seen.add(key)
            # Round prices to 2 decimals
            p["price"] = round(p["price"], 2)
            unique.append(p)
    return unique


def _build_comparison_index(products: list[dict]) -> list[dict]:
    """Build a product comparison index — group similar products across stores.

    Matches products by normalized name similarity across different stores,
    so the app can show "Leite Mimosa 1L: Continente €0.89 vs Pingo Doce €0.92".
    """
    from collections import defaultdict
    import re

    # Brand names and filler words to strip before comparing
    _REMOVE = re.compile(
        r'\b(mimosa|continente|pingo\s*doce|auchan|alpro|parmalat'
        r'|nestl[eé]|danone|pr[eé]sident|nosso\s*talho|nossa\s*peixaria'
        r'|embalad[oa]s?|slim|bio|magro|gordo|meio)\b',
        re.IGNORECASE,
    )
    _UNITS = re.compile(r'\b\d+\s*(ml|l|lt|g|gr|kg|cl|un|emb|pack|cj|doz|dos)\b', re.IGNORECASE)
    _NUMS = re.compile(r'\b\d+\b')
    _PUNCT = re.compile(r'[^\w\s]')
    _SPACE = re.compile(r'\s+')

    def normalize_name(name: str) -> tuple:
        name = name.lower()
        name = _REMOVE.sub(' ', name)
        name = _UNITS.sub(' ', name)
        name = _NUMS.sub(' ', name)
        name = _PUNCT.sub(' ', name)
        name = _SPACE.sub(' ', name).strip()
        # Sort words so "leite uht meio gordo" == "gordo leite meio uht"
        words = tuple(sorted(w for w in name.split() if len(w) > 2))
        return words

    # Group by normalized name key, keeping only the cheapest price per store
    groups: dict[tuple, dict[str, dict]] = defaultdict(dict)
    for p in products:
        key = normalize_name(p["name"])
        if len(key) < 2:  # skip if too little info after stripping
            continue
        store = p["store"]
        entry = {
            "store": store,
            "price": p["price"],
            "unit_price": p.get("unit_price"),
            "product_id": p.get("product_id", ""),
            "original_name": p["name"],
        }
        if store not in groups[key] or p["price"] < groups[key][store]["price"]:
            groups[key][store] = entry

    # Only keep groups with 2+ stores (actual comparison possible)
    comparisons = []
    for _key, store_map in groups.items():
        if len(store_map) >= 2:
            entries = list(store_map.values())
            # Use the longest original name as display name (most descriptive)
            display_name = max((e["original_name"] for e in entries), key=len)
            # Strip original_name from price entries before exposing
            price_entries = [
                {k: v for k, v in e.items() if k != "original_name"}
                for e in entries
            ]
            price_entries.sort(key=lambda x: x["price"])
            cheapest = price_entries[0]
            most_expensive = price_entries[-1]
            savings = round(most_expensive["price"] - cheapest["price"], 2)
            savings_pct = round((savings / most_expensive["price"]) * 100, 1) if most_expensive["price"] > 0 else 0

            comparisons.append({
                "product_name": display_name,
                "prices": price_entries,
                "cheapest_store": cheapest["store"],
                "cheapest_price": cheapest["price"],
                "potential_savings": savings,
                "savings_percent": savings_pct,
            })

    # Sort by biggest savings potential
    comparisons.sort(key=lambda x: x["potential_savings"], reverse=True)
    return comparisons


def _build_category_summary(products: list[dict]) -> list[dict]:
    """Build per-category average price comparison across stores."""
    from collections import defaultdict

    # category -> store -> list of prices
    cat_store_prices = defaultdict(lambda: defaultdict(list))
    for p in products:
        cat = p.get("category", "Outros")
        store = p["store"]
        cat_store_prices[cat][store].append(p["price"])

    summaries = []
    for category, stores in sorted(cat_store_prices.items()):
        store_avgs = {}
        for store, prices in stores.items():
            store_avgs[store] = {
                "avg_price": round(sum(prices) / len(prices), 2),
                "product_count": len(prices),
                "min_price": round(min(prices), 2),
                "max_price": round(max(prices), 2),
            }

        cheapest_store = min(store_avgs, key=lambda s: store_avgs[s]["avg_price"])
        summaries.append({
            "category": category,
            "stores": store_avgs,
            "cheapest_store": cheapest_store,
        })

    return summaries


def run(output_path: Path, enrich_nutrition: bool = False) -> None:
    """Execute all scrapers and write combined JSON output."""
    now = datetime.now(timezone.utc)
    logger.info(f"Starting grocery price scrape at {now.isoformat()}")

    # Run store scrapers
    all_products = []
    scraper_results = {}

    for scraper in pt_store_scrapers():
        try:
            listings = scraper.scrape()
            products = [listing.to_legacy_product() for listing in listings]
            all_products.extend(products)
            scraper_results[scraper.store_name] = {
                "status": "ok",
                "count": len(products),
                "country_code": scraper.country_code,
                "store_id": scraper.store_id,
            }
        except Exception as e:
            logger.error(f"{scraper.store_name} scraper failed: {e}")
            scraper_results[scraper.store_name] = {
                "status": "error",
                "error": str(e),
                "country_code": scraper.country_code,
                "store_id": scraper.store_id,
            }

    # Normalize and deduplicate
    all_products = _normalize_products(all_products)
    logger.info(f"Total unique products after dedup: {len(all_products)}")

    # Canonicalise category names across stores so comparisons and summaries align
    _CATEGORY_MAP = {
        "Frutas": "Frutas e Legumes",
        "Legumes": "Frutas e Legumes",
        "Peixe": "Peixe e Marisco",
    }
    for p in all_products:
        p["category"] = _CATEGORY_MAP.get(p.get("category", ""), p.get("category", ""))

    # Run DECO PROteste scraper
    try:
        deco_data = scraper_deco.scrape()
        scraper_results["DECO PROteste"] = {"status": "ok"}
    except Exception as e:
        logger.error(f"DECO scraper failed: {e}")
        deco_data = scraper_deco.FALLBACK_INDICES
        scraper_results["DECO PROteste"] = {"status": "fallback", "error": str(e)}

    # Run Open Food Facts integration
    try:
        off_data = scraper_openfoodfacts.fetch_all(enrich_nutrition=enrich_nutrition)
        scraper_results["Open Food Facts"] = {
            "status": "ok",
            "open_prices_count": len(off_data.get("open_prices", [])),
        }
    except Exception as e:
        logger.error(f"Open Food Facts failed: {e}")
        off_data = {"open_prices": []}
        scraper_results["Open Food Facts"] = {"status": "error", "error": str(e)}

    # Build comparison indices
    comparison_index = _build_comparison_index(all_products)
    category_summary = _build_category_summary(all_products)

    # Assemble final JSON
    output = {
        "metadata": {
            "scraped_at": now.isoformat(),
            "scraper_version": "1.0.0",
            "scraper_results": scraper_results,
            "total_products": len(all_products),
            "total_comparisons": len(comparison_index),
        },
        "deco_index": deco_data,
        "products": all_products,
        "comparisons": comparison_index,
        "category_summary": category_summary,
        "open_prices": off_data.get("open_prices", []),
        "nutrition": off_data.get("nutrition", {}),
    }

    # Write JSON
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(output, f, ensure_ascii=False, indent=2)

    file_size_kb = output_path.stat().st_size / 1024
    logger.info(f"Wrote {output_path} ({file_size_kb:.1f} KB)")
    logger.info(f"Products: {len(all_products)}, Comparisons: {len(comparison_index)}, Categories: {len(category_summary)}")


def main():
    parser = argparse.ArgumentParser(description="Scrape Portuguese grocery store prices")
    parser.add_argument("-o", "--output", type=Path, default=DEFAULT_OUTPUT, help="Output JSON path")
    parser.add_argument("--enrich", action="store_true", help="Enrich with nutritional data (slower)")
    args = parser.parse_args()

    try:
        run(args.output, enrich_nutrition=args.enrich)
    except Exception as e:
        logger.error(f"Scraper failed: {e}", exc_info=True)
        sys.exit(1)


if __name__ == "__main__":
    main()
