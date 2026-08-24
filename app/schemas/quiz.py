from pydantic import BaseModel


class QuizQuestion(BaseModel):
    id: int
    module_id: int
    prompt: str
    scenario: str


class QuizAnswer(BaseModel):
    question_id: int
    answer: str


class QuizResult(BaseModel):
    score: float          # 0-100
    feedback: str
    question_id: int
