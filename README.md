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

## Database (Supabase)
Run these once in the Supabase SQL editor, in order:
1. `db/schema.sql` — creates tables + row-level security
2. `db/seed.sql`   — inserts two starter modules and their quiz questions

## Auth model
The frontend logs in with `supabase-js` and sends the Supabase access token as
`Authorization: Bearer <token>`. The backend verifies it in `app/core/auth.py`
using `SUPABASE_JWT_SECRET`, then uses the service-role key for DB access.
