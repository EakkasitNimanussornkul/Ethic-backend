from functools import lru_cache

from app.core.config import get_settings


@lru_cache
def get_supabase():
    """Return a cached Supabase client.

    Requires the `supabase` package (see requirements.txt). Uncomment once
    your Supabase URL and keys are set in .env.
    """
    settings = get_settings()
    # from supabase import create_client
    # return create_client(settings.supabase_url, settings.supabase_service_key)
    raise NotImplementedError("Configure Supabase in app/services/supabase_client.py")
