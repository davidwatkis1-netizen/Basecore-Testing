from __future__ import annotations

from uuid import UUID

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from app.config import settings
from app.services.screening import ScreeningResult, run_screening
from app.services.site_store import site_store

router = APIRouter(prefix="/api/v1", tags=["screening"])


class ScreeningRequest(BaseModel):
    buffer_immediate_m: int = settings.default_buffer_immediate_m
    buffer_context_m: int = settings.default_buffer_context_m
    buffer_comparables_m: int = settings.default_buffer_comparables_m


class ScreeningResponse(BaseModel):
    site_id: UUID
    buffers_m: dict[str, int]
    results: list[ScreeningResult]


@router.post("/sites/{site_id}/screenings", response_model=ScreeningResponse)
def run_site_screening(site_id: UUID, request: ScreeningRequest = ScreeningRequest()) -> ScreeningResponse:
    site = site_store.get(site_id)
    if site is None:
        raise HTTPException(status_code=404, detail="Site not found")
    if site.current_boundary is None:
        raise HTTPException(status_code=400, detail="Site has no boundary to screen")

    results = run_screening(
        site.current_boundary.geometry,
        request.buffer_immediate_m,
        request.buffer_context_m,
        request.buffer_comparables_m,
    )
    return ScreeningResponse(
        site_id=site_id,
        buffers_m={
            "immediate": request.buffer_immediate_m,
            "context": request.buffer_context_m,
            "comparables": request.buffer_comparables_m,
        },
        results=results,
    )
