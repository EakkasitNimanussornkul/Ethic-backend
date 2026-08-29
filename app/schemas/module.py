from pydantic import BaseModel

from app.schemas.quiz import QuizQuestion


class Section(BaseModel):
    heading: str
    body: str


class ModuleSummary(BaseModel):
    id: int
    slug: str
    title: str
    summary: str = ""
    order: int


class ModuleDetail(ModuleSummary):
    sections: list[Section] = []
    questions: list[QuizQuestion] = []
