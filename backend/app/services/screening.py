"""Screening engine scaffold.

Implements the buffer-band classification logic described in
docs/06-gis-layer-catalogue.md §6.1, against a small set of hardcoded demonstration features.

Production implementation replaces `DEMO_FEATURES` with live WFS/WMS/REST queries against the
registered data sources in docs/05-data-source-register.md, scoped to each site's bounding box
plus the largest configured buffer, then performs the same intersect/distance logic in PostGIS
(ST_Intersects / ST_Distance) rather than in Python/Shapely — this module exists to make the
buffer-band contract testable and demonstrable without a live database or external API calls.
"""
from __future__ import annotations

from dataclasses import dataclass
from typing import Any
from uuid import UUID, uuid4

from shapely.geometry import shape

from app.services.geometry import buffer_bng, geojson_to_bng

# Illustrative fixed reference features near example Bedfordshire/Hertfordshire test sites.
# Real layers are fetched live per docs/06-gis-layer-catalogue.md.
DEMO_FEATURES: list[dict[str, Any]] = [
    {
        "theme": "planning_policy",
        "feature_name": "Settlement Envelope (demo)",
        "source": "Local Plan Policy Map (demo fixture)",
        "geojson": None,  # None => treated as "within site" for demo purposes when present
    },
]


@dataclass
class ScreeningResult:
    id: UUID
    theme: str
    feature_name: str
    source: str
    buffer_band: str
    distance_m: float


def classify_buffer_band(
    feature_geom, site_geom, immediate_geom, context_geom, comparables_geom
) -> tuple[str | None, float]:
    distance_m = round(feature_geom.distance(site_geom), 1)
    if feature_geom.intersects(site_geom):
        return "within_site", 0.0
    if feature_geom.intersects(immediate_geom):
        return "immediate", distance_m
    if feature_geom.intersects(context_geom):
        return "context", distance_m
    if feature_geom.intersects(comparables_geom):
        return "comparables", distance_m
    return None, distance_m


def run_screening(
    site_boundary_geojson: dict[str, Any],
    buffer_immediate_m: int,
    buffer_context_m: int,
    buffer_comparables_m: int,
) -> list[ScreeningResult]:
    site_geom = geojson_to_bng(site_boundary_geojson)
    immediate = buffer_bng(site_geom, buffer_immediate_m)
    context = buffer_bng(site_geom, buffer_context_m)
    comparables = buffer_bng(site_geom, buffer_comparables_m)

    results: list[ScreeningResult] = []
    for feature in DEMO_FEATURES:
        feature_geom = shape(feature["geojson"]) if feature["geojson"] else site_geom
        band, distance = classify_buffer_band(
            feature_geom, site_geom, immediate, context, comparables
        )
        if band is None:
            continue
        results.append(
            ScreeningResult(
                id=uuid4(),
                theme=feature["theme"],
                feature_name=feature["feature_name"],
                source=feature["source"],
                buffer_band=band,
                distance_m=distance,
            )
        )
    return results
