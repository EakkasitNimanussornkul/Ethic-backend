from pydantic import BaseModel


class QuizAnswer(BaseModel):
    question_id: str
    user_id: str
    answer: str


class QuizResult(BaseModel):
    score: float
    feedback: str
