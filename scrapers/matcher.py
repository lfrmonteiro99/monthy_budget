"""PT canonical product matching helpers."""

from __future__ import annotations

import re
import unicodedata
from dataclasses import replace

from .models import CanonicalProduct, ListingMatchResult, MatchingResult, StoreListing

_REMOVE_WORDS_RE = re.compile(
    r"\b(continente|pingo\s*doce|auchan|mimosa|pack|emb|bio)\b",
    re.IGNORECASE,
)
_NON_WORD_RE = re.compile(r"[^a-z0-9\s]")
_SPACE_RE = re.compile(r"\s+")


def _strip_accents(value: str) -> str:
    normalized = unicodedata.normalize("NFD", value)
    return "".join(char for char in normalized if unicodedata.category(char) != "Mn")


def _normalize_title(value: str) -> str:
    value = _strip_accents(value.lower())
    value = _REMOVE_WORDS_RE.sub(" ", value)
    value = _NON_WORD_RE.sub(" ", value)
    value = _SPACE_RE.sub(" ", value).strip()
    return value


def _title_tokens(value: str) -> set[str]:
    return {token for token in _normalize_title(value).split() if len(token) >= 4}


def _size_matches(listing: StoreListing, canonical: CanonicalProduct) -> bool:
    if listing.base_unit and canonical.base_unit and listing.base_unit != canonical.base_unit:
        return False
    if listing.base_quantity is not None and canonical.base_quantity is not None:
        return abs(listing.base_quantity - canonical.base_quantity) < 0.001
    if listing.size_value is not None and canonical.size_value is not None:
        return listing.size_unit == canonical.size_unit and abs(listing.size_value - canonical.size_value) < 0.001
    return True


def _match_by_store_product_id(listing: StoreListing, canonicals: list[CanonicalProduct]) -> CanonicalProduct | None:
    for canonical in canonicals:
        source_product_ids = canonical.source_product_ids or {}
        known_ids = source_product_ids.get(listing.store_id, ())
        if listing.store_product_id and listing.store_product_id in known_ids:
            return canonical
    return None


def _score_title_match(listing: StoreListing, canonical: CanonicalProduct) -> float:
    listing_tokens = _title_tokens(listing.raw_title)
    canonical_tokens = _title_tokens(canonical.normalized_name)
    if not listing_tokens or not canonical_tokens:
        return 0.0

    intersection = listing_tokens & canonical_tokens
    coverage = len(intersection) / len(canonical_tokens)
    precision = len(intersection) / len(listing_tokens)
    score = (coverage * 0.7) + (precision * 0.3)
    if _size_matches(listing, canonical):
        score += 0.1
    return min(round(score, 2), 1.0)


def match_pt_store_listings(
    listings: list[StoreListing],
    canonical_products: list[CanonicalProduct],
) -> MatchingResult:
    matched_listings: list[StoreListing] = []
    match_results: list[ListingMatchResult] = []
    matched_count = 0
    unmatched_count = 0
    low_confidence_count = 0

    for listing in listings:
        stable_match = _match_by_store_product_id(listing, canonical_products)
        if stable_match is not None:
            matched_listings.append(replace(listing, canonical_product_id=stable_match.id))
            match_results.append(
                ListingMatchResult(
                    listing_id=listing.id,
                    canonical_product_id=stable_match.id,
                    match_method="store_product_id",
                    match_confidence=1.0,
                    review_required=False,
                )
            )
            matched_count += 1
            continue

        best_canonical = None
        best_score = 0.0
        for canonical in canonical_products:
            score = _score_title_match(listing, canonical)
            if score > best_score:
                best_score = score
                best_canonical = canonical

        if best_canonical is None or best_score < 0.55:
            matched_listings.append(listing)
            match_results.append(
                ListingMatchResult(
                    listing_id=listing.id,
                    canonical_product_id=None,
                    match_method="unmatched",
                    match_confidence=0.0,
                    review_required=False,
                )
            )
            unmatched_count += 1
            continue

        review_required = best_score < 0.9
        match_results.append(
            ListingMatchResult(
                listing_id=listing.id,
                canonical_product_id=best_canonical.id,
                match_method="normalized_title",
                match_confidence=best_score,
                review_required=review_required,
            )
        )

        if review_required:
            matched_listings.append(listing)
            unmatched_count += 1
            low_confidence_count += 1
        else:
            matched_listings.append(replace(listing, canonical_product_id=best_canonical.id))
            matched_count += 1

    return MatchingResult(
        listings=matched_listings,
        match_results=match_results,
        matched_count=matched_count,
        unmatched_count=unmatched_count,
        low_confidence_count=low_confidence_count,
    )
