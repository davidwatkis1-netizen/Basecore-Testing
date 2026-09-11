import { useRouter } from "next/router";
import { useEffect, useState } from "react";
import dynamic from "next/dynamic";
import { listSites, runScreening, Site, ScreeningResult } from "@/lib/api";

const MapView = dynamic(() => import("@/components/MapView").then((m) => m.MapView), {
  ssr: false,
});

/**
 * Site workspace scaffold — a single-page slice of docs/09-ui-wireframes.md §9.3 covering
 * the Map tab and a "run screening" action. The full tab rail (Planning, Title, Technical,
 * Commercial, Risk & Opportunity, Reports, Audit Log) is the remainder of the MVP backlog.
 */
export default function SiteWorkspace() {
  const router = useRouter();
  const { id } = router.query;
  const [site, setSite] = useState<Site | null>(null);
  const [results, setResults] = useState<ScreeningResult[]>([]);
  const [running, setRunning] = useState(false);

  useEffect(() => {
    if (typeof id !== "string") return;
    listSites().then((sites) => setSite(sites.find((s) => s.id === id) ?? null));
  }, [id]);

  async function handleRunScreening() {
    if (typeof id !== "string") return;
    setRunning(true);
    try {
      const response = await runScreening(id);
      setResults(response.results);
    } finally {
      setRunning(false);
    }
  }

  if (!site) return <p style={{ padding: 24 }}>Loading site…</p>;

  return (
    <main style={{ display: "flex", height: "100vh" }}>
      <div style={{ flex: 2, position: "relative" }}>
        <MapView boundary={site.current_boundary?.geometry ?? null} />
      </div>
      <aside style={{ flex: 1, padding: 16, overflowY: "auto", borderLeft: "1px solid #ddd" }}>
        <h2 style={{ fontSize: 16 }}>{site.site_name}</h2>
        <p style={{ color: "#666", fontSize: 13 }}>
          {site.site_reference} · {site.status} · {site.current_boundary?.area_ha} ha
        </p>

        <button
          onClick={handleRunScreening}
          disabled={running}
          style={{
            background: "#1a5276",
            color: "white",
            border: "none",
            padding: "8px 14px",
            borderRadius: 6,
            cursor: "pointer",
            marginBottom: 16,
          }}
        >
          {running ? "Screening…" : "Run screening"}
        </button>

        <h3 style={{ fontSize: 14 }}>Screening results</h3>
        {results.length === 0 && <p style={{ color: "#888", fontSize: 13 }}>No results yet.</p>}
        <ul style={{ listStyle: "none", padding: 0, fontSize: 13 }}>
          {results.map((r) => (
            <li key={r.id} style={{ marginBottom: 8, borderBottom: "1px solid #eee", paddingBottom: 8 }}>
              <strong>{r.feature_name}</strong>
              <div>{r.theme} · {r.buffer_band} · {r.distance_m} m</div>
              <div style={{ color: "#888" }}>{r.source}</div>
            </li>
          ))}
        </ul>
      </aside>
    </main>
  );
}
