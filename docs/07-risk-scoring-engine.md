# 7. Risk & Opportunity Scoring Engine — Rules and Pseudocode

## 7.1 Principle

The engine **never fully automates a score**. It computes a **suggested score** from screening
evidence using deterministic rules, but every category requires an analyst to confirm, adjust
(with rationale) and add evidence/assumption/next-action text before an assessment can be
marked complete. This preserves the brief's requirement that professional judgement,
assumptions and unverified information are visibly distinguished from automated data.

## 7.2 Score scale (all 14 risk categories)

| Score | Meaning |
|---|---|
| 1 | Low apparent risk |
| 2 | Manageable risk |
| 3 | Material uncertainty |
| 4 | High risk |
| 5 | Potentially fatal or commercially unacceptable risk |

RAG mapping: 1–2 = Green, 3 = Amber, 4–5 = Red.
Classification: any score of 5 defaults to `hard_stop` (analyst may downgrade with rationale);
score 4 defaults to `gate_issue`; scores 1–3 default to `manageable`.

## 7.3 Suggested-score rule engine (pseudocode)

```python
def suggest_score(category: str, screening_results: list[ScreeningResult],
                   technical_fields: dict) -> SuggestedScore:
    """
    Returns a suggested 1-5 score + rationale bullet list. Pure function of the
    evidence available; never writes directly to risk_score (analyst must confirm).
    """
    facts, uncertainties = [], []
    score = 1  # start optimistic; escalate on evidence

    if category == "flood_risk_drainage":
        fz3 = any(r for r in screening_results
                   if r.theme == "flood_drainage" and r.feature_name == "Flood Zone 3"
                   and r.buffer_band == "within_site")
        fz2 = any(r for r in screening_results
                   if r.theme == "flood_drainage" and r.feature_name == "Flood Zone 2"
                   and r.buffer_band == "within_site")
        surface_water_high = any(r for r in screening_results
                   if r.theme == "flood_drainage" and "surface water" in r.feature_name.lower()
                   and r.raw_attributes.get("risk_band") == "high"
                   and r.buffer_band in ("within_site", "immediate"))
        if fz3:
            score = max(score, 4); facts.append("Site intersects Flood Zone 3.")
            uncertainties.append("Sequential/Exception Test and site-specific FRA required.")
        elif fz2:
            score = max(score, 3); facts.append("Site intersects Flood Zone 2.")
        if surface_water_high:
            score = max(score, 3)
            uncertainties.append("High surface-water flood risk indicated within/adjacent to site.")
        if not technical_fields.get("discharge_route"):
            uncertainties.append("No confirmed discharge route recorded — drainage feasibility unresolved.")
            score = max(score, 3)

    elif category == "highways_transport":
        risk_input = technical_fields.get("highway_risk_score")
        if risk_input:
            score = max(score, int(risk_input))
        if technical_fields.get("junction_capacity_risk") == "high":
            score = max(score, 4)
        if technical_fields.get("third_party_land_required"):
            score = max(score, 4)
            uncertainties.append("Third-party land may be required for access — control not confirmed.")
        no_frontage = not technical_fields.get("proposed_access_location")
        if no_frontage:
            score = max(score, 3)
            uncertainties.append("No confirmed access point recorded.")

    elif category == "title_ownership_legal_access":
        title = technical_fields.get("title_review_status")
        if title in (None, "not_started"):
            score = max(score, 3)
            uncertainties.append("Legal title review not yet started.")
        if technical_fields.get("features_outside_boundary_flag"):
            score = max(score, 4)
            facts.append("Proposed access/drainage/BNG land may fall outside the site polygon.")

    elif category == "heritage_archaeology_landscape":
        within_site = [r for r in screening_results if r.theme == "heritage_archaeology"
                        and r.buffer_band == "within_site"]
        setting_nearby = [r for r in screening_results if r.theme == "heritage_archaeology"
                        and r.buffer_band in ("immediate", "context")]
        if within_site:
            score = max(score, 4)
            facts.append(f"{len(within_site)} heritage asset(s) recorded within the site boundary.")
        elif setting_nearby:
            score = max(score, 2)
            uncertainties.append("Nearby heritage assets may raise a setting consideration.")

    elif category == "ecology_trees_bng":
        statutory = [r for r in screening_results if r.theme == "ecology_trees_bng"
                     and r.raw_attributes.get("designation_type") == "statutory"
                     and r.buffer_band in ("within_site", "immediate")]
        if statutory:
            score = max(score, 4)
            facts.append("Statutory ecological designation within or adjacent to the site.")
        ancient_woodland_nearby = any(r for r in screening_results
                     if r.feature_name == "Ancient Woodland" and r.distance_m is not None
                     and r.distance_m < 15)
        if ancient_woodland_nearby:
            score = max(score, 4)
            uncertainties.append("Ancient woodland within the buffer zone recommended by Natural England guidance (15 m).")

    elif category == "ground_contamination":
        former_use_flags = technical_fields.get("former_industrial_or_fill_use")
        landfill_nearby = any(r for r in screening_results if r.theme == "ground_contamination"
                     and "landfill" in (r.feature_name or "").lower()
                     and r.buffer_band in ("within_site", "immediate"))
        if landfill_nearby:
            score = max(score, 4)
            facts.append("Historic landfill site recorded within or adjacent to the site.")
        if former_use_flags:
            score = max(score, 3)
            uncertainties.append("Site history suggests potential made ground/contamination — Phase 1 required.")

    # ... equivalent deterministic rule blocks exist for the remaining categories:
    # utilities_infrastructure, amenity_design_capacity, planning_obligations_delivery_costs,
    # market_demand_sales_evidence, residual_value_promotion_economics, programme_funding,
    # landowner_alignment_site_control, and planning_principle_policy (Green Belt/settlement
    # boundary/allocation status drive this one directly from screening_results).

    return SuggestedScore(category=category, score=min(score, 5),
                           facts=facts, uncertainties=uncertainties)
```

