import json

from fastapi import HTTPException
from google import genai

from app.core.config import get_settings
from app.schemas.quiz import QuizAnswer, QuizResult
from app.services.supabase_client import get_supabase

_GRADING_INSTRUCTIONS = """You are grading a learner's answer to a data-privacy \
scenario in an ethics course. Judge the *reasoning*, not exact wording. Award \
partial credit where the learner shows sound judgment. Be encouraging but honest.

Scenario:
{scenario}

Question:
{prompt}

Grading rubric / ideal answer:
{rubric}

Learner's answer:
{answer}

Respond with ONLY a JSON object of the form:
{{"score": <integer 0-100>, "feedback": "<2-4 sentences explaining the score and \
the key privacy reasoning>"}}"""


def _client() -> genai.Client:
    settings = get_settings()
    if not settings.gemini_api_key:
        raise HTTPException(status_code=500, detail="GEMINI_API_KEY is not configured")
    return genai.Client(api_key=settings.gemini_api_key)


async def grade_answer(answer: QuizAnswer) -> QuizResult:
    """Grade a scenario answer against its stored rubric using Gemini."""
    supabase = get_supabase()
    row = (
        supabase.table("quiz_questions")
        .select("prompt, scenario, rubric")
        .eq("id", answer.question_id)
        .single()
        .execute()
    )
    if not row.data:
        raise HTTPException(status_code=404, detail="Question not found")

    prompt = _GRADING_INSTRUCTIONS.format(
        scenario=row.data["scenario"],
        prompt=row.data["prompt"],
        rubric=row.data["rubric"],
        answer=answer.answer,
    )

    settings = get_settings()
    # Use the async client (.aio); the sync client fails inside the event loop.
    response = await _client().aio.models.generate_content(
        model=settings.gemini_model,
        contents=prompt,
        config={"response_mime_type": "application/json"},
    )

    try:
        data = json.loads(response.text)
        score = float(data["score"])
        feedback = str(data["feedback"])
    except (json.JSONDecodeError, KeyError, TypeError, ValueError):
        raise HTTPException(status_code=502, detail="Could not parse grading response")

    score = max(0.0, min(100.0, score))
    return QuizResult(score=score, feedback=feedback, question_id=answer.question_id)
