from fastapi import APIRouter, Depends, HTTPException

from app.core.auth import get_current_user_id
from app.schemas.module import ModuleDetail, ModuleSummary
from app.services.supabase_client import get_supabase

router = APIRouter(prefix="/modules", tags=["modules"])


@router.get("", response_model=list[ModuleSummary])
def list_modules(_: str = Depends(get_current_user_id)):
    """Return every course module (ordered), without content."""
    res = (
        get_supabase()
        .table("modules")
        .select("id, slug, title, summary, order")
        .order("order")
        .execute()
    )
    return res.data or []


@router.get("/{module_id}", response_model=ModuleDetail)
def get_module(module_id: int, _: str = Depends(get_current_user_id)):
    """Return one module's sections and quiz questions.

    Correct answers and rubrics are stripped so they never reach the browser.
    """
    supabase = get_supabase()
    mod = (
        supabase.table("modules")
        .select("id, slug, title, summary, order, sections, references")
        .eq("id", module_id)
        .single()
        .execute()
    )
    if not mod.data:
        raise HTTPException(status_code=404, detail="Module not found")

    rows = (
        supabase.table("quiz_questions")
        .select("id, module_id, order, type, prompt, scenario, options")
        .eq("module_id", module_id)
        .order("order")
        .execute()
    )
    return {**mod.data, "questions": rows.data or []}
