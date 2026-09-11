"""Geometry helpers: EPSG:4326 (client) <-> EPSG:27700 (canonical, per database/schema.sql).

British National Grid (EPSG:27700) is used for area/buffer calculations because it is a
metric projected CRS accurate across Bedfordshire/Hertfordshire, avoiding the distortion of
computing area/distance directly in WGS84 degrees.
"""
from __future__ import annotations

from typing import Any

from pyproj import Transformer
from shapely.geometry import shape, mapping
from shapely.ops import transform

_TO_BNG = Transformer.from_crs("EPSG:4326", "EPSG:27700", always_xy=True).transform
_TO_WGS84 = Transformer.from_crs("EPSG:27700", "EPSG:4326", always_xy=True).transform


def geojson_to_bng(geojson: dict[str, Any]):
    geom_wgs84 = shape(geojson)
    return transform(_TO_BNG, geom_wgs84)


def bng_to_geojson(geom_bng) -> dict[str, Any]:
    geom_wgs84 = transform(_TO_WGS84, geom_bng)
    return mapping(geom_wgs84)


def area_ha_sqm(geom_bng) -> tuple[float, float]:
    sqm = geom_bng.area
    return round(sqm / 10_000.0, 4), round(sqm, 1)


def buffer_bng(geom_bng, distance_m: float):
    return geom_bng.buffer(distance_m)
