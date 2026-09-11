# Backend scaffold (FastAPI)

Thin, runnable starting point for the API described in `../docs/04-api-endpoints.md`. It is
**not** the production implementation — persistence is in-memory (`app/services/site_store.py`)
and the screening engine (`app/services/screening.py`) uses fixture data rather than live
data-source queries. Both are clearly marked as scaffolding to be replaced per
`../docs/10-mvp-backlog.md` items #2–#4, against the schema in `../database/schema.sql`.

## What works today

- Site creation with a GeoJSON boundary (`POST /api/v1/sites`), with real area (ha/sqm)
  calculation via reprojection to EPSG:27700 (British National Grid).
- Boundary version listing (`GET /api/v1/sites/{id}/boundaries`).
- A screening run (`POST /api/v1/sites/{id}/screenings`) that demonstrates the
  within-site/immediate/context/comparables buffer-band classification logic from
  `../docs/06-gis-layer-catalogue.md` §6.1, against a fixture feature (real data-source
  integration is an MVP backlog item, not yet built).

## Running locally

```bash
python3 -m venv .venv && source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
# Interactive API docs at http://localhost:8000/docs
```

## Tests

```bash
pytest tests/ -v
```

## Next steps (see docs/10-mvp-backlog.md)

1. Replace `SiteStore` with a SQLAlchemy/GeoAlchemy2 repository against `database/schema.sql`,
   writing an `audit_log` row on every mutation.
2. Replace the `DEMO_FEATURES` fixture in `screening.py` with live WFS/WMS/REST queries against
   the sources registered in `docs/05-data-source-register.md`, pushing the intersect/distance
   logic into PostGIS (`ST_Intersects`/`ST_Distance`) rather than Shapely-in-process.
3. Add the remaining routers listed in `docs/04-api-endpoints.md` (title, technical,
   commercial, scoring, reports, audit).
4. Wire Entra ID OIDC token validation and RBAC dependency injection.
