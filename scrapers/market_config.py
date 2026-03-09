"""Market configuration loader for multi-country grocery scripts."""

from __future__ import annotations

import json
from functools import lru_cache
from pathlib import Path

CONFIG_DIR = Path(__file__).parent / "config"


@lru_cache(maxsize=1)
def load_market_index() -> dict:
    return json.loads((CONFIG_DIR / "markets.json").read_text(encoding="utf-8"))


@lru_cache(maxsize=None)
def load_market_config(country_code: str) -> dict:
    normalized = country_code.strip().upper()
    path = CONFIG_DIR / f"{normalized}.json"
    if not path.exists():
        raise ValueError(f"unsupported market config: {country_code}")
    return json.loads(path.read_text(encoding="utf-8"))


def store_ids_for_market(country_code: str) -> list[str]:
    config = load_market_config(country_code)
    return [
        store["storeId"]
        for store in config.get("stores", [])
        if store.get("enabled", False)
    ]
