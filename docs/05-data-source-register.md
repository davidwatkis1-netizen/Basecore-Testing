# 5. Data-Source Register (UK Public Sources)

This is the seed content for the `data_source` table (§3). Every layer surfaced in the Tool
must have a row here before it is used. **Licence** is the controlling field — anything not
marked OGL/free-API-terms is link-out or manual-entry only, never automated scraping.

> Licence terms and API availability change; the admin panel's "last successful retrieval"
> and "licence" fields are the source of truth in the running system — this table is the
> initial onboarding list, not a permanent guarantee of continued free access.

## 5.1 Planning & policy

| Source | URL | Licence | Access method | Update frequency | Coverage |
|---|---|---|---|---|---|
| Planning Data Platform (MHCLG) | https://www.planning.data.gov.uk/ | OGL v3.0 | REST API / GeoJSON | Rolling | England — Local Plans, Conservation Areas, Green Belt, Article 4, Brownfield Register (where published) |
| PlanIt (aggregated planning applications) | https://www.planit.org.uk/ | Publisher terms (aggregates LPA public registers) | REST API | Daily | England-wide planning applications by LPA |
| Bedford Borough Council Planning | https://www.bedford.gov.uk/planning-and-building/planning-applications | LPA terms | Public register / link-out | Daily | Bedford Borough |
| Central Bedfordshire Council Planning | https://www.centralbedfordshire.gov.uk/info/59/planning_and_building | LPA terms | Public register / link-out | Daily | Central Bedfordshire |
| Luton Borough Council Planning | https://www.luton.gov.uk/Planning_and_building_control | LPA terms | Public register / link-out | Daily | Luton |
| North Hertfordshire District Council Planning | https://www.north-herts.gov.uk/planning | LPA terms | Public register / link-out | Daily | North Hertfordshire |
| Stevenage Borough Council Planning | https://www.stevenage.gov.uk/planning-and-building-control | LPA terms | Public register / link-out | Daily | Stevenage |
| East Hertfordshire District Council Planning | https://www.eastherts.gov.uk/planning | LPA terms | Public register / link-out | Daily | East Hertfordshire |
| Welwyn Hatfield Borough Council Planning | https://www.welhat.gov.uk/planning | LPA terms | Public register / link-out | Daily | Welwyn Hatfield |
| Dacorum Borough Council Planning | https://www.dacorum.gov.uk/home/planning-development | LPA terms | Public register / link-out | Daily | Dacorum |
| St Albans City & District Council Planning | https://www.stalbans.gov.uk/planning-and-building-control | LPA terms | Public register / link-out | Daily | St Albans |
| Hertsmere Borough Council Planning | https://www.hertsmere.gov.uk/Planning.aspx | LPA terms | Public register / link-out | Daily | Hertsmere |
| Bedford Borough Local Plan 2040 | https://www.bedford.gov.uk/planning-and-building/planning-policy | LPA / OGL where mapped | Manual/GIS download | Ad hoc | Bedford Borough |
| Central Bedfordshire Local Plan | https://www.centralbedfordshire.gov.uk/info/50/local_plan | LPA / OGL where mapped | Manual/GIS download | Ad hoc | Central Bedfordshire |
| Hertfordshire local plans (portal index) | https://www.hertfordshire.gov.uk/Planning | LPA terms | Link-out | Ad hoc | Herts districts |
| The Planning Inspectorate — appeals decisions | https://acp.planninginspectorate.gov.uk/ | OGL v3.0 | Search portal / manual | Daily | England — appeal decisions |
| Gov.uk Brownfield Land Registers guidance | https://www.gov.uk/guidance/brownfield-land-registers | OGL v3.0 | Reference / links to LPA registers | Ad hoc | England |

## 5.2 Environment, flood & drainage

