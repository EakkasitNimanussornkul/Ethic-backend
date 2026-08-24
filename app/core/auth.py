from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.services.supabase_client import get_supabase

bearer_scheme = HTTPBearer(auto_error=True)


def get_current_user_id(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
) -> str:
    """Verify the caller's Supabase access token and return their user id.

    The frontend logs in with supabase-js and sends the access token as
    `Authorization: Bearer <token>`. We validate it by asking Supabase who the
    token belongs to. This works with both legacy (HS256) JWT secrets and the
    newer asymmetric JWT signing keys, so no shared secret is needed here.
    """
    token = credentials.credentials
    try:
        response = get_supabase().auth.get_user(token)
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        )

    user = getattr(response, "user", None)
    if user is None or not getattr(user, "id", None):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        )
    return user.id
