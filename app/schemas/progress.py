from datetime import datetime

from pydantic import BaseModel


class ProgressUpdate(BaseModel):
    module_id: int
    completed: bool = False
    score: float | None = None   # latest quiz score for the module, 0-100


class ProgressItem(BaseModel):
    module_id: int
    completed: bool
    best_score: float | None = None
    updated_at: datetime | None = None
