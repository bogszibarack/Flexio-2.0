-- Flexio alapséma: ételkatalógus, felhasználói profil és a naplózott adatok.
-- Minden felhasználói tábla soronkénti jogosultsággal (RLS) védett.

create schema if not exists extensions;

create extension if not exists pgcrypto with schema extensions;
create extension if not exists unaccent with schema extensions;
create extension if not exists pg_trgm with schema extensions;

-- Ékezet- és kisbetű-független normalizálás. Immutable, hogy indexben és
-- generált kolumnában is használható legyen.
create or replace function public.food_normalize(input text)
returns text
language sql
immutable
parallel safe
set search_path = extensions, public
as $$
  select lower(unaccent('unaccent'::regdictionary, coalesce(input, '')));
$$;

create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- Ételkatalógus
-- ---------------------------------------------------------------------------

create table if not exists public.foods (
  id uuid primary key default extensions.gen_random_uuid(),
  source text not null check (source in ('curated', 'off', 'user')),
  external_id text,
  barcode text,
  name text not null,
  brand text,
  quantity text,
  category text,
  lang text not null default 'hu',
  kcal numeric(9, 2) not null default 0,
  protein numeric(9, 2) not null default 0,
  fat numeric(9, 2) not null default 0,
  carbs numeric(9, 2) not null default 0,
  sugar numeric(9, 2),
  saturated_fat numeric(9, 2),
  salt numeric(9, 2),
  fiber numeric(9, 2),
  image_url text,
  popularity integer not null default 0,
  quality_score numeric(4, 2) not null default 0,
  verified boolean not null default false,
  owner_id uuid references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on column public.foods.owner_id is
  'NULL = publikus katalógustétel. Nem NULL = a felhasználó saját étele.';
comment on column public.foods.kcal is 'Tápanyagértékek 100 g vagy 100 ml-re.';

create unique index if not exists foods_barcode_key
  on public.foods (barcode)
  where barcode is not null;

create unique index if not exists foods_source_external_key
  on public.foods (source, external_id)
  where external_id is not null;

create index if not exists foods_name_trgm_idx
  on public.foods using gin (public.food_normalize(name) extensions.gin_trgm_ops);

create index if not exists foods_fts_idx
  on public.foods using gin (
    to_tsvector('hungarian', coalesce(name, '') || ' ' || coalesce(brand, ''))
  );

create index if not exists foods_owner_idx on public.foods (owner_id);
create index if not exists foods_popularity_idx on public.foods (popularity desc);

drop trigger if exists foods_touch_updated_at on public.foods;
create trigger foods_touch_updated_at
  before update on public.foods
  for each row execute function public.touch_updated_at();

create table if not exists public.food_aliases (
  id bigserial primary key,
  food_id uuid not null references public.foods (id) on delete cascade,
  alias text not null,
  normalized text generated always as (public.food_normalize(alias)) stored
);

create unique index if not exists food_aliases_unique
  on public.food_aliases (food_id, normalized);

create index if not exists food_aliases_trgm_idx
  on public.food_aliases using gin (normalized extensions.gin_trgm_ops);

create table if not exists public.food_servings (
  id bigserial primary key,
  food_id uuid not null references public.foods (id) on delete cascade,
  label text not null,
  grams numeric(9, 2) not null check (grams > 0),
  sort_order integer not null default 0
);

create unique index if not exists food_servings_unique
  on public.food_servings (food_id, label);

create index if not exists food_servings_food_idx on public.food_servings (food_id);

-- Találat nélküli vagy kattintás nélküli keresések: ebből derül ki, hova kell
-- új alias vagy új étel.
create table if not exists public.search_misses (
  id bigserial primary key,
  user_id uuid references auth.users (id) on delete set null,
  query text not null,
  normalized text not null,
  result_count integer not null default 0,
  created_at timestamptz not null default now()
);

create index if not exists search_misses_normalized_idx
  on public.search_misses (normalized);

-- ---------------------------------------------------------------------------
-- Profil és célok
-- ---------------------------------------------------------------------------

create table if not exists public.profiles (
  user_id uuid primary key references auth.users (id) on delete cascade,
  first_name text,
  gender text check (gender in ('male', 'female', 'other')),
  birth_date date,
  height_cm numeric(5, 1),
  weight_kg numeric(5, 1),
  activity_level text not null default 'moderate'
    check (activity_level in ('sedentary', 'light', 'moderate', 'active', 'very_active')),
  goal text check (goal in ('lose_weight', 'gain_muscle', 'keep_fit')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

drop trigger if exists profiles_touch_updated_at on public.profiles;
create trigger profiles_touch_updated_at
  before update on public.profiles
  for each row execute function public.touch_updated_at();

create table if not exists public.goals (
  user_id uuid primary key references auth.users (id) on delete cascade,
  calorie_goal numeric(9, 2),
  protein_goal numeric(9, 2),
  fat_goal numeric(9, 2),
  carbs_goal numeric(9, 2),
  water_goal_ml integer,
  is_manual boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists goals_touch_updated_at on public.goals;
create trigger goals_touch_updated_at
  before update on public.goals
  for each row execute function public.touch_updated_at();

-- ---------------------------------------------------------------------------
-- Étkezési napló
-- ---------------------------------------------------------------------------

create table if not exists public.diary_entries (
  -- A kliens állítja elő, így a feltöltés ismételhető (idempotens).
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  logged_at timestamptz not null,
  local_date date not null,
  meal_type text not null,
  food_id uuid references public.foods (id) on delete set null,
  food_name text not null,
  food_image text,
  amount_g numeric(9, 2) not null,
  serving_label text,
  -- Tápanyag-pillanatfelvétel a naplózott mennyiségre. Azért tároljuk, mert a
  -- katalógus adata később változhat, a múltbeli napló viszont nem változhat.
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

create index if not exists diary_entries_user_date_idx
  on public.diary_entries (user_id, local_date desc);

create index if not exists diary_entries_user_updated_idx
  on public.diary_entries (user_id, updated_at desc);

drop trigger if exists diary_entries_touch_updated_at on public.diary_entries;
create trigger diary_entries_touch_updated_at
  before update on public.diary_entries
  for each row execute function public.touch_updated_at();

-- Kedvencek: a keresőben külön fülként jelenik meg.
create table if not exists public.food_favorites (
  user_id uuid not null references auth.users (id) on delete cascade,
  food_id uuid not null references public.foods (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, food_id)
);

-- ---------------------------------------------------------------------------
-- Edzés és alvás (ugyanaz a szinkron-minta)
-- ---------------------------------------------------------------------------

create table if not exists public.workout_sessions (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  kind text not null default 'completed' check (kind in ('template', 'scheduled', 'completed')),
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

create index if not exists workout_sessions_user_idx
  on public.workout_sessions (user_id, kind, updated_at desc);

drop trigger if exists workout_sessions_touch_updated_at on public.workout_sessions;
create trigger workout_sessions_touch_updated_at
  before update on public.workout_sessions
  for each row execute function public.touch_updated_at();

create table if not exists public.workout_exercise_sets (
  id uuid primary key,
  session_id uuid not null references public.workout_sessions (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  exercise_name text not null,
  round_index integer not null default 0,
  reps integer,
  weight_kg numeric(7, 2),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index if not exists workout_sets_session_idx
  on public.workout_exercise_sets (session_id);

create table if not exists public.sleep_entries (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  bedtime timestamptz not null,
  wake_time timestamptz not null,
  quality integer check (quality between 1 and 5),
  note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index if not exists sleep_entries_user_idx
  on public.sleep_entries (user_id, bedtime desc);

drop trigger if exists sleep_entries_touch_updated_at on public.sleep_entries;
create trigger sleep_entries_touch_updated_at
  before update on public.sleep_entries
  for each row execute function public.touch_updated_at();

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.foods enable row level security;
alter table public.food_aliases enable row level security;
alter table public.food_servings enable row level security;
alter table public.food_favorites enable row level security;
alter table public.search_misses enable row level security;
alter table public.profiles enable row level security;
alter table public.goals enable row level security;
alter table public.diary_entries enable row level security;
alter table public.workout_sessions enable row level security;
alter table public.workout_exercise_sets enable row level security;
alter table public.sleep_entries enable row level security;

-- Katalógus: a publikus tételeket mindenki olvashatja, a sajátot csak a tulaj.
drop policy if exists foods_select on public.foods;
create policy foods_select on public.foods
  for select using (owner_id is null or owner_id = auth.uid());

drop policy if exists foods_insert_own on public.foods;
create policy foods_insert_own on public.foods
  for insert to authenticated
  with check (owner_id = auth.uid() and source = 'user');

drop policy if exists foods_update_own on public.foods;
create policy foods_update_own on public.foods
  for update to authenticated
  using (owner_id = auth.uid()) with check (owner_id = auth.uid());

drop policy if exists foods_delete_own on public.foods;
create policy foods_delete_own on public.foods
  for delete to authenticated using (owner_id = auth.uid());

drop policy if exists food_aliases_select on public.food_aliases;
create policy food_aliases_select on public.food_aliases
  for select using (
    exists (
      select 1 from public.foods f
      where f.id = food_id and (f.owner_id is null or f.owner_id = auth.uid())
    )
  );

drop policy if exists food_aliases_write_own on public.food_aliases;
create policy food_aliases_write_own on public.food_aliases
  for all to authenticated
  using (
    exists (select 1 from public.foods f where f.id = food_id and f.owner_id = auth.uid())
  )
  with check (
    exists (select 1 from public.foods f where f.id = food_id and f.owner_id = auth.uid())
  );

drop policy if exists food_servings_select on public.food_servings;
create policy food_servings_select on public.food_servings
  for select using (
    exists (
      select 1 from public.foods f
      where f.id = food_id and (f.owner_id is null or f.owner_id = auth.uid())
    )
  );

drop policy if exists food_servings_write_own on public.food_servings;
create policy food_servings_write_own on public.food_servings
  for all to authenticated
  using (
    exists (select 1 from public.foods f where f.id = food_id and f.owner_id = auth.uid())
  )
  with check (
    exists (select 1 from public.foods f where f.id = food_id and f.owner_id = auth.uid())
  );

drop policy if exists search_misses_insert on public.search_misses;
create policy search_misses_insert on public.search_misses
  for insert to authenticated
  with check (user_id is null or user_id = auth.uid());

-- Felhasználói táblák: mindenki csak a sajátját látja és írja.
do $$
declare
  target text;
begin
  foreach target in array array[
    'profiles', 'goals', 'diary_entries', 'food_favorites',
    'workout_sessions', 'workout_exercise_sets', 'sleep_entries'
  ]
  loop
    execute format('drop policy if exists %1$s_owner on public.%1$s', target);
    execute format(
      'create policy %1$s_owner on public.%1$s for all to authenticated '
      'using (user_id = auth.uid()) with check (user_id = auth.uid())',
      target
    );
  end loop;
end;
$$;

-- ---------------------------------------------------------------------------
-- Jogosultságok
-- ---------------------------------------------------------------------------

grant usage on schema public to anon, authenticated;
grant select on public.foods, public.food_aliases, public.food_servings to anon, authenticated;
grant insert, update, delete on public.foods to authenticated;
grant insert, update, delete on public.food_aliases, public.food_servings to authenticated;
grant usage, select on sequence public.food_aliases_id_seq to authenticated;
grant usage, select on sequence public.food_servings_id_seq to authenticated;
grant insert on public.search_misses to authenticated;
grant usage, select on sequence public.search_misses_id_seq to authenticated;
grant select, insert, update, delete on
  public.profiles, public.goals, public.diary_entries, public.food_favorites,
  public.workout_sessions, public.workout_exercise_sets, public.sleep_entries
  to authenticated;
