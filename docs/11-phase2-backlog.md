# 11. Phase 2 Enhancement Roadmap

Sequenced in three tranches after MVP go-live, subject to reprioritisation based on live
usage feedback from the first 5–10 real assessments.

## Tranche A (months 3–4 post-MVP)

- **Full GIS layer coverage** — bring every layer in `06-gis-layer-catalogue.md` marked
  "reference/link-out" up to full automated screening where a licence/API permits (e.g.
  Article 4 directions, TPOs, local wildlife sites, archaeological priority areas — subject to
  each LPA publishing usable GIS data).
- **BNG unit calculator** — structured habitat baseline capture + the statutory biodiversity
  metric calculation (DEFRA metric), replacing free-text estimation fields.
- **Portfolio Power BI dashboard** — read-replica feed into Power BI for Board-level reporting
  across the whole pipeline (per `00-architecture-comparison.md` recommendation).
- **NUAR integration** (subject to BASECORE completing the organisational data-sharing
  agreement with Geoplace) — apparent-utility mapping upgraded from visual/manual to a
  licensed underground-asset feed.
- **External consultant portal** — scoped, time-limited read/upload access for appointed
  third-party consultants without full user licences.
- **Scenario/sensitivity modelling upgrade** — Monte Carlo or tornado-chart sensitivity on the
  commercial model rather than fixed downside/base/upside.

## Tranche B (months 5–7 post-MVP)

- **Automated re-screening on dataset update** — scheduled diffing against the data-source
  registry's `update_frequency`, flagging sites whose screening may be stale.
- **Neighbourhood plan policy linkage** — structured tagging of relevant neighbourhood-plan
  policies per site (manual curation initially, NLP-assisted later).
- **Mobile-responsive site-visit mode** — read-only site summary + photo upload optimised for
  a phone/tablet during a site walkover.
- **Multi-user real-time collaboration** on the map (presence indicators, live markup sync).
- **Landowner engagement CRM-lite** — structured contact log, meeting notes, offer/heads-of-
  terms tracking, linked to the existing `site_note` categorisation.
- **Template report variants** — a shorter "landowner-facing" report variant with commercially
  sensitive fields (RLV, promoter fee) redacted, generated from the same underlying data.

## Tranche C (months 8–12 post-MVP)

- **Geographic expansion** beyond the 10 initial LPAs, with a config-driven LPA onboarding
  workflow (add boundary + policy map + planning-portal connector without code changes).
- **API integrations with additional promotion partners** (data export/import for joint
  ventures).
- **Machine-assisted precedent analysis** — surfacing the most relevant historic planning
  approvals/refusals by similarity (site size, designation profile, LPA) rather than pure
  distance ranking.
- **Full WCAG 2.2 AA accessibility audit and remediation.**
- **Disaster recovery / multi-region resilience** if the tool becomes business-critical
  (beyond the MVP's single-region, backup-only posture).

## Continuous (not a tranche — ongoing through all phases)

- Data-source licence review (quarterly) — re-confirm each registered source's licence terms
  have not changed, per `16-assumptions-licensing-and-professional-advice.md`.
- Security patching and dependency updates.
- User feedback loop from BASECORE analysts feeding directly into backlog grooming.
