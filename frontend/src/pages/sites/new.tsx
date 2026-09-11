import { useRouter } from "next/router";
import { useState } from "react";
import dynamic from "next/dynamic";
import { createSite } from "@/lib/api";

// MapLibre reads window/DOM at import time, so it must be client-only.
const MapView = dynamic(() => import("@/components/MapView").then((m) => m.MapView), {
  ssr: false,
});

/**
 * "Create site" wizard scaffold — the map-draw path of docs/09-ui-wireframes.md §9.2.
 * Address/postcode/UPRN/grid-ref/what3words search and file upload are MVP backlog item #2
 * and are not yet implemented in this scaffold; only draw-a-polygon is wired end-to-end.
 */
export default function NewSitePage() {
  const router = useRouter();
  const [siteName, setSiteName] = useState("");
  const [boundary, setBoundary] = useState<GeoJSON.Polygon | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  async function handleCreate() {
    if (!siteName || !boundary) return;
    setSubmitting(true);
    setError(null);
    try {
      const site = await createSite({
        site_name: siteName,
        boundary_geojson: boundary,
        boundary_source_method: "drawn",
      });
      router.push(`/sites/${site.id}`);
    } catch (e) {
      setError(String(e));
    } finally {
      setSubmitting(false);
    }
  }

  return (
    <main style={{ display: "flex", flexDirection: "column", height: "100vh" }}>
      <header style={{ padding: 16, borderBottom: "1px solid #ddd" }}>
        <h1 style={{ fontSize: 18, margin: 0 }}>New site — draw boundary</h1>
      </header>
      <div style={{ flex: 1, position: "relative" }}>
        <MapView drawMode onBoundaryDrawn={setBoundary} boundary={boundary} />
      </div>
      <footer
        style={{
          padding: 16,
          borderTop: "1px solid #ddd",
          display: "flex",
          gap: 12,
          alignItems: "center",
        }}
      >
        <input
          placeholder="Site name"
          value={siteName}
          onChange={(e) => setSiteName(e.target.value)}
          style={{ padding: 8, flex: 1, maxWidth: 320 }}
        />
        <span style={{ color: "#666", fontSize: 13 }}>
          {boundary ? "Boundary drawn ✓" : "Draw a boundary on the map above"}
        </span>
        {error && <span style={{ color: "#c0392b" }}>{error}</span>}
        <button
          onClick={handleCreate}
          disabled={!siteName || !boundary || submitting}
          style={{
            marginLeft: "auto",
            background: "#1a5276",
            color: "white",
            border: "none",
            padding: "10px 18px",
            borderRadius: 6,
            cursor: "pointer",
          }}
        >
          {submitting ? "Creating…" : "Create and run screening"}
        </button>
      </footer>
    </main>
  );
}
