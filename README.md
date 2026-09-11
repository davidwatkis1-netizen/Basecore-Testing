# BASECORE Land Promotion Site Assessment Tool

A secure, auditable web application for BASECORE Ltd to screen early-stage land-promotion
opportunities (typically 3–15 dwellings, 0.15–1.0 ha) across Bedfordshire and Hertfordshire.

Users draw or import a site boundary, the platform automatically screens it against public
UK planning, environmental, heritage and infrastructure datasets within configurable buffers,
records manual technical and commercial inputs, scores risk and opportunity across 14 + 10
categories, and generates a professional, evidence-referenced Word/PDF site-screening report.

**This tool performs early-stage desktop screening only.** It does not confirm ownership,
legal access, planning permission, highway adoption, utility capacity, drainage consent,
ecological status, ground conditions or valuation. Formal due diligence from legal, planning,
engineering, ecological, environmental, valuation and financial advisers is always required
before any commitment of funds or exchange of contracts. See
[`docs/16-assumptions-licensing-and-professional-advice.md`](docs/16-assumptions-licensing-and-professional-advice.md).

## What's in this repository

This repository currently contains the **full product specification and a starter technical
scaffold** (database schema, API skeleton, mapping component skeleton). It is the foundation
for the build described in the MVP backlog — it is not yet a deployable application.

| # | Deliverable | Location |
|---|---|---|
| 1 | Executive product specification | [`docs/01-executive-specification.md`](docs/01-executive-specification.md) |
| 2 | System architecture (Mermaid) | [`docs/02-architecture.md`](docs/02-architecture.md) |
| 3 | Database schema | [`docs/03-database-schema.md`](docs/03-database-schema.md), [`database/schema.sql`](database/schema.sql) |
| 4 | API endpoint list | [`docs/04-api-endpoints.md`](docs/04-api-endpoints.md) |
| 5 | Data-source register (UK public sources) | [`docs/05-data-source-register.md`](docs/05-data-source-register.md) / [`.csv`](docs/05-data-source-register.csv) |
| 6 | GIS layer catalogue | [`docs/06-gis-layer-catalogue.md`](docs/06-gis-layer-catalogue.md) |
| 7 | Risk-scoring rules & pseudocode | [`docs/07-risk-scoring-engine.md`](docs/07-risk-scoring-engine.md) |
| 8 | Report template outline | [`docs/08-report-template-outline.md`](docs/08-report-template-outline.md) |
| 9 | UI wireframe descriptions | [`docs/09-ui-wireframes.md`](docs/09-ui-wireframes.md) |
| 10 | MVP backlog (ranked) | [`docs/10-mvp-backlog.md`](docs/10-mvp-backlog.md) |
| 11 | Phase 2 backlog | [`docs/11-phase2-backlog.md`](docs/11-phase2-backlog.md) |
| 12 | Sample site-assessment JSON payload | [`docs/12-sample-site-assessment.json`](docs/12-sample-site-assessment.json) |
| 13 | Sample report executive summary | [`docs/13-sample-executive-summary.md`](docs/13-sample-executive-summary.md) |
| 14 | Implementation programme & costs | [`docs/14-implementation-programme-and-costs.md`](docs/14-implementation-programme-and-costs.md) |
| 15 | Testing & acceptance checklist | [`docs/15-testing-and-acceptance-checklist.md`](docs/15-testing-and-acceptance-checklist.md) |
| 16 | Assumptions, licensing constraints, professional-advice items | [`docs/16-assumptions-licensing-and-professional-advice.md`](docs/16-assumptions-licensing-and-professional-advice.md) |

Also see [`docs/00-architecture-comparison.md`](docs/00-architecture-comparison.md) for the
ArcGIS Online / QGIS / Power BI / Power Apps / Azure Maps / hybrid build-option comparison.

## Starter scaffold

- `database/schema.sql` — PostgreSQL + PostGIS schema matching `docs/03-database-schema.md`.
- `backend/` — FastAPI skeleton (site CRUD, screening trigger, risk-register, report-generation
  stubs) matching the API list. Not wired to real data sources yet — see MVP backlog.
- `frontend/` — Next.js + MapLibre GL skeleton (site map, draw-boundary component) matching the
  UI wireframes. Not wired to the backend yet — see MVP backlog.

Both scaffolds are intentionally thin: they establish the architecture and contracts described
in the docs so the MVP backlog (`docs/10-mvp-backlog.md`) can be executed directly against them,
rather than being a finished product.

## UK English

All product copy, reports and documentation use UK English and UK planning/legal terminology.
