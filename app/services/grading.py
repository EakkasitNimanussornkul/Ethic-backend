import asyncio
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


def _fetch_question(question_id: int) -> dict:
    row = (
        get_supabase()
        .table("quiz_questions")
        .select("id, type, prompt, scenario, rubric, correct_answer")
        .eq("id", question_id)
        .single()
        .execute()
    )
    if not row.data:
        raise HTTPException(status_code=404, detail=f"Question {question_id} not found")
    return row.data


async def grade_answer(answer: QuizAnswer) -> QuizResult:
    """Grade a single answer: tf/mc are auto-graded; scenario goes to Gemini."""
    q = _fetch_question(answer.question_id)
    if q["type"] in ("tf", "mc"):
        return _grade_objective(answer, q)
    return await _grade_scenario(answer, q)


async def grade_submission(answers: list[QuizAnswer]) -> list[QuizResult]:
    """Grade a whole test. Objective questions are instant; scenario questions
    are graded by Gemini concurrently so a full submission stays fast."""
    questions = {a.question_id: _fetch_question(a.question_id) for a in answers}

    results: dict[int, QuizResult] = {}
    scenario_tasks = []
    for a in answers:
        q = questions[a.question_id]
        if q["type"] in ("tf", "mc"):
            results[a.question_id] = _grade_objective(a, q)
        else:
            scenario_tasks.append((a.question_id, _grade_scenario(a, q)))

    if scenario_tasks:
        graded = await asyncio.gather(*(t for _, t in scenario_tasks))
        for (qid, _), result in zip(scenario_tasks, graded):
            results[qid] = result

    # preserve the submitted order
    return [results[a.question_id] for a in answers]


def _grade_objective(answer: QuizAnswer, q: dict) -> QuizResult:
    correct_answer = (q.get("correct_answer") or "").strip().lower()
    given = answer.answer.strip().lower()
    is_correct = given == correct_answer
    explanation = q.get("rubric") or ""
    feedback = ("Correct. " if is_correct else "Not quite. ") + explanation
    return QuizResult(
        score=100.0 if is_correct else 0.0,
        feedback=feedback.strip(),
        question_id=answer.question_id,
        correct=is_correct,
    )


async def _grade_scenario(answer: QuizAnswer, q: dict) -> QuizResult:
    if not answer.answer.strip():
        return QuizResult(
            score=0.0, feedback="No answer was provided.", question_id=answer.question_id
        )
    prompt = _GRADING_INSTRUCTIONS.format(
        scenario=q.get("scenario", ""),
        prompt=q["prompt"],
        rubric=q.get("rubric", ""),
        answer=answer.answer,
    )
    settings = get_settings()
    response = await _client().aio.models.generate_content(
        model=settings.gemini_model,
        contents=prompt,
        config={"response_mime_type": "application/json"},
    )
    try:
        data = json.loads(response.text)
        score = max(0.0, min(100.0, float(data["score"])))
        feedback = str(data["feedback"])
    except (json.JSONDecodeError, KeyError, TypeError, ValueError):
        raise HTTPException(status_code=502, detail="Could not parse grading response")

    return QuizResult(score=score, feedback=feedback, question_id=answer.question_id)
