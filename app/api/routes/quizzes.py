from fastapi import APIRouter, Depends

from app.core.auth import get_current_user_id
from app.schemas.quiz import QuizAnswer, QuizResult
from app.services.grading import grade_answer
from app.services.supabase_client import get_supabase

router = APIRouter(prefix="/quizzes", tags=["quizzes"])


@router.post("/grade", response_model=QuizResult)
async def grade_quiz(
    answer: QuizAnswer, user_id: str = Depends(get_current_user_id)
) -> QuizResult:
    """Grade a learner's scenario answer with Gemini and log the attempt."""
    result = await grade_answer(answer)

    get_supabase().table("quiz_attempts").insert(
        {
            "user_id": user_id,
            "question_id": answer.question_id,
            "answer": answer.answer,
            "score": result.score,
            "feedback": result.feedback,
        }
    ).execute()

    return result
