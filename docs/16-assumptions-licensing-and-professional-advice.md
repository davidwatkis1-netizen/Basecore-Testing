# 16. Assumptions, Source-Licensing Constraints, and Items Requiring External Professional Advice

## 16.1 Key assumptions made in this specification

1. BASECORE holds, or will procure, a Microsoft 365 tenant with Entra ID capable of
   application SSO registration (standard on Business Premium/E-series plans).
2. BASECORE's data-protection lead (or an appointed DPO/adviser) will own the Article 30
   record of processing and privacy notice for landowner/agent personal data handled by the
   Tool — this specification describes the technical controls only, not the legal GDPR
   compliance sign-off itself.
3. Buffer distances (50 m/250 m/500 m) and the risk-scoring thresholds in
   `07-risk-scoring-engine.md` are starting defaults based on the brief and general UK
   planning-screening practice; they should be reviewed and calibrated by BASECORE's senior
   planning/technical staff against real case outcomes during UAT.
4. The 10 named local planning authorities are assumed to each publish planning-application
   registers and, in most cases, some GIS layers, but **not** all LPAs publish a consistent
   set of open GIS layers (e.g. Local Wildlife Sites, TPOs, Article 4 Directions vary widely
   in availability) — the MVP backlog treats these as "screen where available, else
   reference/link-out," and this gap should be re-checked as each LPA's data offering
   changes.
5. Costs in `14-implementation-programme-and-costs.md` are indicative UK 2026 market ranges
   for planning purposes, not quotations.

## 16.2 Source-licensing constraints (read before integrating any dataset)

- **Open Government Licence v3.0 (OGL)** covers most central-government and many local-
  government datasets (planning.data.gov.uk, Environment Agency, Historic England, Natural
  England/MAGIC, DfT). OGL permits copying, adapting and commercial use provided the source
  is acknowledged — the Tool must display the required attribution text per
  `05-data-source-register.md`/`.csv` for every OGL layer shown.
  Licence text: https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/
- **Ordnance Survey** data splits into OS OpenData (OGL-equivalent, free) and OS Data Hub
  Premium/paid-tier data (e.g. higher-resolution basemaps, some NGD API products) — confirm
  which OS product tier is in use before assuming free re-use; OS Data Hub terms:
  https://osdatahub.os.uk/legal/terms
- **British Geological Survey** materials are Crown-copyright-adjacent but licensed
  separately by BGS/UKRI — the Geology of Britain Viewer is free to view; bulk/derived-data
  redistribution requires checking BGS's current terms: https://www.bgs.ac.uk/download/bgs-terms-and-conditions-of-use/
