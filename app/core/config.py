from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application settings loaded from environment / .env file."""

    app_name: str = "PrivacyLens API"
    debug: bool = False

    # CORS: the Vite dev server origin
    frontend_origin: str = "http://localhost:5173"
    # Optional regex to allow all deploy URLs of a host (e.g. Vercel previews)
    frontend_origin_regex: str = ""

    # Supabase
    supabase_url: str = ""
    supabase_anon_key: str = ""
    supabase_service_key: str = ""
    supabase_jwt_secret: str = ""

    # Google Gemini
    gemini_api_key: str = ""
    gemini_model: str = "gemini-2.5-flash"

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


@lru_cache
def get_settings() -> Settings:
    return Settings()
