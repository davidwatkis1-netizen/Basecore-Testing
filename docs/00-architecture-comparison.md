# 0. Rapid-MVP Platform Options — Comparison

Before committing to the bespoke React/FastAPI/PostGIS build recommended for the maintained
product (see `02-architecture.md`), it is worth explicitly comparing lower-code alternatives,
since BASECORE is a small business already on Microsoft 365.

| Criterion | ArcGIS Online (+ Experience Builder) | QGIS (desktop + QGIS Server) | Power BI + Power Apps + Azure Maps (hybrid) | **Bespoke: Next.js/MapLibre + FastAPI + PostGIS** |
|---|---|---|---|---|
| **Cost** | £2,500–£6,000/yr (Creator/Field licences) + storage credits | Free (open source) but needs a VM/hosting for Server and no polished report/report engine | £5–20/user/mo (Power Apps premium) + Azure Maps consumption; cheapest to start if 365 licences already cover base tier | Azure App Service/DB + dev time; lowest recurring licence cost, highest build cost |
| **Build time (MVP)** | 3–5 weeks (configure, not code) | 6–8 weeks (scripting + custom UI needed for a non-GIS end user) | 4–6 weeks but hits a ceiling fast for custom risk-scoring logic and DOCX reports | 6–10 weeks (matches brief's target) |
| **GIS capability** | Excellent — mature drawing, geoprocessing, WFS/WMS ingestion, versioning via feature layers | Excellent for analysis; poor as an *end-user web app* without heavy customisation | Weak-moderate — Azure Maps lacks polygon-drawing/geoprocessing depth; fine for read-only context maps | Excellent — Leaflet/MapLibre/OpenLayers + PostGIS give full control over draw, buffer, spatial join, versioning |
| **Data integration (UK planning/env datasets)** | Good — many UK sources publish Esri REST/WFS layers directly; some are Esri-hosted already | Good — QGIS reads WFS/WMS/GeoPackage natively, best for one-off analysis, weaker for a live multi-user app | Moderate — needs custom connectors for planning.data.gov.uk, EA WMS, etc.; no native GIS join | Full control — direct API/WFS/WMS ingestion into PostGIS with scheduled ETL |
| **Report generation quality** | Moderate — ArcGIS layouts export good maps; the *written* structured report (§6 of the brief) needs a separate Word/PDF engine bolted on | Poor for a polished branded Word/PDF report; would need a separate scripting layer anyway | Power BI exports are dashboard-style, not a structured Board-ready Word/PDF report; Power Automate + a DOCX template can work but is fragile for this much structured content | Best fit — docxtpl/python-docx gives full control over the fixed 10-section report structure required |
| **Audit trail** | Partial — Online has activity logs at org level, not the fine-grained per-field/per-score audit the brief requires | None built-in — would be entirely custom | Partial — Dataverse (Power Apps' database) has built-in audit, but it's a heavyweight platform for a niche schema | Full control — bespoke append-only audit log matching the exact fields required |
| **Scalability** | Scales well, but licence cost scales per user/credit consumption | Scales poorly as a shared multi-user web app without significant engineering | Scales within Power Platform limits (API call/data row limits can bite) | Scales normally as a standard web app; cost scales with Azure consumption, not per-seat GIS licence |
| **Fit for BASECORE's user base** (a handful of engineers/planners, not GIS specialists) | Good — Experience Builder apps are easy for non-GIS staff to use, low training | Poor as end-user tool (QGIS itself is desktop/expert-oriented) | Good — staff already know Power Apps/Teams/SharePoint, low friction | Good once built — but requires the most upfront investment |

### Recommendation

**Hybrid rapid MVP, then migrate to the bespoke build:**

1. **Weeks 0–3 (proof of concept only, optional):** stand up an **ArcGIS Online** map + a
   **Power Apps** form over **Dataverse** to validate the workflow and dataset list with 3–5
   real sites, while the bespoke build is specified/started in parallel. This de-risks the
   requirements before committing full build effort, and costs little if abandoned.
2. **Weeks 0–10 (main track):** build the bespoke **Next.js/MapLibre + FastAPI + PostGIS**
   application described in `02-architecture.md`, because only a bespoke build can satisfy,
   in one coherent system: (a) the fixed 10-section DOCX/PDF report with disclaimers baked in,
   (b) the fine-grained audit trail across scores/boundaries/uploads, and (c) the 14+10
   category risk-scoring engine with hard-stop logic — all *hard requirements* in this brief
   that no low-code platform delivers out of the box without extensive customisation that
   erodes its own cost/time advantage.
3. Use **Power BI** only as a secondary reporting surface (a portfolio dashboard across all
   sites for Board review), reading from the same PostgreSQL database via a read replica or
   scheduled export — not as the system of record.
4. Use **Azure Maps** only for geocoding/routing utility calls (e.g. distance-to-station,
   postcode lookup) where a paid API is more reliable than a free one — not as the primary
   mapping SDK.

This avoids the trap of building a "quick" Power Platform app that then needs to be rebuilt
in year two once report complexity and audit requirements outgrow it, while still using
ArcGIS Online, if BASECORE already licenses it, to validate the concept fast.
