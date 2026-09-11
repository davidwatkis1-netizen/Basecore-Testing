# 9. UI Wireframe Descriptions

Text-described wireframes (no image assets) for the core screens. Layout convention:
left-hand global nav, top bar with site switcher/status/breadcrumb, main content area.

## 9.1 Portfolio dashboard (landing page)

- Top bar: BASECORE logo, "New Site" primary button, user menu (Entra ID profile), search box.
- Left filter rail: status (multi-select chips: Lead/Desktop Review/.../Rejected), LPA
  multi-select, confidentiality filter, "my sites" toggle.
- Main area: toggle between **table view** (sortable columns: reference, name, LPA, status,
  capacity, last assessment date, recommendation badge) and **map view** (portfolio-wide
  MapLibre map, one marker per site coloured by recommendation/status).
- Right summary cards: count by status, count by recommendation, sites needing re-screen
  (boundary changed since last run).

## 9.2 Create site wizard

Modal/stepper, 3 steps:
1. **Locate** — tabs: Search address/postcode/UPRN/grid-ref/lat-long/what3words (autocomplete
   list with map preview) | Drop a pin | Draw polygon | Upload file (drag-drop zone accepting
   .geojson/.kml/.gpx/.dxf/.zip[shapefile]/.csv, with a live map preview of the parsed geometry
   and an inline error state for unparseable files) | Select saved site.
2. **Details** — form: site name, reference (auto-suggested `BAS-YYYY-NNNN`, editable), LPA
   (auto-detected from point-in-polygon against the LPA boundary layer, editable), current
   land use, proposed development type, low/base/high capacity, status (default "Lead"),
   confidentiality classification, notes.
3. **Confirm** — summary card (area ha/sqm computed live, map thumbnail), "Create and run
   screening now" checkbox (default on), Create button.

## 9.3 Site workspace (main working screen)

Persistent left tab rail within the site: **Overview | Map | Planning | Title & Ownership |
Technical | Commercial | Risk & Opportunity | Reports | Audit Log**.

### Map tab
- Full-width MapLibre map. Right-hand collapsible **layer panel**: grouped checkboxes by
  theme (Planning, Flood/Drainage, Ecology, Heritage, Ground, Highways, Utilities, Context),
  each with an opacity slider and a small legend swatch; a "data source & retrieval date"
  info icon per layer opens a tooltip.
- Top-left floating toolbar: basemap switcher (Aerial/Road/OS), measure tool, draw/markup
  tool (point/line/polygon with a style picker for "possible entrance", "drainage route",
  "constraint area", "note"), screenshot/print, buffer toggle (50 m/250 m/500 m rings with
  distance labels), coordinate readout following the cursor.
- Feature identify: clicking any feature opens a right-hand info drawer: layer name, feature
  name/reference, distance from site, source + retrieval date, "view raw record" link.
- Bottom-right: scale bar, north arrow, "Save markup as version" button (prompts for a version
  label), "Rerun screening" button (shown with a badge if the boundary has changed since the
  last run).

### Planning tab
- Summary card: settlement boundary / Green Belt / allocation status (auto, with source link).
- Table: nearby planning applications & appeals (reference, address, proposal, status,
  decision, distance, relevance rating stars, notes — editable inline).
- "Add application manually" button for records not caught by automated screening.

### Title & Ownership tab
- Banner disclaimer: "Title plans show general boundaries only. Legal advice required."
- Form: title number(s), registered proprietor, tenure, charges/restrictions/covenants/
  easements, access notes, legal review status (stepper: Not started → Solicitor instructed →
  In progress → Reviewed).
- "Features outside boundary" warning banner (auto-shown if flagged), with a note field.
- Document list (title register/plan/deed uploads) with SharePoint links.
- "Open HM Land Registry search" external link button.

### Technical tab
- Sub-tabs: Highways | Drainage & Flood | Utilities | Ground & Contamination | Ecology & BNG |
  Heritage | Amenity & Design.
- Each sub-tab: left column = auto-screened findings (read-only cards, source-cited); right
  column = manual form fields per `03-database-schema.md` §3.3 JSON Schema, each field tagged
  with a small coloured dot indicating data_confidence (grey=automated, blue=manual entry,
  purple=professional opinion, amber=assumption, red=unverified).

### Commercial tab
- Input form organised in collapsible sections (Capacity & Mix, Sales Assumptions, Costs,
  Promotion & Waterfall) with a live-calculated summary panel (GDV, Residual Land Value, Net
  Sale Proceeds, Promoter Fee) that recalculates on blur.
- Sensitivity table (downside/base/upside) rendered as a 3-column comparison.
- Version selector + "New version" button; assumptions date stamped automatically.
- Persistent banner: "Early-stage screening estimate — not a formal valuation."

### Risk & Opportunity tab
- Two tables (Risk — 14 rows, Opportunity — 10 rows), each row expandable to show all fields.
- Score cells are RAG-coloured; changing a score opens a modal requiring rationale text if a
  prior score exists.
- Right-hand panel: computed recommendation card (recommendation, basis, critical
  uncertainties list, next-stage scope, cost cap) with an "Override" control (rationale
  required) and an "Approve" button (senior reviewer role only).

### Reports tab
- List of generated report versions (date, generator, approved Y/N) with Download DOCX/PDF
  buttons.
- "Generate report" button — opens a modal to pick which assessment version and confirm
  confidentiality classification before generation.

### Audit Log tab
- Chronological, filterable (event type, date range, user) table; "Export CSV/PDF" button.

## 9.4 Responsive/print considerations

- Map dashboard optimised for desktop/laptop (min 1280 px); a read-only mobile view is
  Phase 2 (see `11-phase2-backlog.md`).
- Print/screenshot tool renders the current map state (layers, legend, scale bar, north
  arrow, attribution) to a PNG/PDF suitable for pasting into ad-hoc documents.