- **HM Land Registry** title/ownership data is **not** to be bulk-scraped or redistributed;
  it is a paid, per-search service intended for named individual searches
  (https://eservices.landregistry.gov.uk/) — the Tool only stores what a user manually
  purchases and uploads, plus a deep link to the official service. Price Paid Data is
  separately OGL-licensed and safe for comparables use.
- **National Underground Asset Register (NUAR)** requires a formal organisational
  data-sharing agreement — do not attempt API access without one in place; treat all
  utilities data as manual/observed until that agreement exists.
- **Woodland Trust Ancient Tree Inventory** and similar charity-held datasets typically
  require attribution and sometimes registration for API/bulk access — confirm current terms
  before automating ingestion at volume.
- **Local planning authority planning registers** are generally public for individual
  lookups but scraping terms vary by council/software vendor (IDOX Public Access, Northgate,
  etc.) — prefer an aggregator with its own terms (e.g. PlanIt) or each council's official
  API/open-data feed where one exists, and always respect robots.txt/rate limits; do not
  bypass CAPTCHAs or authentication.
- **General rule embedded in the architecture**: the data-source registry (`data_source`
  table) is the single gate — a layer is only auto-fetched if its `licence` field is populated
  and `access_method` is one of `wms`/`wfs`/`rest_api` with documented terms; anything else
  defaults to `manual_entry`/`link_out`.

## 16.3 Items requiring external professional advice (not resolved by this Tool)

| Area | Who to instruct | Why the Tool cannot resolve it |
|---|---|---|
| Title, easements, restrictive covenants, right of access | Solicitor / licensed conveyancer | Title plans show general boundaries only (HM Land Registry practice); legal interpretation of deeds/covenants requires qualified legal advice |
| Formal planning strategy and submission | Chartered town planner | Screening identifies policy position; a professional planning judgement and pre-application engagement is required |
| Flood risk assessment, drainage strategy, hydraulic modelling | Chartered civil/drainage engineer | Desktop flood-zone mapping does not model site-specific hydraulics or discharge feasibility |
| Ground investigation and remediation strategy | Geotechnical/geoenvironmental consultant (Phase 1/2) | Desk indicators (former use, geology) are not a substitute for intrusive investigation |
| Ecological surveys and BNG metric calculation | Suitably qualified ecologist | Surveys are seasonally constrained (e.g. bat, great crested newt, breeding bird seasons) and a desk screen cannot determine actual habitat condition |
| Heritage/setting assessment | Heritage consultant / archaeologist | Setting impact requires site-specific visual and historical analysis beyond distance-based screening |
| Highway design, access, TA/TS, S278/S38 | Chartered highway/transport engineer, agreed with the Highway Authority | Adoption status and technical highway design cannot be confirmed from mapping alone |
| Utilities capacity and connection costs | Statutory undertakers (DNO, water/sewerage company, gas, telecoms) via formal enquiry | Only the provider can confirm capacity, connection rights and cost |
| Formal valuation (RICS Red Book) | RICS-registered valuer | The commercial module produces an early-stage screening estimate only, not a Red Book valuation suitable for financing or accounts |
| Tax structuring (SDLT, CGT, VAT on land transactions) | Tax adviser / accountant | Outside the Tool's scope entirely |
| GDPR/data-protection sign-off | DPO or data-protection solicitor | The Tool provides technical controls (access logging, RBAC, retention fields); the legal compliance judgement sits with BASECORE |
| Software security penetration test before go-live | Independent security tester (CREST-accredited or equivalent) | This specification recommends a security review; an independent test is a distinct professional service |

## 16.4 Security, GDPR and licensing review checklist (pre-go-live gate)

- [ ] Entra ID app registration reviewed (least-privilege API permissions, conditional access
      policy applied)
- [ ] RBAC roles tested against the matrix in `01-executive-specification.md` §1.3
- [ ] All secrets in Key Vault; no secrets in source control or environment files committed
      to the repository
- [ ] TLS enforced end-to-end; HSTS enabled
- [ ] Database backups configured and a restore tested at least once before go-live
- [ ] Audit log append-only permissions verified at the database role level
- [ ] Personal data inventory completed (landowner/agent names, contact details) and mapped
      to BASECORE's Article 30 record
- [ ] Data retention schedule agreed and implemented (including for rejected/dead sites)
- [ ] Data-subject access/erasure request process documented and testable
- [ ] Every integrated data source has a populated, current licence record in the
      `data_source` table, matching this document
- [ ] Dependency vulnerability scan run with no unresolved high/critical findings
- [ ] Independent security review or penetration test completed (or formally scheduled) for
      the production environment
- [ ] Legal review of §16.2 licensing constraints completed by BASECORE or its advisers before
      first live use with real landowner/title data

## 16.5 Risk register for the software project itself

| Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|
| A key data source changes its licence terms or API mid-project | Medium | Medium | Data-source registry with licence field is the single control point; quarterly licence review |
| LPA GIS data coverage is inconsistent across the 10 authorities | High | Medium | MVP explicitly treats gaps as "reference/link-out with a logged data gap," not a blocking dependency |
| NUAR/utilities data access is delayed or refused | Medium | Low (already deferred to Phase 2) | Utilities module is manual-first by design; NUAR is additive, not required for MVP |
| Report-generation quality (DOCX template complexity) underestimated | Medium | Medium | Build and pilot the DOCX template early (week 9 is late; consider drafting the template skeleton from week 3 in parallel) |
| Risk-scoring thresholds miscalibrated against real BASECORE judgement | Medium | Medium | UAT explicitly tests suggested scores against the 5 known-profile test sites before go-live; thresholds are config-driven, not hard-coded |
| Small delivery team creates key-person dependency | Medium | Medium | Keep documentation (this repository) current as the source of truth, not tribal knowledge |
| Scope creep from the very large brief into the 10-week MVP window | High | High | This backlog is deliberately split MVP/Phase 2; resist adding Phase 2 items into the MVP sprint plan |
