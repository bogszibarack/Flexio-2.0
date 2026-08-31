-- Tesztadatbázis a perzisztencia / RLS / sync izolációs tesztekhez.
-- Szándékosan önálló: nincs szükség Supabase auth sémára, de a
-- flexio_current_user_id() és a policy-k ugyanazt a szerződést tartják.

create schema if not exists auth;

create or replace function auth.uid()
returns uuid
language sql
stable
as $$
  select null::uuid;
$$;

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  if new.updated_at is not distinct from old.updated_at then
    new.updated_at = now();
  end if;
  return new;
end;
$$;

do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then
    create role anon nologin;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then
    create role authenticated nologin;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'flexio_api') then
    create role flexio_api login password 'flexio_api_test' nobypassrls;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'flexio_jobs') then
    create role flexio_jobs login password 'flexio_jobs_test' nobypassrls;
  end if;
end;
$$;

grant authenticated to flexio_api;
grant usage on schema auth to anon, authenticated, flexio_api, flexio_jobs;
grant execute on function auth.uid() to anon, authenticated, flexio_api, flexio_jobs;

create or replace function public.flexio_current_user_id()
returns uuid
language plpgsql
stable
as $$
declare
  configured text;
begin
  configured := nullif(current_setting('app.current_user_id', true), '');
  if configured is not null then
    return configured::uuid;
  end if;

  return auth.uid();
end;
$$;

grant execute on function public.flexio_current_user_id() to anon, authenticated, flexio_api, flexio_jobs;

create table if not exists public.profiles (
  user_id uuid primary key,
  first_name text,
  gender text,
  birth_date date,
  height_cm numeric(5, 1),
  weight_kg numeric(5, 1),
  activity_level text not null default 'moderate',
  goal text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.goals (
  user_id uuid primary key,
  calorie_goal numeric(9, 2),
  protein_goal numeric(9, 2),
  fat_goal numeric(9, 2),
  carbs_goal numeric(9, 2),
  water_goal_ml integer,
  is_manual boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.diary_entries (
  id uuid primary key,
  user_id uuid not null,
  logged_at timestamptz not null default now(),
  local_date date not null default current_date,
  meal_type text not null default 'lunch',
  food_id uuid,
  food_name text not null,
  food_image text,
  amount_g numeric(9, 2) not null default 100,
  serving_label text,
  kcal numeric(9, 2) not null default 0,
  protein numeric(9, 2) not null default 0,
  fat numeric(9, 2) not null default 0,
  carbs numeric(9, 2) not null default 0,
  sugar numeric(9, 2),
  saturated_fat numeric(9, 2),
  salt numeric(9, 2),
  fiber numeric(9, 2),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.workout_sessions (
  id uuid primary key,
  user_id uuid not null,
  title text not null,
  kind text not null default 'completed',
  scheduled_at timestamptz,
  started_at timestamptz,
  completed_at timestamptz,
  duration_minutes integer,
  calories numeric(9, 2),
  difficulty text,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.sleep_entries (
  id uuid primary key,
  user_id uuid not null,
  bedtime timestamptz not null,
  wake_time timestamptz not null,
  quality integer,
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.foods (
  id uuid primary key default gen_random_uuid(),
  source text not null check (source in ('curated', 'off', 'user')),
  name text not null,
  owner_id uuid,
  kcal numeric(9, 2) not null default 0,
  protein numeric(9, 2) not null default 0,
  fat numeric(9, 2) not null default 0,
  carbs numeric(9, 2) not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists profiles_touch_updated_at on public.profiles;
create trigger profiles_touch_updated_at
  before update on public.profiles
  for each row execute function public.touch_updated_at();

drop trigger if exists diary_entries_touch_updated_at on public.diary_entries;
create trigger diary_entries_touch_updated_at
  before update on public.diary_entries
  for each row execute function public.touch_updated_at();

drop trigger if exists workout_sessions_touch_updated_at on public.workout_sessions;
create trigger workout_sessions_touch_updated_at
  before update on public.workout_sessions
  for each row execute function public.touch_updated_at();

drop trigger if exists sleep_entries_touch_updated_at on public.sleep_entries;
create trigger sleep_entries_touch_updated_at
  before update on public.sleep_entries
  for each row execute function public.touch_updated_at();

alter table public.profiles enable row level security;
alter table public.goals enable row level security;
alter table public.diary_entries enable row level security;
alter table public.workout_sessions enable row level security;
alter table public.sleep_entries enable row level security;
alter table public.foods enable row level security;

drop policy if exists profiles_owner on public.profiles;
create policy profiles_owner on public.profiles
  for all to authenticated
  using (user_id = (select public.flexio_current_user_id()))
  with check (user_id = (select public.flexio_current_user_id()));

drop policy if exists goals_owner on public.goals;
create policy goals_owner on public.goals
  for all to authenticated
  using (user_id = (select public.flexio_current_user_id()))
  with check (user_id = (select public.flexio_current_user_id()));

drop policy if exists diary_entries_owner on public.diary_entries;
create policy diary_entries_owner on public.diary_entries
  for all to authenticated
  using (user_id = (select public.flexio_current_user_id()))
  with check (user_id = (select public.flexio_current_user_id()));

drop policy if exists workout_sessions_owner on public.workout_sessions;
create policy workout_sessions_owner on public.workout_sessions
  for all to authenticated
  using (user_id = (select public.flexio_current_user_id()))
  with check (user_id = (select public.flexio_current_user_id()));

drop policy if exists sleep_entries_owner on public.sleep_entries;
create policy sleep_entries_owner on public.sleep_entries
  for all to authenticated
  using (user_id = (select public.flexio_current_user_id()))
  with check (user_id = (select public.flexio_current_user_id()));

drop policy if exists foods_select on public.foods;
create policy foods_select on public.foods
  for select using (
    owner_id is null or owner_id = (select public.flexio_current_user_id())
  );

drop policy if exists foods_insert_own on public.foods;
create policy foods_insert_own on public.foods
  for insert to authenticated
  with check (
    owner_id = (select public.flexio_current_user_id()) and source = 'user'
  );

drop policy if exists foods_jobs_all on public.foods;
create policy foods_jobs_all on public.foods
  for all to flexio_jobs using (true) with check (true);

grant usage on schema public to anon, authenticated, flexio_api, flexio_jobs;
grant select, insert, update, delete on
  public.profiles, public.goals, public.diary_entries,
  public.workout_sessions, public.sleep_entries, public.foods
  to authenticated, flexio_api;
grant select, insert, update, delete on public.foods to flexio_jobs;
