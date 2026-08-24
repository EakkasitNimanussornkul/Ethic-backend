from app.schemas.quiz import QuizAnswer, QuizResult


async def grade_answer(answer: QuizAnswer) -> QuizResult:
    """Grade a scenario answer against a stored rubric using Gemini.

    Placeholder: fetch the rubric/ideal answer for `answer.question_id` from
    Supabase, send it plus the learner answer to the Gemini API, and map the
    returned score + feedback into a QuizResult.
    """
    return QuizResult(score=0.0, feedback="Grading not implemented yet.")
