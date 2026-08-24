from fastapi import APIRouter, Depends, HTTPException

from app.core.auth import get_current_user_id
from app.schemas.module import ModuleDetail, ModuleSummary
from app.services.supabase_client import get_supabase

router = APIRouter(prefix="/modules", tags=["modules"])


@router.get("", response_model=list[ModuleSummary])
def list_modules(_: str = Depends(get_current_user_id)):
    """Return every course module (ordered), without content."""
    supabase = get_supabase()
    res = (
        supabase.table("modules")
        .select("id, slug, title, order")
        .order("order")
        .execute()
    )
    return res.data or []


@router.get("/{module_id}", response_model=ModuleDetail)
def get_module(module_id: int, _: str = Depends(get_current_user_id)):
    """Return one module's reading content, case study, and quiz questions."""
    supabase = get_supabase()
    mod = (
        supabase.table("modules")
        .select("id, slug, title, order, content, case_study")
        .eq("id", module_id)
        .single()
        .execute()
    )
    if not mod.data:
        raise HTTPException(status_code=404, detail="Module not found")

    questions = (
        supabase.table("quiz_questions")
        .select("id, module_id, prompt, scenario")
        .eq("module_id", module_id)
        .order("id")
        .execute()
    )
    return {**mod.data, "questions": questions.data or []}
