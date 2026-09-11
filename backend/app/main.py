from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.routers import screenings, sites

app = FastAPI(
    title="BASECORE Land Promotion Site Assessment Tool API",
    description=(
        "Early-stage desktop screening API for land-promotion opportunities. "
        "See /docs for the interactive OpenAPI schema and docs/04-api-endpoints.md "
        "in the repository for the full endpoint list this scaffold will grow into."
    ),
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(sites.router)
app.include_router(screenings.router)


@app.get("/healthz", tags=["health"])
def healthz() -> dict[str, str]:
    return {"status": "ok"}
