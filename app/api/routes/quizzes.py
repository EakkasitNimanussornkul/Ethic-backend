from fastapi import APIRouter

from app.schemas.quiz import QuizAnswer, QuizResult
from app.services.grading import grade_answer

router = APIRouter(prefix="/quizzes", tags=["quizzes"])


@router.post("/grade", response_model=QuizResult)
async def grade_quiz(answer: QuizAnswer) -> QuizResult:
    """Send a learner's scenario answer + rubric to Gemini for grading."""
    return await grade_answer(answer)