## 7.4 Recommendation logic

```python
def compute_recommendation(risk_scores: list[RiskScore]) -> Recommendation:
    hard_stops = [r for r in risk_scores if r.classification == "hard_stop"]
    gate_issues = [r for r in risk_scores if r.classification == "gate_issue"]
    high_risk_count = len([r for r in risk_scores if r.score >= 4])
    avg_score = mean(r.score for r in risk_scores)

    if hard_stops:
        return Recommendation(
            recommendation="reject",
            basis=f"{len(hard_stops)} category scored as a hard stop: "
                  f"{', '.join(r.category for r in hard_stops)}.",
        )
    if high_risk_count >= 4 or avg_score >= 3.5:
        return Recommendation(
            recommendation="monitor",
            basis="Multiple high-risk/uncertain categories; not viable to progress without "
                  "material change in evidence or landowner terms.",
        )
    if gate_issues and avg_score < 3.5:
        return Recommendation(
            recommendation="approach_landowner",
            basis="Gate issues identified but appear resolvable; site control should be "
                  "explored before committing survey spend.",
        )
    return Recommendation(
        recommendation="proceed_to_feasibility",
        basis="No hard stops; risk profile manageable within the standard feasibility "
              "cost cap.",
    )
```

The suggested recommendation is always presented to the analyst/senior reviewer with the
**critical uncertainties list** (every category's `uncertainties` field) and a **capped
next-stage scope** (a template list of surveys/reports keyed to which categories scored ≥3,
e.g. score ≥3 on `flood_risk_drainage` → "commission a Flood Risk Assessment and preliminary
drainage strategy, est. £X, Y weeks"). The analyst can override the computed recommendation,
but an override requires a mandatory rationale field (`assessment_recommendation.basis` is
NOT NULL) and is itself audit-logged.

## 7.5 Wording safeguards baked into the engine

The report/UI text generator uses a fixed phrase library and **never** interpolates raw
dataset findings into an assertion of fact about deliverability. Examples:

| Situation | Prohibited phrasing | Required phrasing |
|---|---|---|
| No Flood Zone 3 found within site | "The site is flood safe." | "No Flood Zone 3 (high probability) mapping was identified intersecting the site boundary based on the Environment Agency Flood Map for Planning retrieved on [date]. This does not confirm drainage feasibility or discharge consent; a site-specific Flood Risk Assessment is recommended." |
| Road adjoins site frontage | "The site has adopted highway access." | "Mapping indicates a road adjoins the site frontage. Adoption status has not been confirmed with the highway authority and must be verified before relying on this as a point of access." |
| RLV calculated | "This site is worth £X." | "Based on the assumptions dated [date] (see Commercial Assessment), the indicative residual land value is £X. This is an early-stage screening estimate, not a formal RICS valuation." |

## 7.6 Opportunity scoring

Opportunity categories (10, per brief §4.2) are scored 1–5 (5 = strongest opportunity) with a
free-text narrative; they do not feed the hard-stop logic but are displayed alongside risk
scores in the report's risk-and-opportunity register and inform the "Key opportunities" line
of the executive summary.
