# Frontend scaffold (Next.js + MapLibre GL)

Thin, runnable starting point for the map dashboard described in `../docs/09-ui-wireframes.md`.

## What works today

- `/` — portfolio table view, reading from the backend's `GET /api/v1/sites`.
- `/sites/new` — draw-a-boundary wizard (click to add points, double-click to finish),
  computes area server-side and creates the site via `POST /api/v1/sites`.
- `/sites/[id]` — site workspace: map showing the saved boundary, "Run screening" button
  calling `POST /api/v1/sites/{id}/screenings` and listing results.

Not yet built (see `../docs/10-mvp-backlog.md`): address/postcode/UPRN/grid-ref/what3words
search, file upload (GeoJSON/KML/GPX/DXF/Shapefile/CSV), the full layer control panel/legend,
measure tool, feature-identify, markup layers, and the remaining workspace tabs (Planning,
Title & Ownership, Technical, Commercial, Risk & Opportunity, Reports, Audit Log).

## Running locally

Requires the backend running at `http://localhost:8000` (see `../backend/README.md`).

```bash
npm install
npm run dev
# http://localhost:3000
```

Set `NEXT_PUBLIC_API_BASE_URL` if the backend runs elsewhere.

## Basemap note

The scaffold uses OpenStreetMap raster tiles purely as a placeholder basemap. Production
must switch to the OS Data Hub Maps API (or a licensed aerial imagery provider) per
`../docs/05-data-source-register.md` §5.8 before any external/BASECORE-branded use, and
credit tiles accordingly.
