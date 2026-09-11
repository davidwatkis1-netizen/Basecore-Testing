# 4. API Endpoint List

FastAPI backend, versioned under `/api/v1`. All endpoints require a valid Entra ID bearer
token except `/healthz`. RBAC enforced per-endpoint (see `01-executive-specification.md` §1.3).
All list endpoints support pagination (`?page=&page_size=`) and filtering by site status/LPA.

## 4.1 Auth & users

| Method | Path | Description |
|---|---|---|
| GET | `/healthz` | Liveness/readiness probe |
| GET | `/api/v1/me` | Current authenticated user + role |
| GET | `/api/v1/users` | List users (admin) |
| PATCH | `/api/v1/users/{user_id}` | Update role/active status (admin) |

## 4.2 Sites

| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/sites` | List/search sites (filter by status, LPA, confidentiality) |
| POST | `/api/v1/sites` | Create a site (metadata; boundary added separately or inline) |
| GET | `/api/v1/sites/{site_id}` | Get full site record |
| PATCH | `/api/v1/sites/{site_id}` | Update site metadata |
| DELETE | `/api/v1/sites/{site_id}` | Soft-delete/archive a site (admin/senior reviewer) |
| GET | `/api/v1/sites/search/location` | Address / postcode / UPRN / grid-ref / lat-long / what3words lookup (proxies OS Places API / what3words API) |

## 4.3 Boundaries

| Method | Path | Description |
|---|---|---|
| POST | `/api/v1/sites/{site_id}/boundaries` | Create new boundary version (GeoJSON body, or `source_method`=upload with file) |
| POST | `/api/v1/sites/{site_id}/boundaries/upload` | Upload GeoJSON/KML/GPX/DXF/Shapefile-ZIP/CSV, server converts to canonical geometry |
| GET | `/api/v1/sites/{site_id}/boundaries` | List boundary version history |
| GET | `/api/v1/sites/{site_id}/boundaries/{version_id}` | Get one boundary version |
| POST | `/api/v1/sites/{site_id}/boundaries/{version_id}/set-current` | Mark a historic version as current (creates audit entry) |

## 4.4 Screening

| Method | Path | Description |
|---|---|---|
| POST | `/api/v1/sites/{site_id}/screenings` | Trigger a new automatic desk-screening run (optionally override buffer distances) |
| GET | `/api/v1/sites/{site_id}/screenings` | List screening runs for a site |
| GET | `/api/v1/screenings/{run_id}` | Get screening run status/summary |
| GET | `/api/v1/screenings/{run_id}/results` | List screening results (filter by theme, buffer_band, data_source) |
| GET | `/api/v1/screenings/{run_id}/results/{result_id}` | Single result detail (raw attributes, source link) |
| GET | `/api/v1/screenings/{run_id}/data-gaps` | List failed/partial dataset retrievals for this run |
| GET | `/api/v1/screenings/{run_id}/map-layers` | GeoJSON FeatureCollections per theme for the map dashboard |

## 4.5 Planning history

| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/sites/{site_id}/planning-applications` | List nearby planning applications/appeals |
| POST | `/api/v1/sites/{site_id}/planning-applications` | Add/import a planning application record |
| PATCH | `/api/v1/planning-applications/{id}` | Edit relevance rating / analyst notes |

## 4.6 Title & ownership

| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/sites/{site_id}/title` | Get title/ownership record(s) |
| POST | `/api/v1/sites/{site_id}/title` | Create/update title record (manual entry) |
| POST | `/api/v1/sites/{site_id}/title/documents` | Upload title register/plan/deed (routes to SharePoint via Graph API) |
| GET | `/api/v1/sites/{site_id}/title/land-registry-link` | Return a deep link to HM Land Registry's own search service (no scraping) |

## 4.7 Technical assessment panels

| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/sites/{site_id}/technical/{theme}` | Get manual technical panel (highways_access, drainage_flood, utilities, ground_contamination, ecology_bng, heritage, amenity_design) |
| PUT | `/api/v1/sites/{site_id}/technical/{theme}` | Upsert manual technical panel fields (validated against theme JSON Schema) |

## 4.8 Commercial appraisal

| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/sites/{site_id}/commercial` | List commercial appraisal versions |
| POST | `/api/v1/sites/{site_id}/commercial` | Create new commercial appraisal version |
| GET | `/api/v1/commercial/{appraisal_id}` | Get one appraisal (with calculated RLV/net proceeds/promoter fee) |
| POST | `/api/v1/commercial/{appraisal_id}/calculate` | Recalculate RLV, net sale proceeds, promoter fee from inputs |

## 4.9 Risk & opportunity scoring

| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/sites/{site_id}/assessments` | List assessment versions |
| POST | `/api/v1/sites/{site_id}/assessments` | Create new assessment version (snapshot for scoring) |
| GET | `/api/v1/assessments/{assessment_id}/risk-scores` | Get 14-category risk scores |
| PUT | `/api/v1/assessments/{assessment_id}/risk-scores/{category}` | Set/update a risk score (requires `change_rationale` if superseding) |
| GET | `/api/v1/assessments/{assessment_id}/opportunity-scores` | Get 10-category opportunity scores |
| PUT | `/api/v1/assessments/{assessment_id}/opportunity-scores/{category}` | Set/update an opportunity score |
| POST | `/api/v1/assessments/{assessment_id}/recommendation` | Compute/set the final recommendation (engine-suggested, analyst-confirmed) |
| GET | `/api/v1/assessments/{assessment_id}/recommendation` | Get current recommendation |

## 4.10 Reports

| Method | Path | Description |
|---|---|---|
| POST | `/api/v1/assessments/{assessment_id}/reports` | Generate DOCX + PDF report for an assessment version |
| GET | `/api/v1/reports/{report_id}` | Get report metadata/status |
| GET | `/api/v1/reports/{report_id}/download` | Download DOCX or PDF (`?format=docx|pdf`) |
| POST | `/api/v1/reports/{report_id}/approve` | Mark report approved for issue (senior reviewer only) |

## 4.11 Notes, attachments, markup

| Method | Path | Description |
|---|---|---|
| GET/POST | `/api/v1/sites/{site_id}/notes` | List/add notes |
| GET/POST | `/api/v1/sites/{site_id}/attachments` | List/upload attachments |
| GET/POST | `/api/v1/sites/{site_id}/markup-layers` | List/save named map-markup versions (annotations, drawn access arrows etc.) |

## 4.12 Data-source registry & admin

| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/data-sources` | List registered data sources (licence, coverage, last retrieval) |
| POST | `/api/v1/data-sources` | Register a new data source (admin) |
| PATCH | `/api/v1/data-sources/{id}` | Update licence/status/frequency (admin) |
| GET | `/api/v1/local-planning-authorities` | List the 10 in-scope LPAs |

## 4.13 Audit

| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/sites/{site_id}/audit-log` | Full audit trail for a site (paginated, filterable by event_type/date) |
| GET | `/api/v1/sites/{site_id}/audit-log/export` | Export audit trail as CSV/PDF |

## 4.14 Portfolio / dashboard

| Method | Path | Description |
|---|---|---|
| GET | `/api/v1/dashboard/summary` | Portfolio counts by status/LPA/recommendation, for Board-level view |
| GET | `/api/v1/dashboard/map` | Portfolio-wide map of all active sites |
