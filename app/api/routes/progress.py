from fastapi import APIRouter, Depends

from app.core.auth import get_current_user_id
from app.schemas.progress import ProgressItem, ProgressUpdate
from app.services.supabase_client import get_supabase

router = APIRouter(prefix="/progress", tags=["progress"])


@router.get("", response_model=list[ProgressItem])
def get_progress(user_id: str = Depends(get_current_user_id)):
    """Return the current learner's progress across all modules."""
    res = (
        get_supabase()
        .table("progress")
        .select("module_id, completed, best_score, updated_at")
        .eq("user_id", user_id)
        .execute()
    )
    return res.data or []


@router.post("", response_model=ProgressItem)
def upsert_progress(
    update: ProgressUpdate, user_id: str = Depends(get_current_user_id)
):
    """Mark a module complete and/or record a new quiz score (keeps the best)."""
    supabase = get_supabase()
    existing = (
        supabase.table("progress")
        .select("completed, best_score")
        .eq("user_id", user_id)
        .eq("module_id", update.module_id)
        .execute()
    )

    best = update.score
    completed = update.completed
    if existing.data:
        prev = existing.data[0]
        completed = completed or bool(prev.get("completed"))
        prev_best = prev.get("best_score")
        if prev_best is not None and (best is None or prev_best > best):
            best = prev_best

    row = {
        "user_id": user_id,
        "module_id": update.module_id,
        "completed": completed,
        "best_score": best,
        "updated_at": "now()",
    }
    res = (
        supabase.table("progress")
        .upsert(row, on_conflict="user_id,module_id")
        .execute()
    )
    return res.data[0]
