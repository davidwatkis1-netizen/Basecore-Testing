import { useEffect, useState } from "react";
import Link from "next/link";
import { listSites, Site } from "@/lib/api";

/**
 * Portfolio dashboard landing page — scaffold for docs/09-ui-wireframes.md §9.1.
 * Table view only; the map view and filter rail are MVP backlog item #14.
 */
export default function Dashboard() {
  const [sites, setSites] = useState<Site[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    listSites()
      .then(setSites)
      .catch((e) => setError(String(e)));
  }, []);

  return (
    <main style={{ padding: 24, maxWidth: 1000, margin: "0 auto" }}>
      <header style={{ display: "flex", justifyContent: "space-between", alignItems: "center" }}>
        <h1 style={{ fontSize: 20 }}>BASECORE Site Assessment — Portfolio</h1>
        <Link
          href="/sites/new"
          style={{
            background: "#1a5276",
            color: "white",
            padding: "8px 14px",
            borderRadius: 6,
            textDecoration: "none",
            fontSize: 14,
          }}
        >
          + New site
        </Link>
      </header>

      <div className="disclaimer-banner">
        Early-stage desktop screening only. Does not confirm ownership, legal access, planning
        permission, utility capacity, drainage consent, ecology status, contamination
        condition, ground condition or valuation. See docs/16 for full disclaimer.
      </div>

      {error && (
        <p style={{ color: "#c0392b" }}>
          Could not reach the API ({error}). Start the backend with{" "}
          <code>uvicorn app.main:app --reload</code> from <code>backend/</code>.
        </p>
      )}

      <table style={{ width: "100%", borderCollapse: "collapse", marginTop: 16 }}>
        <thead>
          <tr style={{ textAlign: "left", borderBottom: "2px solid #ddd" }}>
            <th style={{ padding: 8 }}>Reference</th>
            <th style={{ padding: 8 }}>Name</th>
            <th style={{ padding: 8 }}>LPA</th>
            <th style={{ padding: 8 }}>Status</th>
            <th style={{ padding: 8 }}>Area (ha)</th>
          </tr>
        </thead>
        <tbody>
          {sites.map((s) => (
            <tr key={s.id} style={{ borderBottom: "1px solid #eee" }}>
              <td style={{ padding: 8 }}>{s.site_reference}</td>
              <td style={{ padding: 8 }}>{s.site_name}</td>
              <td style={{ padding: 8 }}>{s.lpa_name ?? "—"}</td>
              <td style={{ padding: 8 }}>{s.status}</td>
              <td style={{ padding: 8 }}>{s.current_boundary?.area_ha ?? "—"}</td>
            </tr>
          ))}
          {sites.length === 0 && !error && (
            <tr>
              <td colSpan={5} style={{ padding: 16, textAlign: "center", color: "#888" }}>
                No sites yet — create one to get started.
              </td>
            </tr>
          )}
        </tbody>
      </table>
    </main>
  );
}
