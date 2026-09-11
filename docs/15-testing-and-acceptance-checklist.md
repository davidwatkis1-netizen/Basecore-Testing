# 15. Testing and Acceptance Checklist

## 15.1 Sample test sites (recommended profile spread)

Select 3–5 real or realistic sites spanning the risk spectrum so testing exercises every
module meaningfully:

1. **Straightforward infill** — small settlement-envelope site, no flood/heritage/ecology
   constraint, existing frontage access (expected result: proceed_to_feasibility).
2. **Flood-constrained site** — partial Flood Zone 3 overlap (expected result: gate_issue on
   flood category, recommendation likely monitor or approach_landowner depending on other
   scores).
3. **Green Belt / policy-constrained site** — outside settlement boundary, in Green Belt
   (expected result: hard_stop or high score on planning_principle_policy, recommendation
   reject or monitor).
4. **Heritage-sensitive site** — adjacent to a Listed Building/Conservation Area (expected
   result: gate_issue on heritage category, additional assessment flagged).
5. **Brownfield ex-commercial/institutional site** — former garage/yard/nursery with likely
   ground contamination indicators (expected result: gate_issue on ground_contamination,
   opportunity score high on brownfield_redevelopment_benefit).

## 15.2 Functional test checklist

**Site creation**
- [ ] Address search returns correct location and postcode
- [ ] UPRN search returns correct location
- [ ] OS grid reference search returns correct location
- [ ] Lat/long search returns correct location
- [ ] what3words search returns correct location
- [ ] Point-drop creates a site centred on the clicked location
- [ ] Polygon draw tool creates an accurate boundary (spot-check area against a known value)
- [ ] GeoJSON upload parses correctly
- [ ] KML upload parses correctly
- [ ] GPX upload parses correctly
- [ ] DXF upload parses correctly
- [ ] Shapefile ZIP upload parses correctly
- [ ] CSV coordinate upload parses correctly
- [ ] Invalid/corrupt file upload shows a clear error, does not crash
- [ ] Editing a boundary preserves the previous version and increments version number
- [ ] Area (ha/sqm) is correct to within 1% of an independently calculated reference value
- [ ] All 15 metadata fields (brief §2 Step 1) save and are editable

**Screening**
- [ ] Screening run completes for each of the 5 test sites without unhandled errors
- [ ] Buffer distances (50/250/500 m default) are configurable and take effect on rerun
- [ ] Each live-integrated layer returns expected features for at least one test site with a
      known ground truth (verified manually against the source website)
  - [ ] Green Belt
  - [ ] Settlement boundary
  - [ ] Flood Zone 2/3
  - [ ] Listed Buildings
  - [ ] SSSI/statutory ecological designations
  - [ ] BGS geology
  - [ ] Nearby planning applications
- [ ] A deliberately unreachable/broken data source produces a logged data-gap, not a silent
      omission or an application crash
- [ ] Rerunning a screen after a boundary edit produces a new screening_run tied to the new
      boundary version, and old runs remain retrievable

**Map dashboard**
- [ ] All basemaps load (aerial, road, OS-style)
- [ ] Layer toggle/opacity/legend work for every layer
- [ ] Measure tool accurate to within 1 m over a 100 m test line
- [ ] Feature-identify shows correct source, name, reference, distance
- [ ] Markup (point/line/polygon annotation) saves and reloads correctly as a named version
- [ ] Screenshot/print export includes scale bar, north arrow, legend, attribution
- [ ] Buffer rings render at the correct configured distances

**Modules**
- [ ] Title/ownership manual fields save; disclaimer always visible; document upload reaches
      SharePoint successfully
- [ ] Each of the 7 technical assessment theme panels saves all listed fields correctly
- [ ] Data-confidence tagging is visibly distinct (automated/manual/opinion/assumption/
      unverified) in the UI for at least one field of each type
- [ ] Commercial appraisal: RLV, Net Sale Proceeds and Promoter Fee formulas verified against
      an independent spreadsheet calculation for all 5 test sites
- [ ] Risk scoring: suggested scores match the pseudocode rules in `07-risk-scoring-engine.md`
      for each test site's known constraint profile
- [ ] Score override requires and stores a rationale; audit log captures the change
- [ ] Recommendation logic produces the expected output category for each of the 5 test sites
      (per §15.1 expected results)

**Reporting**
- [ ] Generated DOCX contains all 10 sections in the correct order with correct content
- [ ] All disclaimer text is present verbatim (cover, footer, appendix)
- [ ] Every mapped constraint referenced in the report cites its data source and retrieval date
- [ ] PDF conversion visually matches the DOCX (spot-check maps, tables, page breaks)
- [ ] Confidentiality classification is shown correctly on cover and every page footer
- [ ] Report approval workflow restricts "approve for issue" to senior reviewer role

**Audit & security**
- [ ] Every create/update/delete on site, boundary, score, title, commercial data produces an
      audit_log entry with correct before/after values
- [ ] Audit log export (CSV/PDF) is complete and correctly filtered by date/user/event type
- [ ] A user without the required role cannot access a restricted endpoint (verified for at
      least: external_consultant blocked from commercial data; read_only blocked from all
      writes)
- [ ] Confidentiality classification restricts visibility as configured
- [ ] No API key or secret appears in client-side network traffic or source code

## 15.3 Non-functional / quality gates

- [ ] All automated unit/integration tests pass in CI
- [ ] No high/critical severity findings in dependency vulnerability scan
- [ ] No high/critical severity findings in a basic OWASP-aligned security review (see
      `16-assumptions-licensing-and-professional-advice.md` §16.4 checklist)
- [ ] Page load and screening-run time acceptable for a business-hours single-office user base
      (target: screening run completes in under 60 seconds for a typical 0.5 ha site)
- [ ] Data-source registry accurately reflects live licence status for every integrated layer

## 15.4 Sign-off

UAT is complete when every checklist item above is ticked for all 5 test sites, the
implementation team has reviewed the results with a BASECORE senior reviewer, and any
outstanding defects are either fixed or explicitly accepted (logged with rationale) before
go-live.
