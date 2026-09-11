from __future__ import annotations

from uuid import UUID

from fastapi import APIRouter, HTTPException

from app.models.site import BoundarySourceMethod, Site, SiteBoundaryVersion, SiteCreate
from app.services.site_store import site_store

router = APIRouter(prefix="/api/v1/sites", tags=["sites"])


@router.get("", response_model=list[Site])
def list_sites() -> list[Site]:
    return site_store.list()


@router.post("", response_model=Site, status_code=201)
def create_site(payload: SiteCreate) -> Site:
    return site_store.create(payload)


@router.get("/{site_id}", response_model=Site)
def get_site(site_id: UUID) -> Site:
    site = site_store.get(site_id)
    if site is None:
        raise HTTPException(status_code=404, detail="Site not found")
    return site


@router.get("/{site_id}/boundaries", response_model=list[SiteBoundaryVersion])
def list_boundaries(site_id: UUID) -> list[SiteBoundaryVersion]:
    if site_store.get(site_id) is None:
        raise HTTPException(status_code=404, detail="Site not found")
    return site_store.list_boundary_versions(site_id)


@router.post("/{site_id}/boundaries", response_model=SiteBoundaryVersion, status_code=201)
def add_boundary(
    site_id: UUID, geojson: dict, source_method: BoundarySourceMethod
) -> SiteBoundaryVersion:
    if site_store.get(site_id) is None:
        raise HTTPException(status_code=404, detail="Site not found")
    return site_store.add_boundary_version(site_id, geojson, source_method)
