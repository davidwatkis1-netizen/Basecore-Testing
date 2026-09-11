-- BASECORE Land Promotion Site Assessment Tool
-- PostgreSQL + PostGIS schema (MVP)
-- Coordinate reference systems: store canonical geometry in EPSG:27700 (OSGB36 / British
-- National Grid) for accurate metric buffering/area, expose EPSG:4326 to the frontend on read.

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto; -- gen_random_uuid()

-- ============================================================================
-- Reference / lookup tables
-- ============================================================================

CREATE TABLE local_planning_authority (
    id              SMALLSERIAL PRIMARY KEY,
    name            TEXT NOT NULL UNIQUE,          -- e.g. 'Central Bedfordshire Council'
    ons_code        TEXT,                            -- ONS local authority code
    planning_portal_url TEXT,
    cil_zone_notes  TEXT
);

CREATE TABLE app_user (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entra_object_id TEXT NOT NULL UNIQUE,           -- Microsoft Entra ID subject
    display_name    TEXT NOT NULL,
    email           TEXT NOT NULL UNIQUE,
    role            TEXT NOT NULL CHECK (role IN
                        ('analyst','senior_reviewer','commercial_lead',
                         'external_consultant','admin','read_only')),
    is_active       BOOLEAN NOT NULL DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE data_source (
    id                  SERIAL PRIMARY KEY,
    name                TEXT NOT NULL UNIQUE,
    provider            TEXT NOT NULL,
    url                 TEXT NOT NULL,
    licence             TEXT NOT NULL,              -- e.g. 'OGL v3.0', 'Organisational subscription'
    access_method       TEXT NOT NULL CHECK (access_method IN
                            ('wms','wfs','rest_api','manual_download','manual_entry','link_out')),
    update_frequency    TEXT,                       -- e.g. 'Monthly', 'Ad hoc / on request'
    geographic_coverage TEXT,
    data_quality_notes  TEXT,
    required_attribution TEXT,
    last_successful_retrieval TIMESTAMPTZ,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE
);

-- ============================================================================
-- Sites
-- ============================================================================

CREATE TABLE site (
    id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_reference          TEXT NOT NULL UNIQUE,   -- e.g. 'BAS-2026-0042'
    site_name               TEXT NOT NULL,
    address                 TEXT,
    postcode                TEXT,
    lpa_id                  SMALLINT REFERENCES local_planning_authority(id),
    current_land_use        TEXT,
    proposed_development_type TEXT,
    dwelling_capacity_low   INTEGER,
    dwelling_capacity_base  INTEGER,
    dwelling_capacity_high  INTEGER,
    status                  TEXT NOT NULL DEFAULT 'lead' CHECK (status IN
                                ('lead','desktop_review','owner_contacted','exclusivity',
                                 'feasibility','planning','consented','marketed','sold',
                                 'rejected','on_hold')),
    confidentiality         TEXT NOT NULL DEFAULT 'internal' CHECK (confidentiality IN
                                ('internal','restricted','strictly_confidential')),
    created_by              UUID REFERENCES app_user(id),
    created_at              TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE site_boundary_version (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id         UUID NOT NULL REFERENCES site(id) ON DELETE CASCADE,
    version_number  INTEGER NOT NULL,
    geom            GEOMETRY(Polygon, 27700) NOT NULL,
    area_sqm        NUMERIC GENERATED ALWAYS AS (ST_Area(geom)) STORED,
    area_ha         NUMERIC GENERATED ALWAYS AS (ST_Area(geom) / 10000.0) STORED,
    source_method   TEXT CHECK (source_method IN
                        ('drawn','uploaded_geojson','uploaded_kml','uploaded_gpx',
                         'uploaded_dxf','uploaded_shapefile','uploaded_csv','gis_import','point_buffer')),
    uploaded_file_ref TEXT,                          -- SharePoint/Blob reference
    is_current      BOOLEAN NOT NULL DEFAULT TRUE,
    created_by      UUID REFERENCES app_user(id),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (site_id, version_number)
);
CREATE INDEX idx_site_boundary_geom ON site_boundary_version USING GIST (geom);

CREATE TABLE site_note (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id     UUID NOT NULL REFERENCES site(id) ON DELETE CASCADE,
    body        TEXT NOT NULL,
    category    TEXT CHECK (category IN
                    ('general','landowner_contact','legal','planning','technical','commercial')),
    created_by  UUID REFERENCES app_user(id),
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE site_attachment (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id         UUID NOT NULL REFERENCES site(id) ON DELETE CASCADE,
    file_name       TEXT NOT NULL,
    storage_location TEXT NOT NULL,                 -- SharePoint/OneDrive item URL or Blob path
    document_type   TEXT CHECK (document_type IN
                        ('title_register','title_plan','deed','photo','survey_report',
                         'correspondence','consultant_report','other')),
    uploaded_by     UUID REFERENCES app_user(id),
    uploaded_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- Screening (automated desk-screening runs)
-- ============================================================================

CREATE TABLE screening_run (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id             UUID NOT NULL REFERENCES site(id) ON DELETE CASCADE,
    boundary_version_id UUID NOT NULL REFERENCES site_boundary_version(id),
    buffer_immediate_m  INTEGER NOT NULL DEFAULT 50,
    buffer_context_m    INTEGER NOT NULL DEFAULT 250,
    buffer_comparables_m INTEGER NOT NULL DEFAULT 500,
    status              TEXT NOT NULL DEFAULT 'pending' CHECK (status IN
                            ('pending','running','complete','failed','partial')),
    requested_by        UUID REFERENCES app_user(id),
    started_at          TIMESTAMPTZ,
    completed_at        TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE screening_result (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    screening_run_id UUID NOT NULL REFERENCES screening_run(id) ON DELETE CASCADE,
    data_source_id  INTEGER NOT NULL REFERENCES data_source(id),
    theme           TEXT NOT NULL CHECK (theme IN
                        ('planning_policy','title_ownership','flood_drainage','ecology_trees_bng',
                         'heritage_archaeology','ground_contamination','highways_access',
                         'utilities_infrastructure')),
    feature_name    TEXT,
    feature_reference TEXT,
    feature_geom    GEOMETRY(Geometry, 27700),
    buffer_band     TEXT NOT NULL CHECK (buffer_band IN ('within_site','immediate','context','comparables')),
    distance_m      NUMERIC,
    raw_attributes  JSONB,                          -- full feature attribute payload as retrieved
    retrieved_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    screening_interpretation TEXT,                  -- analyst/engine-generated plain-English note
    required_next_action TEXT,
    data_confidence TEXT CHECK (data_confidence IN ('automated','manual_entry','professional_opinion',
                                                       'assumption','unverified'))
);
CREATE INDEX idx_screening_result_geom ON screening_result USING GIST (feature_geom);
CREATE INDEX idx_screening_result_run ON screening_result(screening_run_id);

CREATE TABLE data_retrieval_log (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    screening_run_id UUID REFERENCES screening_run(id) ON DELETE CASCADE,
    data_source_id  INTEGER NOT NULL REFERENCES data_source(id),
    request_url     TEXT,
    http_status     INTEGER,
    success         BOOLEAN NOT NULL,
    error_message   TEXT,
    retrieved_at    TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- Planning history (per-site records of nearby applications/appeals)
-- ============================================================================

CREATE TABLE planning_application_record (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id             UUID NOT NULL REFERENCES site(id) ON DELETE CASCADE,
    reference           TEXT NOT NULL,
    address             TEXT,
    proposal            TEXT,
    status              TEXT,
    decision_date       DATE,
    decision_outcome    TEXT CHECK (decision_outcome IN
                            ('approved','refused','withdrawn','pending','appeal_allowed',
                             'appeal_dismissed','lapsed','unknown')),
    document_links      TEXT[],
    distance_m          NUMERIC,
    relevance_rating    SMALLINT CHECK (relevance_rating BETWEEN 1 AND 5),
    analyst_notes       TEXT,
    created_by          UUID REFERENCES app_user(id),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- Title / ownership module
-- ============================================================================

CREATE TABLE title_record (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id             UUID NOT NULL REFERENCES site(id) ON DELETE CASCADE,
    title_number        TEXT,
    registered_proprietor TEXT,
    tenure              TEXT CHECK (tenure IN ('freehold','leasehold','unregistered','unknown')),
    title_plan_date     DATE,
    charges             TEXT,
    restrictions        TEXT,
    covenants           TEXT,
    easements           TEXT,
    access_notes        TEXT,
    legal_review_status TEXT CHECK (legal_review_status IN
                            ('not_started','solicitor_instructed','review_in_progress','reviewed')),
    features_outside_boundary_flag BOOLEAN NOT NULL DEFAULT FALSE,
    features_outside_boundary_notes TEXT,
    created_by          UUID REFERENCES app_user(id),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ============================================================================
-- Technical manual-assessment panels (highways, utilities, drainage etc.)
-- Stored as JSONB per theme to keep the schema adaptable without migrations
-- for every new field required by engineers; validated at API layer.
-- ============================================================================

CREATE TABLE technical_assessment (
    id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id     UUID NOT NULL REFERENCES site(id) ON DELETE CASCADE,
    theme       TEXT NOT NULL CHECK (theme IN
                    ('highways_access','drainage_flood','utilities','ground_contamination',
                     'ecology_bng','heritage','amenity_design')),
    fields      JSONB NOT NULL DEFAULT '{}'::jsonb,  -- theme-specific manual fields, see docs/03
    data_confidence TEXT NOT NULL DEFAULT 'manual_entry' CHECK (data_confidence IN
                        ('manual_entry','professional_opinion','assumption','unverified')),
    updated_by  UUID REFERENCES app_user(id),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (site_id, theme)
);

-- ============================================================================
-- Commercial appraisal
-- ============================================================================

CREATE TABLE commercial_appraisal (
    id                          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id                     UUID NOT NULL REFERENCES site(id) ON DELETE CASCADE,
    version_number              INTEGER NOT NULL,
    dwelling_mix                JSONB,               -- [{type, count, gia_sqm}, ...]
    sales_comparables           JSONB,               -- [{address, price, date, source}, ...]
    assumed_sales_value_per_sqm NUMERIC,
    gdv                         NUMERIC,
    affordable_housing_pct      NUMERIC,
    build_cost_per_sqm          NUMERIC,
    external_works_cost         NUMERIC,
    abnormals_cost              NUMERIC,
    professional_fees_pct       NUMERIC,
    cil_s106_bng_cost           NUMERIC,
    finance_cost                NUMERIC,
    sales_disposal_cost_pct     NUMERIC,
    contingency_pct             NUMERIC,
    developer_profit_pct        NUMERIC,
    residual_land_value         NUMERIC,             -- GDV - development costs - developer profit
    landowner_minimum_expectation NUMERIC,
    promotion_costs             NUMERIC,
    land_sale_costs             NUMERIC,
    promoter_percentage         NUMERIC,
    net_sale_proceeds           NUMERIC,             -- gross land sale price - sale costs - promotion costs
    promoter_fee                NUMERIC,             -- net sale proceeds * promoter percentage
    waterfall_notes             JSONB,
    assumptions_date            DATE NOT NULL,
    is_formal_valuation         BOOLEAN NOT NULL DEFAULT FALSE CHECK (is_formal_valuation = FALSE),
    created_by                  UUID REFERENCES app_user(id),
    created_at                  TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (site_id, version_number)
);

-- ============================================================================
-- Risk & opportunity scoring
-- ============================================================================

CREATE TABLE risk_score (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id             UUID NOT NULL REFERENCES site(id) ON DELETE CASCADE,
    assessment_version  INTEGER NOT NULL,
    category            TEXT NOT NULL CHECK (category IN
                            ('planning_principle_policy','title_ownership_legal_access',
                             'highways_transport','flood_risk_drainage','utilities_infrastructure',
                             'ground_contamination','ecology_trees_bng','heritage_archaeology_landscape',
                             'amenity_design_capacity','planning_obligations_delivery_costs',
                             'market_demand_sales_evidence','residual_value_promotion_economics',
                             'programme_funding','landowner_alignment_site_control')),
    score               SMALLINT NOT NULL CHECK (score BETWEEN 1 AND 5),
    rag_status          TEXT NOT NULL CHECK (rag_status IN ('green','amber','red')),
    evidence_sources    TEXT[],
    key_facts           TEXT,
    assumptions         TEXT,
    uncertainties       TEXT,
    recommended_next_action TEXT,
    estimated_cost_to_resolve NUMERIC,
    estimated_programme_effect_weeks NUMERIC,
    classification      TEXT NOT NULL CHECK (classification IN ('hard_stop','gate_issue','manageable')),
    scored_by           UUID REFERENCES app_user(id),
    scored_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    change_rationale    TEXT,                        -- required when superseding a prior score
    UNIQUE (site_id, assessment_version, category)
);

CREATE TABLE opportunity_score (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id             UUID NOT NULL REFERENCES site(id) ON DELETE CASCADE,
    assessment_version  INTEGER NOT NULL,
    category            TEXT NOT NULL CHECK (category IN
                            ('brownfield_redevelopment_benefit','settlement_service_proximity',
                             'planning_precedent','existing_access_use','yield_optimisation_potential',
                             'engineering_resolvable_constraints','owner_partnership_potential',
                             'buyer_pool','local_plan_call_for_sites_route','post_consent_value_uplift')),
    score               SMALLINT NOT NULL CHECK (score BETWEEN 1 AND 5),
    narrative           TEXT,
    scored_by           UUID REFERENCES app_user(id),
    scored_at           TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (site_id, assessment_version, category)
);

CREATE TABLE assessment_recommendation (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id             UUID NOT NULL REFERENCES site(id) ON DELETE CASCADE,
    assessment_version  INTEGER NOT NULL,
    recommendation      TEXT NOT NULL CHECK (recommendation IN
                            ('reject','monitor','approach_landowner','proceed_to_feasibility')),
    basis               TEXT NOT NULL,
    critical_uncertainties TEXT NOT NULL,
    next_stage_scope    TEXT NOT NULL,
    next_stage_cost_cap NUMERIC,
    decided_by          UUID REFERENCES app_user(id),
    approved_by         UUID REFERENCES app_user(id),
    approved_at         TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (site_id, assessment_version)
);

-- ============================================================================
-- Reports
-- ============================================================================

CREATE TABLE report (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id         UUID NOT NULL REFERENCES site(id) ON DELETE CASCADE,
    assessment_version INTEGER NOT NULL,
    report_version  INTEGER NOT NULL,
    docx_storage_ref TEXT,
    pdf_storage_ref TEXT,
    confidentiality TEXT NOT NULL,
    generated_by    UUID REFERENCES app_user(id),
    generated_at    TIMESTAMPTZ NOT NULL DEFAULT now(),
    is_approved_for_issue BOOLEAN NOT NULL DEFAULT FALSE,
    approved_by     UUID REFERENCES app_user(id),
    approved_at     TIMESTAMPTZ,
    UNIQUE (site_id, report_version)
);

-- ============================================================================
-- Audit trail (append-only)
-- ============================================================================

CREATE TABLE audit_log (
    id              BIGSERIAL PRIMARY KEY,
    site_id         UUID REFERENCES site(id) ON DELETE CASCADE,
    user_id         UUID REFERENCES app_user(id),
    event_type      TEXT NOT NULL,                  -- e.g. 'boundary_edited','score_changed','report_generated'
    entity_type     TEXT,
    entity_id       UUID,
    before_value    JSONB,
    after_value     JSONB,
    metadata        JSONB,
    occurred_at     TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_audit_log_site ON audit_log(site_id, occurred_at);

-- Application role should be granted INSERT/SELECT only on audit_log (no UPDATE/DELETE):
-- REVOKE UPDATE, DELETE ON audit_log FROM app_role;
