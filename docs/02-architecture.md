# 2. System Architecture

## 2.1 Technology choices

| Layer | Choice | Rationale |
|---|---|---|
| Frontend | Next.js (React, TypeScript) | SSR for report/dashboard pages, strong ecosystem, easy Azure Static Web Apps / App Service hosting |
| Mapping | MapLibre GL JS (+ Turf.js for client-side geometry ops) | Open-source, vector-tile performant, no per-seat licence, works with OS Maps API/EA WMS tiles |
| Backend | Python FastAPI | Async, OpenAPI-native (matches `04-api-endpoints.md` directly), strong GIS ecosystem (GeoPandas, Shapely, GDAL/OGR bindings) |
| GIS processing | PostGIS, GeoPandas, GDAL/OGR, Shapely | Industry-standard spatial stack; PostGIS does the buffer/intersect screening server-side |
| Database | PostgreSQL 15 + PostGIS 3.4 | Native spatial types/indexes, JSONB for flexible manual-field storage, mature Azure managed offering |
| File storage | SharePoint/OneDrive (via Microsoft Graph) for user-facing documents (title docs, reports); Azure Blob Storage for large raster/GIS extracts and generated PDFs | Keeps end-user documents inside BASECORE's existing 365 governance/retention/DLP policies |
| Auth | Microsoft Entra ID (OIDC/SAML SSO) | Matches existing 365 estate, gives MFA/conditional access for free |
| Reporting | docxtpl + python-docx → LibreOffice headless (`soffice --convert-to pdf`) or Azure Function running Gotenberg for DOCX→PDF | Keeps the DOCX as the editable master; PDF is a rendered export, not a second source of truth |
| Background jobs | Azure Functions / a Celery+Redis worker | Scheduled dataset refresh, screening re-runs, report rendering (all can be slow/blocking) |
| Hosting | Azure App Service (frontend + backend containers), Azure Database for PostgreSQL Flexible Server, Azure Blob Storage, Azure Key Vault, Azure Monitor/App Insights | UK South region; PaaS reduces ops burden for a small team |
| CI/CD | GitHub Actions → Azure | Matches this repository |

## 2.2 High-level architecture

```mermaid
flowchart TB
    subgraph Client["Client (Browser)"]
        UI["Next.js App<br/>Map Dashboard / Forms / Report Viewer"]
    end

    subgraph Azure["Azure (UK South)"]
        subgraph Web["App Service"]
            FE["Next.js SSR Frontend"]
            API["FastAPI Backend<br/>(REST, OpenAPI)"]
        end
        DB[("PostgreSQL + PostGIS<br/>Sites, Screening, Scores, Audit")]
        BLOB[("Azure Blob Storage<br/>Rendered PDFs, raster extracts")]
        KV["Azure Key Vault<br/>API keys, secrets"]
        FUNC["Azure Functions<br/>Scheduled ETL + Report Rendering"]
        MON["Azure Monitor / App Insights<br/>Logs, audit export"]
    end

    subgraph M365["Microsoft 365"]
        ENTRA["Entra ID<br/>SSO + MFA + RBAC groups"]
        SPO["SharePoint / OneDrive<br/>Title docs, uploads, final reports"]
    end

    subgraph External["External UK Data Sources (OGL / public APIs)"]
        PLAN["planning.data.gov.uk<br/>LPA planning portals"]
        EA["Environment Agency<br/>Flood Map / WMS"]
        HE["Historic England NHLE"]
        NE["Natural England / MAGIC"]
        BGS["British Geological Survey"]
        OS["OS Data Hub<br/>(Places, Maps, NGD APIs)"]
        DFT["DfT / NaPTAN / Sustrans NCN"]
        LR["HM Land Registry<br/>(manual/linked, not scraped)"]
    end

    UI <-->|HTTPS/JSON| FE
    FE <-->|Internal| API
    UI -. OIDC login .-> ENTRA
    API -->|RBAC token validation| ENTRA
    API <--> DB
    API <--> BLOB
    API --> KV
    API <-->|Graph API| SPO
    FUNC -->|scheduled pulls, respecting licence terms| PLAN & EA & HE & NE & BGS & OS & DFT
    FUNC --> DB
    FUNC --> BLOB
    API --> MON
    LR -. links out only .-> UI
```

## 2.3 Data flow: creating a site and running a screen

```mermaid
sequenceDiagram
    actor Analyst
    participant FE as Next.js Frontend
    participant API as FastAPI Backend
    participant DB as PostGIS
    participant Cache as Dataset Cache (Blob/DB)
    participant Ext as External Data Sources

    Analyst->>FE: Draw/upload site boundary
    FE->>API: POST /sites (geometry + metadata)
    API->>DB: Insert site + boundary_version(v1)
    API-->>FE: site_id, area, LPA lookup
    Analyst->>FE: Trigger "Run screening"
    FE->>API: POST /sites/{id}/screenings
    API->>DB: Create screening_run (status=running)
    API->>Cache: Check per-layer freshness (per data-source registry)
    alt cached layer stale or missing
        API->>Ext: Fetch WFS/WMS/API within site+buffers (per licence terms)
        Ext-->>API: Features (GeoJSON)
        API->>Cache: Store with retrieval timestamp + source metadata
    end
    API->>DB: Spatial intersect/nearest-distance vs site, 50m, 250m, 500m buffers
    API->>DB: Persist screening_result rows (dataset, feature, distance, buffer_band)
    API->>DB: Update screening_run(status=complete)
    API-->>FE: Screening summary + map layers
    FE-->>Analyst: Constraints table + map, ready for scoring
```

## 2.4 Environments

- **dev** — shared development/test data only, synthetic sites.
- **staging** — mirrors production config, used for UAT against the 3–5 test sites in
  `15-testing-and-acceptance-checklist.md`.
- **production** — BASECORE internal use, Entra ID production tenant, UK South region,
  daily automated backups (35-day retention on PostgreSQL Flexible Server).

## 2.5 Security architecture summary

- All traffic TLS 1.2+; HSTS enabled.
- Entra ID SSO, groups mapped to the roles in `01-executive-specification.md` §1.3.
- API enforces RBAC per-endpoint and per-site confidentiality classification (see schema).
- Secrets (data-provider API keys, storage connection strings) in Key Vault, never in code
  or environment files committed to source control.
- Audit log table is append-only (no UPDATE/DELETE grants for the application role; a
  separate, tightly restricted admin role may perform GDPR erasure requests with a logged
  justification).
- Regular dependency and container image scanning in CI.
- Full checklist in `16-assumptions-licensing-and-professional-advice.md`.
