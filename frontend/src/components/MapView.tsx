"use client";

import { useEffect, useRef, useState } from "react";
import maplibregl, { Map as MapLibreMap } from "maplibre-gl";
import "maplibre-gl/dist/maplibre-gl.css";

/**
 * Site boundary map with a minimal polygon-draw tool.
 *
 * This is the MVP-scaffold version of the "Map tab" described in
 * docs/09-ui-wireframes.md. It implements: basemap, click-to-draw polygon, live area
 * read-out, and a callback with the finished GeoJSON boundary. The full feature set
 * (layer panel, legend, measure tool, feature-identify, markup layers, buffer rings) is
 * MVP backlog item #5 in docs/10-mvp-backlog.md and is not yet built here.
 */

const BEDFORDSHIRE_HERTFORDSHIRE_CENTRE: [number, number] = [-0.35, 51.95];

const BASEMAP_STYLE = {
  version: 8 as const,
  sources: {
    osm: {
      type: "raster" as const,
      tiles: ["https://tile.openstreetmap.org/{z}/{x}/{y}.png"],
      tileSize: 256,
      attribution:
        "© OpenStreetMap contributors — replace with licensed OS Maps API / aerial imagery in production, see docs/05-data-source-register.md",
    },
  },
  layers: [{ id: "osm", type: "raster" as const, source: "osm" }],
};

export interface MapViewProps {
  boundary?: GeoJSON.Polygon | null;
  onBoundaryDrawn?: (polygon: GeoJSON.Polygon) => void;
  drawMode?: boolean;
}

export function MapView({ boundary, onBoundaryDrawn, drawMode = false }: MapViewProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const mapRef = useRef<MapLibreMap | null>(null);
  const drawPoints = useRef<[number, number][]>([]);
  const [areaLabel, setAreaLabel] = useState<string>("");

  useEffect(() => {
    if (!containerRef.current || mapRef.current) return;

    const map = new maplibregl.Map({
      container: containerRef.current,
      style: BASEMAP_STYLE,
      center: BEDFORDSHIRE_HERTFORDSHIRE_CENTRE,
      zoom: 11,
    });
    map.addControl(new maplibregl.NavigationControl(), "top-right");
    map.addControl(new maplibregl.ScaleControl({ unit: "metric" }), "bottom-left");

    map.on("load", () => {
      map.addSource("site-boundary", {
        type: "geojson",
        data: { type: "FeatureCollection", features: [] },
      });
      map.addLayer({
        id: "site-boundary-fill",
        type: "fill",
        source: "site-boundary",
        paint: { "fill-color": "#c0392b", "fill-opacity": 0.15 },
      });
      map.addLayer({
        id: "site-boundary-outline",
        type: "line",
        source: "site-boundary",
        paint: { "line-color": "#c0392b", "line-width": 2 },
      });
      mapRef.current = map;
      if (boundary) updateBoundarySource(map, boundary);
    });

    return () => {
      map.remove();
      mapRef.current = null;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    if (mapRef.current && boundary) {
      updateBoundarySource(mapRef.current, boundary);
    }
  }, [boundary]);

  useEffect(() => {
    const map = mapRef.current;
    if (!map || !drawMode) return;

    drawPoints.current = [];

    const handleClick = (e: maplibregl.MapMouseEvent) => {
      drawPoints.current.push([e.lngLat.lng, e.lngLat.lat]);
      renderDraftPolygon(map, drawPoints.current, setAreaLabel);
    };

    const handleDoubleClick = (e: maplibregl.MapMouseEvent) => {
      e.preventDefault();
      if (drawPoints.current.length < 3) return;
      const ring = [...drawPoints.current, drawPoints.current[0]];
      const polygon: GeoJSON.Polygon = { type: "Polygon", coordinates: [ring] };
      onBoundaryDrawn?.(polygon);
      drawPoints.current = [];
    };

    map.on("click", handleClick);
    map.on("dblclick", handleDoubleClick);
    return () => {
      map.off("click", handleClick);
      map.off("dblclick", handleDoubleClick);
    };
  }, [drawMode, onBoundaryDrawn]);

  return (
    <div style={{ position: "relative", width: "100%", height: "100%" }}>
      <div ref={containerRef} style={{ width: "100%", height: "100%" }} />
      {drawMode && (
        <div
          style={{
            position: "absolute",
            top: 12,
            left: 12,
            background: "rgba(255,255,255,0.95)",
            padding: "8px 12px",
            borderRadius: 6,
            fontSize: 13,
            boxShadow: "0 1px 4px rgba(0,0,0,0.2)",
          }}
        >
          Click to add boundary points, double-click to finish.
          {areaLabel && <div>{areaLabel}</div>}
        </div>
      )}
    </div>
  );
}

function updateBoundarySource(map: MapLibreMap, boundary: GeoJSON.Polygon) {
  const source = map.getSource("site-boundary") as maplibregl.GeoJSONSource | undefined;
  source?.setData({
    type: "FeatureCollection",
    features: [{ type: "Feature", properties: {}, geometry: boundary }],
  });
  const coords = boundary.coordinates[0];
  const bounds = coords.reduce(
    (b, c) => b.extend(c as [number, number]),
    new maplibregl.LngLatBounds(coords[0] as [number, number], coords[0] as [number, number])
  );
  map.fitBounds(bounds, { padding: 40, maxZoom: 17 });
}

function renderDraftPolygon(
  map: MapLibreMap,
  points: [number, number][],
  setAreaLabel: (label: string) => void
) {
  const source = map.getSource("site-boundary") as maplibregl.GeoJSONSource | undefined;
  if (!source || points.length < 2) return;
  const ring = points.length >= 3 ? [...points, points[0]] : points;
  source.setData({
    type: "FeatureCollection",
    features: [
      {
        type: "Feature",
        properties: {},
        geometry: points.length >= 3 ? { type: "Polygon", coordinates: [ring] } : { type: "LineString", coordinates: ring },
      },
    ],
  });
  setAreaLabel(`${points.length} point(s) — double-click to finish`);
}
