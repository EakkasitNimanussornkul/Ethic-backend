-- PrivacyLens database schema (run in Supabase SQL editor)

-- Course modules --------------------------------------------------------------
create table if not exists modules (
    id          bigint generated always as identity primary key,
    slug        text unique not null,
    title       text not null,
    "order"     int  not null default 0,
    content     text not null default '',
    case_study  text not null default '',
    created_at  timestamptz not null default now()
);

-- Scenario quiz questions -----------------------------------------------------
create table if not exists quiz_questions (
    id          bigint generated always as identity primary key,
    module_id   bigint not null references modules(id) on delete cascade,
    prompt      text not null,
    scenario    text not null,
    rubric      text not null,          -- ideal answer / grading guidance (server-only)
    created_at  timestamptz not null default now()
);

-- Per-learner progress --------------------------------------------------------
create table if not exists progress (
    id          bigint generated always as identity primary key,
    user_id     uuid not null references auth.users(id) on delete cascade,
    module_id   bigint not null references modules(id) on delete cascade,
    completed   boolean not null default false,
    best_score  numeric,
    updated_at  timestamptz not null default now(),
    unique (user_id, module_id)
);

-- History of graded attempts --------------------------------------------------
create table if not exists quiz_attempts (
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

-- Course content is readable by any signed-in learner (rubric stays server-only:
-- do not expose quiz_questions.rubric through anon reads).
create policy "modules readable" on modules
    for select using (auth.role() = 'authenticated');

-- Learners can only see and write their own progress / attempts.
create policy "own progress" on progress
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "own attempts" on quiz_attempts
    for all using (auth.uid() = user_id) with check (auth.uid() = user_id);
