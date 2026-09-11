from fastapi.testclient import TestClient

from app.main import app

client = TestClient(app)

BOUNDARY = {
    "type": "Polygon",
    "coordinates": [[
        [-0.36021, 52.05587],
        [-0.35932, 52.05601],
        [-0.35911, 52.05548],
        [-0.36004, 52.05531],
        [-0.36021, 52.05587],
    ]],
}


def test_healthz():
    r = client.get("/healthz")
    assert r.status_code == 200
    assert r.json() == {"status": "ok"}


def test_create_site_computes_area():
    r = client.post(
        "/api/v1/sites",
        json={
            "site_name": "Land off Poplar Farm Lane",
            "boundary_geojson": BOUNDARY,
            "boundary_source_method": "drawn",
        },
    )
    assert r.status_code == 201
    body = r.json()
    assert body["site_reference"].startswith("BAS-")
    # Known reference site is ~0.42 ha (docs/12-sample-site-assessment.json) - allow tolerance
    # for the simplified demo polygon used here.
    assert 0.3 < body["current_boundary"]["area_ha"] < 0.5


def test_screening_returns_within_site_result():
    create = client.post(
        "/api/v1/sites",
        json={
            "site_name": "Screening test site",
            "boundary_geojson": BOUNDARY,
            "boundary_source_method": "drawn",
        },
    )
    site_id = create.json()["id"]

    r = client.post(f"/api/v1/sites/{site_id}/screenings", json={})
    assert r.status_code == 200
    results = r.json()["results"]
    assert any(res["buffer_band"] == "within_site" for res in results)


def test_screening_without_boundary_fails():
    create = client.post("/api/v1/sites", json={"site_name": "No boundary yet"})
    site_id = create.json()["id"]

    r = client.post(f"/api/v1/sites/{site_id}/screenings", json={})
    assert r.status_code == 400
