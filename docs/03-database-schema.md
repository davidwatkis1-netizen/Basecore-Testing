# 3. Database Schema

Full DDL: [`../database/schema.sql`](../database/schema.sql) (PostgreSQL 15 + PostGIS 3.4).

## 3.1 Design principles

- **Canonical geometry stored in EPSG:27700** (OSGB36 / British National Grid) so that area
  (ha/sqm) and buffer distances (50 m / 250 m / 500 m) are true metric values without
  reprojection error; reprojected to EPSG:4326 (WGS84) on API read for the map client.
- **Every boundary edit creates a new `site_boundary_version` row** rather than mutating
  geometry in place — full version history is a hard requirement (brief §2, "Step 1").
- **Screening results are never overwritten** — each `screening_run` is immutable once
  complete; re-running the screen creates a new run, so historic evidence for a report already
  issued remains reconstructable.
- **Manual technical fields use JSONB** (`technical_assessment.fields`) rather than one column
  per field, because the brief specifies a long, evolving list of manual fields per theme
  (highways, drainage, utilities, ground, ecology, heritage, amenity) — JSONB avoids a
  migration for every new field while the API layer still validates against a versioned
  JSON Schema per theme (kept in `backend/app/schemas/technical_fields/`).
- **`data_confidence` fields everywhere information is entered** implement the brief's
  requirement (§5) to distinguish automatically derived data, manual entry, professional
  opinion, assumption and unverified information.
- **Scores are versioned** (`assessment_version`) and require `change_rationale` when a score
  is revised, satisfying the audit requirement that "changes to scores and rationale" are
  retained.
- **`audit_log` is append-only**: the application's database role is granted `INSERT, SELECT`
  only; no `UPDATE`/`DELETE` grants, so the trail cannot be silently altered.
- **`commercial_appraisal.is_formal_valuation` is hard-constrained to `FALSE`** — a defence in
  depth measure so the schema itself cannot represent a screening output as a formal RICS
  valuation.

## 3.2 Key tables (summary)

| Table | Purpose |
|---|---|
| `local_planning_authority` | Reference list of the 10 in-scope LPAs |
| `app_user` | Entra ID-linked user with RBAC role |
| `data_source` | Data-source registry (see `05-data-source-register.md`) |
| `site` | Core site record (name, ref, LPA, status, confidentiality, capacity) |
| `site_boundary_version` | Versioned polygon geometry, area, source method |
| `site_note` | Free-text notes, categorised |
| `site_attachment` | Uploaded files (title docs, photos, reports) referencing SharePoint/Blob |
| `screening_run` | One automatic desk-screen execution against a boundary version + buffers |
| `screening_result` | Individual constraint/feature found by a screening run, with distance/buffer band |
| `data_retrieval_log` | Per-source success/failure log for each screening run (data-gaps record) |
| `planning_application_record` | Nearby planning applications/appeals, manually reviewed and annotated |
| `title_record` | Manually entered title/ownership data, legal-review status |
| `technical_assessment` | Manual technical panels per theme (JSONB fields) |
| `commercial_appraisal` | Versioned commercial/residual-value model |
| `risk_score` | 14-category risk scores per assessment version |
| `opportunity_score` | 10-category opportunity scores per assessment version |
| `assessment_recommendation` | Final recommendation + basis + next-stage scope per version |
| `report` | Generated DOCX/PDF report metadata, approval status |
| `audit_log` | Append-only event log across the whole system |

## 3.3 Example `technical_assessment.fields` JSON Schema (highways_access theme)

```json
{
  "proposed_access_location": "string",
  "access_width_m": "number",
  "apparent_visibility": "string",
  "level_gradient_concerns": "string",
  "footway_crossing_requirement": "string",
  "refuse_fire_emergency_access": "string",
  "turning_provision": "string",
  "junction_capacity_risk": "low|medium|high",
  "offsite_works_required": "boolean",
  "s278_required": "boolean",
  "s38_required": "boolean",
  "rsa_required": "boolean",
  "ta_ts_required": "boolean",
  "travel_plan_required": "boolean",
  "swept_path_analysis_required": "boolean",
  "third_party_land_required": "boolean",
  "highway_risk_score": "1-5"
}
```

Equivalent JSON Schemas exist for `drainage_flood`, `utilities`, `ground_contamination`,
`ecology_bng`, `heritage`, and `amenity_design`, mirroring the manual fields listed in the
brief §3.3–§3.8.
