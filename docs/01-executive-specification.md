# 1. Executive Product Specification

## 1.1 Product name

**BASECORE Land Promotion Site Assessment Tool** ("the Tool").

## 1.2 Purpose

A secure, internal web application used by BASECORE Ltd (UK civil and environmental engineering
consultancy) to carry out consistent, evidence-based, auditable **early-stage desktop screening**
of land-promotion opportunities in Bedfordshire and Hertfordshire, before committing the
£10,000–£15,000 initial feasibility budget.

The Tool does **not** replace statutory searches, specialist surveys, legal title investigation,
or professional advice. Its output is a screening judgement to support a **proceed / stop /
watch / approach-landowner** decision, with a clearly capped next-stage scope.

## 1.3 Users and roles

| Role | Description | Typical permissions |
|---|---|---|
| Analyst | Desk-based screening, data entry, map markup | Create/edit sites, run screens, edit manual fields, draft reports |
| Senior Reviewer / Director | Approves recommendations before circulation | All Analyst rights + approve/lock reports, override scores with rationale |
| Commercial Lead | Enters/reviews commercial model | Edit commercial module, view all |
| External Consultant (limited) | Read-only or scoped input on invitation | View assigned site(s) only, upload documents to assigned site |
| Admin | User/role management, data-source configuration, audit export | Full access + system configuration |
| Read-only / Board | View approved reports and dashboards only | View published reports only |

Authentication via **Microsoft Entra ID (Azure AD) SSO**, consistent with BASECORE's Microsoft
365 estate. Role-based access control (RBAC) enforced at API level, not just UI.

## 1.4 Core capabilities

1. **Site creation** — address/postcode/UPRN/grid-ref/lat-long/what3words search, point drop,
   polygon draw, file upload (GeoJSON/KML/GPX/DXF/Shapefile-ZIP/CSV), or selection of a saved
   site. Full boundary version history.
2. **Automatic desk-screening** — on boundary creation/edit, screens the site polygon plus
   configurable 50 m / 250 m / 500 m buffers against the registered dataset catalogue
   (see `06-gis-layer-catalogue.md`), producing a structured, source-cited constraints table.
   Re-runnable on demand.
3. **Interactive map dashboard** — MapLibre GL-based GIS viewer: basemaps, layer control,
   legend, transparency, measure/print/screenshot, feature-identify, markup/annotation layers,
   saved assessment versions, scale bar, north arrow, data-source/retrieval-date attribution.
4. **Structured modules** for planning, title/ownership, flood/drainage, ecology/trees/BNG,
   heritage/archaeology, ground/contamination, highways/access, utilities, and commercial
   appraisal — each separating **automated data**, **manual entry**, **professional opinion**,
   **assumption** and **unverified information**.
5. **Risk-and-opportunity assessment engine** — 14 scored risk categories + 10 scored
   opportunity categories, each with RAG status, evidence, assumptions, next action, cost/
   programme impact and hard-stop/gate/manageable classification, rolling up to one of four
   recommendations (see `07-risk-scoring-engine.md`).
6. **Full audit trail** — every dataset retrieval, boundary edit, score change, upload,
   landowner contact, cost commitment and report issued, exportable and immutable
   (append-only log with user, timestamp, before/after values).
7. **Report generation** — professional .docx (editable) and PDF export following the fixed
   structure in `08-report-template-outline.md`, branded, with mandatory disclaimers baked in.
8. **Data-source registry** — every layer/API is registered with licence, update frequency,
   last successful retrieval, coverage and required attribution; the UI will not present a
   dataset that lacks a recorded, in-date licence basis.

## 1.5 Non-functional requirements

- **Security**: Entra ID SSO + MFA, RBAC, encryption at rest and in transit (TLS 1.2+),
  Azure Key Vault for secrets, no client-side storage of confidential site data beyond session.
- **Data residency**: UK South / UK West Azure regions where available for the service tier used.
- **GDPR**: personal data (landowner contacts, agent details) minimised, access-logged, retained
  per a documented retention schedule, and included in BASECORE's Article 30 record of
  processing; data-subject-rights process documented (see `16-assumptions-licensing-and-
  professional-advice.md`).
- **Availability**: business-hours priority (08:00–19:00 UK, Mon–Fri); no 24/7 SLA required
  for MVP.
- **Auditability**: every automated fact traceable to a source, URL and retrieval timestamp;
  every manual fact traceable to an author and timestamp; scores never silently overwritten
  (versioned, with rationale required for any change).
- **Licensing compliance**: only datasets whose licence terms (principally the **Open
  Government Licence v3.0**, INSPIRE, and named free-tier API terms) permit this use are
  integrated automatically; anything requiring a paid/organisational licence (e.g. OS
  Premium data, NUAR, full Land Registry title data) is either manually entered, linked out
  to the provider's own portal, or gated behind a documented organisational subscription —
  never scraped.
- **Extensibility**: new local planning authorities, buffer distances, dataset sources and
  risk-category weightings must be configurable without code changes (config/admin-panel
  driven).

## 1.6 Explicit exclusions (what the Tool must never assert)

The Tool must never state or imply, from mapped data alone, that:

- Planning permission is guaranteed or likely to be granted.
- Legal access, ransom-free access, or right of way exists.
- A road is publicly adopted (unless confirmed by the highway authority).
- Utilities capacity or connection rights exist.
- Drainage discharge (surface water or foul) is feasible or consented.
- A site is "flood safe."
- Ground conditions are suitable for development.
- Ecological status, heritage setting impact, or contamination condition is resolved.
- A valuation, residual land value or GDV figure is a formal valuation (RICS Red Book) —
  all commercial outputs are labelled "early-stage screening estimate, not a formal valuation."

These exclusions are enforced in the UI copy, the report template's fixed disclaimer blocks,
and the assessment engine's output wording (see `07-risk-scoring-engine.md` §7.5).

## 1.7 Geographic and market scope (MVP)

Local planning authorities: Bedford Borough, Central Bedfordshire, Luton, North Hertfordshire,
Stevenage, East Hertfordshire, Welwyn Hatfield, Dacorum, St Albans, Hertsmere.

Typical opportunity profile: 3–15 dwellings, 0.15–1.0 ha, infill/backland/brownfield/surplus
institutional/settlement-edge sites, screened to a £10,000–£15,000 spend cap before a
proceed/stop gate.
