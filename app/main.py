from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes import health, modules, progress, quizzes
from app.core.config import get_settings

settings = get_settings()

app = FastAPI(title=settings.app_name, debug=settings.debug)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[settings.frontend_origin],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Route groups live under app/api/routes/ and are mounted here
app.include_router(health.router)
app.include_router(modules.router, prefix="/api")
app.include_router(quizzes.router, prefix="/api")
app.include_router(progress.router, prefix="/api")


@app.get("/")
def root():
    return {"service": settings.app_name, "docs": "/docs"}
