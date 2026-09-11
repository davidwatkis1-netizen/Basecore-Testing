# 10. MVP Backlog (Ranked)

Target: deployable MVP in 6–10 weeks (see `14-implementation-programme-and-costs.md` for the
week-by-week programme). Ranked by priority; each item includes user stories and acceptance
criteria. Story points are relative (S/M/L/XL) for a small team (2–3 developers).

## P0 — Foundation (must exist before anything else is testable)

### 1. Auth, RBAC and project scaffold (XL)
**User story:** As a BASECORE analyst, I can sign in with my Microsoft 365 account and see
only the features my role permits.
**Acceptance criteria:**
- Entra ID SSO login works; unauthenticated requests to any `/api/v1/*` route (except
  `/healthz`) return 401.
- Roles from `01-executive-specification.md` §1.3 are enforced server-side on at least one
  endpoint per role tier (verified by automated test).
- CI pipeline runs lint + unit tests on every PR.

### 2. Site CRUD + boundary creation (all input methods) (XL)
**User story:** As an analyst, I can create a site by drawing, uploading, or searching for a
location, and see it saved with a version history.
**Acceptance criteria:**
- All input methods in brief §2 Step 1 work end-to-end: address/postcode/UPRN/grid-ref/
  lat-long/what3words search, point drop, polygon draw, upload of GeoJSON/KML/GPX/DXF/
  Shapefile-ZIP/CSV.
- Area (ha and sqm) is calculated correctly to within 1% against a known reference polygon.
- Editing a boundary creates a new version; old versions remain viewable.
- All 15 metadata fields listed in brief §2 Step 1 are captured and editable.

### 3. Database schema + audit logging middleware (L)
**User story:** As an admin, I can see who did what and when for any site.
**Acceptance criteria:** every create/update/delete on `site`, `site_boundary_version`,
`risk_score`, `commercial_appraisal`, `title_record` writes an `audit_log` row with
before/after JSON; audit log is exportable as CSV.

## P1 — Core screening workflow

### 4. Data-source registry + at least 6 live automated layers (L)
**User story:** As an analyst, when I create a site, I automatically see Green Belt,
settlement boundary, Flood Zone 2/3, Listed Buildings, SSSI/LWS, and BGS geology intersecting
my site and buffers, each cited to source and retrieval date.
**Acceptance criteria:** 6 layers from `06-gis-layer-catalogue.md` ingest live via WFS/WMS/API
per the registered licence; `screening_result` rows populate correctly for a known test site;
a failed retrieval is logged in `data_retrieval_log` and shown as a data gap, not silently
dropped.

### 5. Map dashboard (M)
**User story:** As an analyst, I can view my site on a map with the screened layers, measure
distances, and identify features.
**Acceptance criteria:** layer panel with legend/opacity works for all live layers; measure
tool accurate to within 1 m over 100 m; feature-identify shows source/reference/distance;
scale bar, north arrow and attribution are always visible; screenshot export produces a
usable PNG.

### 6. Planning history module (M)
**User story:** As an analyst, I can see nearby planning applications and appeals and rate
their relevance.
**Acceptance criteria:** PlanIt/LPA integration returns applications within the comparables
buffer for a known test site; manual add/edit works; relevance rating and notes persist.

### 7. Manual technical assessment panels (all 7 themes) (L)
**User story:** As an engineer, I can record my technical judgement against each theme with
the specific fields listed in the brief.
**Acceptance criteria:** every field listed in brief §3.3–§3.8 exists and validates; each
field is tagged with a data-confidence level; panels save per-site and are versionless
(latest state) but changes are audit-logged.

### 8. Title & ownership module (S)
**User story:** As an analyst, I can record title information and flag off-site risks.
**Acceptance criteria:** manual fields save; disclaimer banner always shown; document upload
routes to SharePoint via Graph API; "features outside boundary" flag surfaces on the risk tab.

## P1 — Assessment and output

### 9. Risk & opportunity scoring engine (14 + 10 categories) (XL)
**User story:** As a senior reviewer, I can see a suggested score per category based on
evidence, adjust it with a rationale, and get an overall recommendation.
**Acceptance criteria:** suggested-score rules in `07-risk-scoring-engine.md` implemented for
at least the categories with live data feeds; all 14/10 categories are scorable manually even
where no automated feed exists yet; recommendation logic produces one of the 4 outputs;
score changes require rationale and are audit-logged.

### 10. Commercial appraisal module + calculations (M)
**User story:** As a commercial lead, I can enter GDV/cost assumptions and see the residual
land value, net sale proceeds and promoter fee calculated automatically.
**Acceptance criteria:** formulas match brief §3.9 exactly; results update live; every
appraisal is dated and versioned; "not a formal valuation" statement always shown.

### 11. Report generation (DOCX + PDF) (XL)
**User story:** As an analyst, I can generate a professional report covering all 10 sections
in the brief, ready to send to the Board.
**Acceptance criteria:** DOCX generated from docxtpl matches the outline in
`08-report-template-outline.md` section-for-section; PDF conversion succeeds and matches the
DOCX content; all disclaimers present verbatim; report stores source/retrieval-date citations
for every mapped constraint referenced.

### 12. Audit log export + data-gap reporting (S)
**User story:** As an admin, I can export a complete audit trail for a site for a Board query
or dispute.
**Acceptance criteria:** export includes every event type listed in brief §5; data gaps
(failed retrievals) are listed explicitly, not silently omitted.

## P2 — Usability polish (still within MVP window if time allows)

### 13. Map markup/annotation save-as-version (S)
### 14. Portfolio dashboard (table + map view, filters) (M)
### 15. Saved search / re-run screening on demand with change detection (S)

## Out of scope for MVP (see Phase 2 backlog)

BNG unit calculator, NUAR integration, Power BI portfolio reporting, mobile view, multi-firm
tenancy, automated Land Registry API integration, neighbourhood-plan policy text mining,
scenario-based sensitivity Monte Carlo modelling, external consultant portal.
