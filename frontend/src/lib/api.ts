const API_BASE = process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8000";

export interface SiteBoundaryVersion {
  id: string;
  site_id: string;
  version_number: number;
  geometry: GeoJSON.Polygon;
  area_sqm: number;
  area_ha: number;
  source_method: string;
  is_current: boolean;
  created_at: string;
}

export interface Site {
  id: string;
  site_reference: string;
  site_name: string;
  address?: string | null;
  postcode?: string | null;
  lpa_name?: string | null;
  status: string;
  confidentiality: string;
  current_boundary?: SiteBoundaryVersion | null;
}

export async function listSites(): Promise<Site[]> {
  const res = await fetch(`${API_BASE}/api/v1/sites`);
  if (!res.ok) throw new Error(`Failed to list sites: ${res.status}`);
  return res.json();
}

export async function createSite(payload: {
  site_name: string;
  boundary_geojson?: GeoJSON.Polygon;
  boundary_source_method?: string;
}): Promise<Site> {
  const res = await fetch(`${API_BASE}/api/v1/sites`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
  if (!res.ok) throw new Error(`Failed to create site: ${res.status}`);
  return res.json();
}

export interface ScreeningResult {
  id: string;
  theme: string;
  feature_name: string;
  source: string;
  buffer_band: string;
  distance_m: number;
}

export async function runScreening(siteId: string): Promise<{
  site_id: string;
  buffers_m: Record<string, number>;
  results: ScreeningResult[];
}> {
  const res = await fetch(`${API_BASE}/api/v1/sites/${siteId}/screenings`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({}),
  });
  if (!res.ok) throw new Error(`Failed to run screening: ${res.status}`);
  return res.json();
}
