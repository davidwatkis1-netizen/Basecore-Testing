# 14. Implementation Programme and Indicative Costs

All figures are indicative UK market rates (2026), excluding VAT, for planning purposes only —
obtain fixed quotations before committing budget.

## 14.1 Programme (10-week MVP track)

| Week | Milestone |
|---|---|
| 1 | Discovery workshop with BASECORE engineers/analysts; confirm final dataset priority list and 3–5 test sites; finalise schema |
| 2 | Environment setup (Azure, Entra ID app registration, CI/CD, PostGIS); auth + RBAC scaffold |
| 3 | Site CRUD + all boundary input methods; database schema live |
| 4 | Map dashboard (MapLibre) + first 3 live data-source integrations (Green Belt, settlement boundary, Flood Zones) |
| 5 | Remaining priority data-source integrations (Listed Buildings, SSSI/LWS, BGS geology, planning applications) |
| 6 | Manual technical assessment panels (all 7 themes) + title/ownership module |
| 7 | Risk & opportunity scoring engine (suggested-score rules + manual override + recommendation logic) |
| 8 | Commercial appraisal module + calculations; audit log + export |
| 9 | Report generation (DOCX template build + PDF conversion pipeline); portfolio dashboard |
| 10 | UAT against the 3–5 test sites (`15-testing-and-acceptance-checklist.md`); bug-fix; go-live |

Assumes a team of 1 full-stack/GIS developer + 1 backend/data developer + part-time
BASECORE domain input (2–4 hours/week from an engineer for review and test-site validation).
A team of 3 developers could compress this to 6–7 weeks; a single developer would likely need
14–16 weeks.

## 14.2 Costed estimate (indicative ranges, GBP, excl. VAT)

| Cost area | MVP (one-off) | Ongoing (annual) | Notes |
|---|---|---|---|
| **Development** | £35,000–£60,000 | — | 2 developers x 8–10 weeks at typical UK contractor day rates (£400–£650/day blended); wide range reflects in-house vs. agency delivery |
| **Software licences** | £500–£2,000 | £1,500–£4,000 | Entra ID (likely already covered by existing M365 licences), IDE/tooling, DOCX-to-PDF conversion service if not self-hosted |
| **Data** | £0–£3,000 | £500–£3,000 | Most core datasets are OGL/free-tier; budget for OS Data Hub paid tier if usage exceeds free allowance, and for any paid Land Registry/Coal Authority per-search reports used during testing |
| **Hosting (Azure)** | — | £2,500–£6,000 | App Service (frontend+backend), PostgreSQL Flexible Server (small/medium tier), Blob Storage, Key Vault, Monitor — UK South region, business-hours-priority sizing |
| **Report/PDF conversion** | £0–£1,500 | £0–£1,000 | Self-hosted LibreOffice/Gotenberg (near-zero marginal cost) vs. a managed conversion API |
| **Maintenance & support** | — | £8,000–£15,000 | Bug fixes, dependency/security patching, dataset licence review, minor enhancements (~0.5 day/week average) |
| **Professional review** (legal/GDPR/security sign-off before go-live) | £2,000–£5,000 | £1,000–£2,000/yr refresh | External legal review of data licensing and GDPR posture (see §16) |
| **Contingency (15%)** | £6,000–£10,000 | — | Standard project contingency |
| **Indicative total** | **£45,000–£80,000** one-off | **£13,500–£31,000** per year | Phase 2 enhancements costed separately when scoped |

## 14.3 Cost drivers to watch

- **OS Data Hub usage** — the free tier covers light usage; a busy analyst team running many
  screenings/day could cross into the paid tier (transaction-based pricing) — monitor and
  budget accordingly.
- **NUAR access** — deferred to Phase 2 specifically because it requires a signed
  organisational data-sharing agreement with Geoplace/HM Land Registry, which has its own
  onboarding lead time and is not guaranteed to be free for a private consultancy — confirm
  eligibility and cost before committing to the Phase 2 date.
- **Land Registry data** — deliberately kept manual/link-out (paid per search, ~£3–£7/title
  as at general market rates) rather than integrated, to avoid a recurring bulk-data licence
  cost that is disproportionate to a screening tool.
