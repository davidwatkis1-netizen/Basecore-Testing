"""Pydantic schemas for the Site resource.

Mirrors the `site` and `site_boundary_version` tables in database/schema.sql. This scaffold
uses these as the API contract; the persistence layer (see app/services/site_store.py) is an
in-memory stand-in until the real PostGIS-backed repository is built (MVP backlog item #2/#3
in docs/10-mvp-backlog.md).
"""
from __future__ import annotations

from datetime import datetime, timezone
from enum import Enum
from typing import Any
from uuid import UUID, uuid4

from pydantic import BaseModel, Field


class SiteStatus(str, Enum):
    lead = "lead"
    desktop_review = "desktop_review"
    owner_contacted = "owner_contacted"
    exclusivity = "exclusivity"
    feasibility = "feasibility"
    planning = "planning"
    consented = "consented"
    marketed = "marketed"
    sold = "sold"
    rejected = "rejected"
    on_hold = "on_hold"


class Confidentiality(str, Enum):
    internal = "internal"
    restricted = "restricted"
    strictly_confidential = "strictly_confidential"


class BoundarySourceMethod(str, Enum):
    drawn = "drawn"
    uploaded_geojson = "uploaded_geojson"
    uploaded_kml = "uploaded_kml"
    uploaded_gpx = "uploaded_gpx"
    uploaded_dxf = "uploaded_dxf"
    uploaded_shapefile = "uploaded_shapefile"
    uploaded_csv = "uploaded_csv"
    gis_import = "gis_import"
    point_buffer = "point_buffer"


class SiteCreate(BaseModel):
    site_name: str
    address: str | None = None
    postcode: str | None = None
    lpa_name: str | None = None
    current_land_use: str | None = None
    proposed_development_type: str | None = None
    dwelling_capacity_low: int | None = None
    dwelling_capacity_base: int | None = None
    dwelling_capacity_high: int | None = None
    status: SiteStatus = SiteStatus.lead
    confidentiality: Confidentiality = Confidentiality.internal
    boundary_geojson: dict[str, Any] | None = Field(
        default=None, description="GeoJSON Polygon in EPSG:4326, if supplied at creation time"
    )
    boundary_source_method: BoundarySourceMethod | None = None


class SiteBoundaryVersion(BaseModel):
    id: UUID
    site_id: UUID
    version_number: int
    geometry: dict[str, Any]
    area_sqm: float
    area_ha: float
    source_method: BoundarySourceMethod
    is_current: bool = True
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))


class Site(BaseModel):
    id: UUID = Field(default_factory=uuid4)
    site_reference: str
    site_name: str
    address: str | None = None
    postcode: str | None = None
    lpa_name: str | None = None
    current_land_use: str | None = None
    proposed_development_type: str | None = None
    dwelling_capacity_low: int | None = None
    dwelling_capacity_base: int | None = None
    dwelling_capacity_high: int | None = None
    status: SiteStatus = SiteStatus.lead
    confidentiality: Confidentiality = Confidentiality.internal
    created_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    updated_at: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))
    current_boundary: SiteBoundaryVersion | None = None
