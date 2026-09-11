# 6. GIS Layer Catalogue

Layers presented in the map dashboard's layer control panel, grouped by theme. Each layer
maps to one `data_source` row (see `05-data-source-register.md`) and one `screening_result.theme`
value. "Screening" = automatically intersected/measured against the site + buffers on every run.
"Reference/link-out" = shown as a link or manually reviewed, not spatially auto-screened
(usually because the licence or data structure does not support automated ingestion).

| Layer | Theme | Geometry type | Screened automatically? | Legend style | Source |
|---|---|---|---|---|---|
| Local Planning Authority boundary | planning_policy | Polygon | Reference | Outline only | planning.data.gov.uk |
| Local Plan adopted policy map | planning_policy | Polygon | Screening | Categorical fill | LPA GIS download |
| Emerging Local Plan allocations | planning_policy | Polygon | Screening | Categorical fill (dashed = emerging) | LPA GIS download |
| Settlement boundaries | planning_policy | Polygon | Screening | Outline | LPA GIS download |
| Green Belt | planning_policy | Polygon | Screening | Hatched fill | planning.data.gov.uk |
| Article 4 Direction areas | planning_policy | Polygon | Screening (where mapped) | Outline | LPA GIS download |
| Brownfield Land Register sites | planning_policy | Polygon/Point | Screening | Point/fill | planning.data.gov.uk |
| Conservation Areas | heritage_archaeology | Polygon | Screening | Outline | Historic England / planning.data.gov.uk |
| Neighbourhood Plan areas | planning_policy | Polygon | Reference | Outline | Locality / LPA |
| Planning applications (nearby) | planning_policy | Point | Screening | Point, coloured by outcome | PlanIt / LPA register |
| Planning appeal decisions | planning_policy | Point | Screening | Point | Planning Inspectorate |
| Flood Zone 2 / Flood Zone 3 | flood_drainage | Polygon | Screening | Blue graduated fill | EA Flood Map for Planning |
| Surface water flood risk | flood_drainage | Polygon | Screening | Blue graduated fill | EA Long Term Flood Risk |
| Reservoir flood risk | flood_drainage | Polygon | Screening | Outline | EA Long Term Flood Risk |
| Main rivers | flood_drainage | Line | Screening | Blue line | OS Open Rivers / EA |
| Ordinary watercourses | flood_drainage | Line | Screening (where available) | Blue line (thin) | LPA/IDB where published |
| Flood defences | flood_drainage | Line/Point | Reference | Symbol | EA |
| Groundwater Source Protection Zones | flood_drainage | Polygon | Screening | Graduated fill | EA |
| SSSI / SAC / SPA / Ramsar | ecology_trees_bng | Polygon | Screening | Green hatch | MAGIC / Natural England |
| National/Local Nature Reserves | ecology_trees_bng | Polygon | Screening | Green fill | MAGIC |
| Local Wildlife Sites | ecology_trees_bng | Polygon | Screening (where published) | Green fill (light) | LPA/local records centre |
| Ancient Woodland | ecology_trees_bng | Polygon | Screening | Dark green fill | Natural England |
| Priority Habitat Inventory | ecology_trees_bng | Polygon | Screening | Green graduated fill | Natural England |
| Ancient/veteran trees | ecology_trees_bng | Point | Screening | Tree symbol | Woodland Trust ATI |
| Tree Preservation Orders | ecology_trees_bng | Polygon/Point | Screening (where LPA GIS available) | Green symbol/outline | LPA GIS |
| AONB / National Landscape | ecology_trees_bng | Polygon | Screening | Outline | Natural England |
| Public Rights of Way | highways_access | Line | Screening | Dashed green line | LPA/County definitive map |
| Listed Buildings | heritage_archaeology | Point | Screening | Grade-coloured symbol | Historic England NHLE |
| Scheduled Monuments | heritage_archaeology | Polygon/Point | Screening | Symbol | Historic England NHLE |
| Registered Parks & Gardens | heritage_archaeology | Polygon | Screening | Outline | Historic England NHLE |
| Registered Battlefields | heritage_archaeology | Polygon | Screening | Outline | Historic England NHLE |
| World Heritage Sites | heritage_archaeology | Polygon | Screening | Outline | Historic England NHLE |
| Archaeological Priority Areas | heritage_archaeology | Polygon | Reference (where published) | Outline | HER / LPA |
| BGS bedrock geology | ground_contamination | Polygon | Screening | Categorical fill | BGS |
| BGS superficial geology | ground_contamination | Polygon | Screening | Categorical fill | BGS |
| Boreholes (GeoIndex) | ground_contamination | Point | Reference | Symbol | BGS |
| Coal Authority referral area | ground_contamination | Polygon | Screening | Hatched fill | Coal Authority |
| Historic landfill sites | ground_contamination | Polygon/Point | Screening | Symbol | EA |
| Radon affected areas | ground_contamination | Polygon | Reference | Graduated fill | UKradon |
| Road network (classified) | highways_access | Line | Screening | Coloured by class | OS Open Roads |
| Bus stops / rail stations (NaPTAN) | highways_access | Point | Screening | Symbol | DfT NaPTAN |
| National Cycle Network | highways_access | Line | Screening | Coloured line | Sustrans |
| STATS19 collision data | highways_access | Point | Reference | Heat/point | DfT |
| Aerial imagery basemap | context | Raster | N/A | N/A | OS Maps API / Bing (licensed) |
| OS road-map basemap | context | Raster/Vector tiles | N/A | N/A | OS Maps API |
| Site boundary (all versions) | site | Polygon | N/A | Red outline (current), grey (historic) | User-drawn/uploaded |
| Buffers (50 m / 250 m / 500 m) | site | Polygon | N/A | Dashed rings | Generated (PostGIS `ST_Buffer`) |
| User markup / annotations | markup | Mixed | N/A | User-styled | User-drawn |

## 6.1 Buffer logic

For every screening layer, the engine calculates, per feature:

```
if ST_Intersects(feature, site_boundary): buffer_band = 'within_site'
elif ST_Intersects(feature, buffer_immediate):    buffer_band = 'immediate'   (default 50 m)
elif ST_Intersects(feature, buffer_context):      buffer_band = 'context'     (default 250 m)
elif ST_Intersects(feature, buffer_comparables):  buffer_band = 'comparables' (default 500 m; planning history only)
else: not recorded
distance_m = ST_Distance(feature, site_boundary)
```

Planning application/appeal records use the 500 m comparables buffer by default (configurable);
all other constraint themes default to the 250 m context buffer as their outer search limit,
per the brief's emphasis on flood/heritage/ecology/ground risk being screened within
site + 50 m + 250 m, with the 500 m band reserved for planning comparables — this default is
itself configurable per theme in the admin panel.
