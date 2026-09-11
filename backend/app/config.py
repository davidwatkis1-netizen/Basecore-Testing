from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Runtime configuration, loaded from environment variables / .env.

    See docs/16-assumptions-licensing-and-professional-advice.md for the secrets-handling
    requirement: real deployments must source these from Azure Key Vault, never a committed
    .env file.
    """

    environment: str = "development"
    database_url: str = "postgresql+psycopg://basecore:basecore@localhost:5432/basecore"

    entra_tenant_id: str = ""
    entra_client_id: str = ""

    os_data_hub_api_key: str = ""
    what3words_api_key: str = ""

    default_buffer_immediate_m: int = 50
    default_buffer_context_m: int = 250
    default_buffer_comparables_m: int = 500

    class Config:
        env_file = ".env"
        env_prefix = "BASECORE_"


settings = Settings()
