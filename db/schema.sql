-- PrivacyLens database schema (run in Supabase SQL editor).
-- NOTE: this resets the content tables. Learner progress is test data only.

drop table if exists quiz_attempts cascade;
drop table if exists quiz_questions cascade;
drop table if exists progress cascade;
drop table if exists modules cascade;

-- Course modules --------------------------------------------------------------
-- `sections` holds the reading content as an ordered list of small blocks:
--   [{ "heading": "…", "body": "…" }, …]  (3 per module)
create table modules (
    id          bigint generated always as identity primary key,
    slug        text unique not null,
    title       text not null,
    summary     text not null default '',
    "order"     int  not null default 0,
    sections    jsonb not null default '[]'::jsonb,
    -- Real sources for the module's content: [{ "citation": "…", "url": "…" }, …]
    "references" jsonb not null default '[]'::jsonb,
    created_at  timestamptz not null default now()
);

-- Quiz questions --------------------------------------------------------------
-- type: 'tf' (true/false) and 'mc' (multiple choice) are auto-graded;
--       'scenario' is graded by Gemini against `rubric`.
-- options:        for 'mc', a JSON array of choice strings.
-- correct_answer: for 'tf' ('true'/'false') and 'mc' (exact choice string).
-- rubric:         grading guidance for 'scenario'; the explanation shown after
--                 answering for 'tf'/'mc'. Never exposed before answering.
create table quiz_questions (
    id             bigint generated always as identity primary key,
    module_id      bigint not null references modules(id) on delete cascade,
    "order"        int not null default 0,
    type           text not null check (type in ('tf', 'mc', 'scenario')),
    prompt         text not null,
    scenario       text not null default '',
    options        jsonb,
    correct_answer text,
    rubric         text not null default '',
    created_at     timestamptz not null default now()
);

-- Per-learner progress --------------------------------------------------------
create table progress (
    id          bigint generated always as identity primary key,
    user_id     uuid not null references auth.users(id) on delete cascade,
    module_id   bigint not null references modules(id) on delete cascade,
    completed   boolean not null default false,
    best_score  numeric,
    updated_at  timestamptz not null default now(),
    unique (user_id, module_id)
);

-- History of graded attempts --------------------------------------------------
create table quiz_attempts (
    id          bigint generated always as identity primary key,
    user_id     uuid not null references auth.users(id) on delete cascade,
    question_id bigint not null references quiz_questions(id) on delete cascade,
    answer      text not null,
    score       numeric not null,
    feedback    text not null,
    created_at  timestamptz not null default now()
);

-- Row Level Security ----------------------------------------------------------
-- The backend uses the service-role key (bypasses RLS). These policies protect
-- the tables if the frontend ever reads them directly with the anon key.
alter table modules        enable row level security;
alter table quiz_questions enable row level security;
alter table progress       enable row level security;
alter table quiz_attempts  enable row level security;

create policy "modules readable" on modules
    for select using (auth.role() = 'authenticated');

-- Do NOT expose quiz_questions to the anon key: it holds correct answers and
-- rubrics. All quiz reads/writes go through the backend service key.
create policy "own progress" on progress
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own attempts" on quiz_attempts
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
