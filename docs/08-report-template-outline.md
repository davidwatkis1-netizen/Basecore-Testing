# 8. Report Template Outline

Generated via `docxtpl` from a fixed BASECORE-branded `.docx` template
(`backend/app/templates/site_screening_report.docx`, Jinja-in-Word placeholders), then
converted to PDF server-side. Structure is fixed; content is populated from the site,
screening, technical, commercial and scoring records for the selected assessment version.

## Section-by-section

**1. Cover page**
- BASECORE logo/branding block
- Site name and reference
- Site location (address/postcode, LPA)
- Boundary plan thumbnail
- Report date, report version number, assessment version number
- Confidentiality classification banner (Internal / Restricted / Strictly Confidential)

**2. Executive summary**
- Overall recommendation (one of the four engine outputs) in a coloured banner
- Overall risk rating (average/worst-category RAG)
- Key opportunities (top 3, from opportunity scores)
- Key constraints (top 3 red/hard-stop risk categories)
- Immediate actions (bulleted, from `recommended_next_action` fields)
- Recommended spend cap for next stage (`assessment_recommendation.next_stage_cost_cap`)
- Standard disclaimer block (short form; full form in appendix)

**3. Site description**
- Location narrative, area (ha/sqm), current land use, surroundings
- Site photographs (from `site_attachment`, type=photo)
- Access observations (from technical panel, clearly marked "observation, not confirmed adoption")
- Boundary description and source method

**4. Mapping section** — each plan includes scale bar, north arrow, legend, data source(s) +
retrieval date, standard mapping disclaimer, and the site boundary overlaid:
- Location plan
- Aerial plan
- Planning-policy constraints plan
- Flood and drainage constraints plan
- Heritage and ecology constraints plan
- Ground/geology/contamination indicators plan
- Highways/access/PROW plan
- Utilities/infrastructure observations plan
- Annotated opportunity and constraint plan (from saved markup layer)

**5. Planning assessment**
- Local Plan position (adopted + emerging), settlement boundary/Green Belt/allocation status
- Planning history table (from `planning_application_record`)
- Nearby approvals/refusals/appeals summary and precedent commentary
- Initial planning strategy and likely route (full application / outline / permission in
  principle / Local Plan promotion)
- Statement of required professional planning review

**6. Technical feasibility assessment** — one subsection per theme (title/access, highways,
drainage/flood, utilities, ground/contamination, ecology/trees/BNG, heritage/archaeology,
amenity and design, planning obligations), each structured as: automated findings → manual
technical notes → assumptions → required next action → disclaimer.

**7. Commercial assessment**
- Low/base/high capacity and dwelling mix
- High-level GDV assumptions and sales comparables (with source/date)
- Residual land value methodology and worked calculation
- Promotion-cost budget and promoter-fee waterfall summary
- Downside/base/upside sensitivity table
- Mandatory statement: "This is an early-stage screening estimate only, dated [assumptions_date],
  and is not a formal RICS valuation."

**8. Risk and opportunity register**
- Full 14-category risk table (score, RAG, evidence, assumptions, uncertainties, next action,
  cost/programme effect, classification)
- Full 10-category opportunity table
- Red flags summary and unknowns list
- Mitigation and cost/programme implications

**9. Recommended next steps**
- Gate decision and basis
- Site-control recommendation
- Surveys/reports required (auto-populated from categories scoring ≥3)
- Suggested consultant appointments
- Suggested landowner engagement action
- Proposed cost cap and indicative programme to pre-application/submission

**10. Appendices**
- Data-source register extract (sources actually used, with licence/retrieval date)
- Planning records extract
- Dataset extracts (raw screening_result rows, for traceability)
- Site photographs (full set)
- Audit log extract for this assessment version
- Assumptions and limitations (full disclaimer text, verbatim — see `01-executive-
  specification.md` §1.6 and the master disclaimer text below)
- Draft site-screening checklist (tick-list mirroring §9)

## Master disclaimer text (embedded verbatim, footer of every page + full text in Appendix)

> This report is an early-stage desktop screening assessment prepared by BASECORE Ltd for
> internal feasibility purposes. It is based on publicly available and lawfully accessible
> mapping, planning and environmental data current as at the retrieval dates stated herein,
> which may be incomplete, historic, approximate, or subject to the data provider's own
> licensing restrictions and disclaimers. This report does not confirm, and must not be relied
> upon as confirming: legal ownership, title, or right of access; highway adoption status;
> the grant of planning permission; buildability or ground conditions; utilities capacity,
> connection rights, or diversion costs; drainage discharge consent; ecological, heritage,
> or contamination status; or any valuation or achievable sale price. Formal due diligence
> and advice from appropriately qualified legal, planning, engineering, ecological,
> environmental, valuation, tax and financial advisers is required before any decision to
> acquire, promote, or invest in this site. This report is for BASECORE internal use only
> unless expressly approved for external issue by a senior reviewer.

## Output formats

- **DOCX** — the editable master, generated first, stored via `report.docx_storage_ref`.
- **PDF** — rendered from the DOCX (LibreOffice headless / Gotenberg), stored via
  `report.pdf_storage_ref`. The PDF is never hand-edited; corrections are made in DOCX and
  re-rendered, keeping one source of truth.
