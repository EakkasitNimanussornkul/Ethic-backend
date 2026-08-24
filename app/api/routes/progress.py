from fastapi import APIRouter

router = APIRouter(prefix="/progress", tags=["progress"])


@router.get("/{user_id}")
async def get_progress(user_id: str):
    """Return a learner's module completion + quiz history (from Supabase)."""
    # TODO: query Supabase
    return {"user_id": user_id, "modules_completed": [], "scores": []}
