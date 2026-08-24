# PrivacyLens — Backend (FastAPI)

## Setup
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env   # then fill in Supabase + Gemini keys
```

## Run (dev)
```bash
uvicorn app.main:app --reload
```
API docs: http://localhost:8000/docs

## Layout
```
Backend/
  app/
    main.py            # FastAPI app, CORS, mounts routers
    api/routes/        # endpoint groups (health, quizzes, progress)
    core/              # config/settings
    schemas/           # Pydantic request/response models
    models/            # DB/table models (Supabase)
    services/          # Gemini grading, Supabase client
  requirements.txt
  .env.example
```
