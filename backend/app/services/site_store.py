"""In-memory site repository — MVP scaffold placeholder only.

This exists so the API contract in docs/04-api-endpoints.md is runnable/demonstrable without
a provisioned PostgreSQL+PostGIS instance. It is intentionally NOT the real implementation:
production must replace this with a SQLAlchemy/GeoAlchemy2 repository against
database/schema.sql (MVP backlog item #2/#3), including the audit-log write on every mutation.
"""
from __future__ import annotations

from datetime import datetime, timezone
from itertools import count
from uuid import UUID, uuid4

from app.models.site import Site, SiteBoundaryVersion, SiteCreate
from app.services.geometry import area_ha_sqm, geojson_to_bng, bng_to_geojson

_reference_counter = count(1)


class SiteStore:
    def __init__(self) -> None:
        self._sites: dict[UUID, Site] = {}
        self._boundaries: dict[UUID, list[SiteBoundaryVersion]] = {}

    def _next_reference(self) -> str:
        year = datetime.now(timezone.utc).year
        return f"BAS-{year}-{next(_reference_counter):04d}"

    def create(self, payload: SiteCreate) -> Site:
        site = Site(
            site_reference=self._next_reference(),
            site_name=payload.site_name,
            address=payload.address,
            postcode=payload.postcode,
            lpa_name=payload.lpa_name,
            current_land_use=payload.current_land_use,
            proposed_development_type=payload.proposed_development_type,
            dwelling_capacity_low=payload.dwelling_capacity_low,
            dwelling_capacity_base=payload.dwelling_capacity_base,
            dwelling_capacity_high=payload.dwelling_capacity_high,
            status=payload.status,
            confidentiality=payload.confidentiality,
        )
        self._sites[site.id] = site
        self._boundaries[site.id] = []

        if payload.boundary_geojson is not None:
            self.add_boundary_version(
                site.id, payload.boundary_geojson, payload.boundary_source_method
            )
        return self.get(site.id)

    def add_boundary_version(
        self, site_id: UUID, geojson: dict, source_method
    ) -> SiteBoundaryVersion:
        geom_bng = geojson_to_bng(geojson)
        area_ha, area_sqm = area_ha_sqm(geom_bng)

        existing = self._boundaries[site_id]
        for v in existing:
            v.is_current = False

        version = SiteBoundaryVersion(
            id=uuid4(),
            site_id=site_id,
            version_number=len(existing) + 1,
            geometry=bng_to_geojson(geom_bng),
            area_sqm=area_sqm,
            area_ha=area_ha,
            source_method=source_method,
            is_current=True,
        )
        existing.append(version)
        site = self._sites[site_id]
        site.current_boundary = version
        site.updated_at = datetime.now(timezone.utc)
        return version

    def list(self) -> list[Site]:
        return list(self._sites.values())

    def get(self, site_id: UUID) -> Site | None:
        return self._sites.get(site_id)

    def list_boundary_versions(self, site_id: UUID) -> list[SiteBoundaryVersion]:
        return self._boundaries.get(site_id, [])


site_store = SiteStore()
