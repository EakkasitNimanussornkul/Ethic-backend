from fastapi import APIRouter, Depends, HTTPException

from app.core.auth import get_current_user_id
from app.schemas.quiz import QuizSubmission, QuizSubmissionResult
from app.services.grading import grade_submission
from app.services.supabase_client import get_supabase

router = APIRouter(prefix="/quizzes", tags=["quizzes"])


@router.post("/submit", response_model=QuizSubmissionResult)
async def submit_quiz(
    submission: QuizSubmission, user_id: str = Depends(get_current_user_id)
) -> QuizSubmissionResult:
    """Grade a whole module test at once, log attempts, and save progress."""
    if not submission.answers:
        raise HTTPException(status_code=400, detail="No answers submitted")

    results = await grade_submission(submission.answers)
    supabase = get_supabase()

    supabase.table("quiz_attempts").insert(
        [
            {
                "user_id": user_id,
                "question_id": a.question_id,
                "answer": a.answer,
                "score": r.score,
                "feedback": r.feedback,
            }
            for a, r in zip(submission.answers, results)
        ]
    ).execute()

    avg = sum(r.score for r in results) / len(results)
    supabase.table("progress").upsert(
        {
            "user_id": user_id,
            "module_id": submission.module_id,
            "completed": True,
            "best_score": avg,
            "updated_at": "now()",
        },
        on_conflict="user_id,module_id",
    ).execute()

    return QuizSubmissionResult(score=avg, results=results)
