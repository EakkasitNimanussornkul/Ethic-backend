from typing import Literal

from pydantic import BaseModel

QuestionType = Literal["tf", "mc", "scenario"]


class QuizQuestion(BaseModel):
    id: int
    module_id: int
    order: int = 0
    type: QuestionType
    prompt: str
    scenario: str = ""
    # Present only for multiple-choice questions. Correct answers and rubrics
    # are deliberately NOT included here — they never reach the browser.
    options: list[str] | None = None


class QuizAnswer(BaseModel):
    question_id: int
    answer: str


class QuizResult(BaseModel):
    score: float          # 0-100
    feedback: str
    question_id: int
    correct: bool | None = None   # set for auto-graded (tf/mc) questions


class QuizSubmission(BaseModel):
    module_id: int
    answers: list[QuizAnswer]


class QuizSubmissionResult(BaseModel):
    score: float                  # average across all questions, 0-100
    results: list[QuizResult]