| Source | URL | Licence | Access method | Update frequency | Coverage |
|---|---|---|---|---|---|
| Flood Map for Planning (Environment Agency) | https://flood-map-for-planning.service.gov.uk/ | OGL v3.0 | WMS/service (manual lookup for planning-grade determination) | Periodic | England — Flood Zones 2/3 |
| Check Long Term Flood Risk | https://check-long-term-flood-risk.service.gov.uk/map | OGL v3.0 | Web map / WMS | Periodic | England — river/sea, surface water, reservoir |
| Environment Agency Data Services (Open Data Hub) | https://environment.data.gov.uk/ | OGL v3.0 | REST API / WMS/WFS | Varies by dataset | England — flood, water quality, EA constraints |
| EA Real-time flood-monitoring API | https://environment.data.gov.uk/flood-monitoring/doc/reference | OGL v3.0 | REST API | Real-time | England |
| Ordnance Survey — Rivers/Watercourses (OS Open Rivers) | https://osdatahub.os.uk/downloads/open/OpenRivers | OS OpenData Licence (OGL-compatible) | Download / API | Periodic | GB |
| Local authority SFRAs (index via each LPA's planning policy pages) | See §5.1 LPA links | LPA terms | Manual/document link | Ad hoc | Per LPA |
| Anglian Water — developer services | https://www.anglianwater.co.uk/developers/ | Provider terms | Link-out / manual enquiry | N/A | Parts of Beds/Herts |
| Affinity Water — developer services | https://www.affinitywater.co.uk/developers | Provider terms | Link-out / manual enquiry | N/A | Parts of Beds/Herts |
| Thames Water — developer services | https://www.thameswater.co.uk/developer-services | Provider terms | Link-out / manual enquiry | N/A | Parts of Herts |

## 5.3 Ecology, trees & landscape

| Source | URL | Licence | Access method | Update frequency | Coverage |
|---|---|---|---|---|---|
| MAGIC Map (Defra/Natural England) | https://magic.defra.gov.uk/ | OGL v3.0 | WMS/WFS | Periodic | England — SSSI, SAC, SPA, Ramsar, NNR, LNR, Ancient Woodland, Priority Habitat |
| Natural England Open Data Geoportal | https://naturalengland-defra.opendata.arcgis.com/ | OGL v3.0 | REST API / download | Periodic | England |
| Ancient Tree Inventory (Woodland Trust) | https://ati.woodlandtrust.org.uk/ | Woodland Trust terms (attribution required) | Web map / download | Ad hoc | UK |
| National Landscapes (AONB) designations | https://www.landscapesforlife.org.uk/ | Publisher terms | Reference / MAGIC layer | Ad hoc | England |
| Ordnance Survey — Public Rights of Way (via local authority definitive map) | See LPA/County Council links | LPA/OGL | Manual/GIS download | Ad hoc | Per authority |
| Natural England — Biodiversity Net Gain guidance | https://www.gov.uk/guidance/biodiversity-net-gain | OGL v3.0 | Reference | Ad hoc | England |

## 5.4 Heritage & archaeology

| Source | URL | Licence | Access method | Update frequency | Coverage |
|---|---|---|---|---|---|
| National Heritage List for England (Historic England) | https://historicengland.org.uk/listing/the-list/ | OGL v3.0 | Search / REST API | Periodic | England — Listed Buildings, Scheduled Monuments, Registered Parks & Gardens, Battlefields, World Heritage Sites |
| Historic England Data Downloads (GIS) | https://historicengland.org.uk/services-skills/our-planning-services/data-downloads/ | OGL v3.0 | GIS download (Shapefile/GeoJSON) | Periodic | England |
| Historic Environment Record — Hertfordshire (via Herts CC) | https://www.hertfordshire.gov.uk/services/education-and-learning/history-and-heritage/ | LPA/County terms | Link-out / enquiry | Ad hoc | Hertfordshire |
| Bedfordshire Historic Environment Record | https://www.bedford.gov.uk/ (HER hosted regionally) | LPA/County terms | Link-out / enquiry | Ad hoc | Bedfordshire |

## 5.5 Ground conditions & geology

| Source | URL | Licence | Access method | Update frequency | Coverage |
|---|---|---|---|---|---|
| BGS Geology of Britain Viewer | https://www.bgs.ac.uk/geology-of-britain-viewer/ | BGS terms (free viewing; bulk data licensed) | Web map / WMS | Periodic | GB — bedrock & superficial geology |
| BGS GeoIndex | https://www.bgs.ac.uk/technologies/geoindex/ | BGS terms | Web map | Periodic | GB — boreholes |
| Coal Authority Interactive Map / mining reports | https://www.gov.uk/guidance/coal-mining-reports-request-one-for-a-residential-property | OGL v3.0 (viewer); reports paid | Web map / paid report | Periodic | England coalfield areas |
| UKradon (radon maps, UKHSA/BGS) | https://www.ukradon.org/ | UKHSA/BGS terms | Web map / paid report | Static | UK |
| Gov.uk — Contaminated land guidance & local registers index | https://www.gov.uk/guidance/land-contamination-how-to-manage-the-risks-when-you-develop-land | OGL v3.0 | Reference / LPA link-out | Ad hoc | England |

## 5.6 Highways, access & transport

| Source | URL | Licence | Access method | Update frequency | Coverage |
|---|---|---|---|---|---|
| DfT Road Traffic Statistics | https://roadtraffic.dft.gov.uk/ | OGL v3.0 | REST API / download | Annual | GB |
| NaPTAN (National Public Transport Access Nodes) | https://beta-naptan.dft.gov.uk/ | OGL v3.0 | Download / API | Periodic | GB — bus stops, stations |
| National Rail — station data (via Rail Delivery Group / ORR) | https://www.raildeliverygroup.com/ | Publisher terms | Reference | Periodic | GB |
| Sustrans National Cycle Network | https://www.sustrans.org.uk/national-cycle-network/ | OGL-compatible (attribution) | Download / API | Periodic | GB |
| Ordnance Survey OS Data Hub — OS NGD/Maps/Places API | https://osdatahub.os.uk/ | OS Data Hub free-tier terms / OGL for OpenData products | REST API / WMTS | Continuous | GB |
| Crash Map / DfT road safety data (STATS19) | https://www.gov.uk/government/collections/road-accidents-and-safety-statistics | OGL v3.0 | Download | Annual | GB |
| Hertfordshire County Council Highways | https://www.hertfordshire.gov.uk/services/highways-roads-and-pavements/ | LPA/County terms | Link-out | Ad hoc | Hertfordshire |
| Bedford Borough / Central Bedfordshire Highways (highway authority functions) | https://www.bedford.gov.uk/ / https://www.centralbedfordshire.gov.uk/ | LPA/County terms | Link-out | Ad hoc | Bedfordshire |

## 5.7 Utilities & infrastructure

| Source | URL | Licence | Access method | Update frequency | Coverage |
|---|---|---|---|---|---|
| National Underground Asset Register (NUAR) | https://www.geoplace.co.uk/nuar or https://nuar.gov.uk | Organisational access agreement required — **not** integrated without a signed data-sharing agreement | Manual/organisational API | Continuous (once licensed) | England (rollout) |
| UK Power Networks (DNO — parts of Herts) | https://www.ukpowernetworks.co.uk/ | Provider terms | Link-out / enquiry | N/A | Parts of Hertfordshire |
| Western Power Distribution / National Grid Electricity Distribution (parts of Beds) | https://www.nationalgrid.co.uk/electricity-distribution | Provider terms | Link-out / enquiry | N/A | Parts of Bedfordshire |
| Cadent Gas — developer services | https://cadentgas.com/ | Provider terms | Link-out / enquiry | N/A | Beds/Herts (gas) |
| Openreach — developer services | https://www.openreach.com/new-developments | Provider terms | Link-out / enquiry | N/A | UK |
| LinesearchbeforeUdig (LSBUD) | https://www.linesearchbeforeudig.co.uk/ | Free registration, provider terms | Manual enquiry | On request | UK |

## 5.8 Address, location & base mapping

| Source | URL | Licence | Access method | Update frequency | Coverage |
|---|---|---|---|---|---|
| OS Data Hub — OS Places API (address/UPRN lookup) | https://osdatahub.os.uk/docs/places/overview | OS Data Hub terms (free tier available) | REST API | Continuous | GB |
| OS Open Names | https://osdatahub.os.uk/downloads/open/OpenNames | OS OpenData Licence | Download / API | Periodic | GB |
| Code-Point Open (postcode centroids) | https://osdatahub.os.uk/downloads/open/CodePointOpen | OS OpenData Licence | Download | Periodic | GB |
| what3words API | https://developer.what3words.com/public-api | what3words API terms (free tier) | REST API | N/A | Global |
| OS Maps API (basemap tiles) | https://osdatahub.os.uk/docs/wmts/overview | OS Data Hub terms | WMTS | Continuous | GB |

## 5.9 Land Registry (link-out / manual only — never scraped)

| Source | URL | Licence | Access method | Notes |
|---|---|---|---|---|
| HM Land Registry — Search for land and property information | https://eservices.landregistry.gov.uk/eservices/FindAProperty/QuickEnquiryInit.do | Crown copyright / paid per search | Manual, user-initiated | Title register/plan purchased per search; upload the PDF/results into `site_attachment` |
| HM Land Registry — Price Paid Data | https://www.gov.uk/government/collections/price-paid-data | OGL v3.0 | Bulk download | Comparable evidence only, not title data |

## 5.10 Neighbourhood plans & Call for Sites

| Source | URL | Licence | Access method | Notes |
|---|---|---|---|---|
| Locality — neighbourhood planning register | https://neighbourhoodplanning.org/ | Publisher terms | Reference / link-out | Index of made/emerging neighbourhood plans |
| Each LPA's Call for Sites / SHLAA-HELAA pages | See §5.1 LPA links | LPA terms | Manual download/link-out | Published as PDF/spreadsheet per LPA, not a consistent API |

---

Machine-readable seed file: [`05-data-source-register.csv`](05-data-source-register.csv)
(columns match the `data_source` table in `database/schema.sql`).
