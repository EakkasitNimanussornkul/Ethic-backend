from pydantic import BaseModel

from app.schemas.quiz import QuizQuestion


class ModuleSummary(BaseModel):
    id: int
    slug: str
    title: str
    order: int


class ModuleDetail(ModuleSummary):
    content: str
    case_study: str
    questions: list[QuizQuestion] = []
