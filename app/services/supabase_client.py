from functools import lru_cache

from supabase import Client, create_client

from app.core.config import get_settings


@lru_cache
def get_supabase() -> Client:
    """Return a cached server-side Supabase client.

    Uses the service-role key so the backend can read/write tables after it
    has already verified the caller's identity from their JWT. This key must
    never reach the frontend.
    """
    settings = get_settings()
    if not settings.supabase_url or not settings.supabase_service_key:
        raise RuntimeError("SUPABASE_URL and SUPABASE_SERVICE_KEY must be set in .env")
    return create_client(settings.supabase_url, settings.supabase_service_key)
