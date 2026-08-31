-- A saját (C#) API adatbázis-kontextusa.
--
-- Két kliens írja ugyanezt az adatbázist:
--   * a telefon a Supabase-en keresztül, ahol auth.uid() adja a felhasználót,
--   * a saját API egy külön role-lal, ami tranzakció-lokális beállításban közli,
--     kinek a nevében dolgozik.
--
-- Ez a migráció egyetlen illesztési pontot vezet be, hogy mindkét út ugyanazokon
-- a policy-kon menjen át, és a későbbi kibocsátó-csere egy függvényt érintsen.

-- ---------------------------------------------------------------------------
-- Illesztési pont
-- ---------------------------------------------------------------------------

create or replace function public.flexio_current_user_id()
returns uuid
language plpgsql
stable
as $$
declare
  configured text;
begin
  -- A beállítás előbb jön, mint az auth.uid(): így a saját API role-nak nem
  -- kell az auth sémához nyúlnia, és az SQL-inlining sem értékelheti ki a
  -- második ágat jogosultság-hiba mellett.
  configured := nullif(current_setting('app.current_user_id', true), '');
  if configured is not null then
    return configured::uuid;
  end if;

  return auth.uid();
end;
$$;

comment on function public.flexio_current_user_id() is
  'A kérést indító felhasználó: a saját API tranzakció-lokális beállítása, vagy a Supabase JWT-je. Ha egyik sincs, null - ilyenkor a policy-k nem engednek.';

grant execute on function public.flexio_current_user_id() to anon, authenticated;

-- ---------------------------------------------------------------------------
-- Role-ok
-- ---------------------------------------------------------------------------
-- A jelszót szándékosan nem a migráció állítja be: a titok a Render
-- környezetében él. Egyszeri lépés a projekt SQL konzoljában:
--   alter role flexio_api  password '...';
--   alter role flexio_jobs password '...';

do $$
begin
  -- A kérés-útvonal role-ja: RLS alatt fut, ez a védelem-mélység alapja.
  if not exists (select 1 from pg_roles where rolname = 'flexio_api') then
    create role flexio_api login nobypassrls;
  end if;

  -- A kötegelt katalógusírás role-ja (Open Food Facts import, seed). Csak a
  -- katalógustáblákhoz kap jogot, felhasználói naplóhoz soha.
  if not exists (select 1 from pg_roles where rolname = 'flexio_jobs') then
    create role flexio_jobs login nobypassrls;
  end if;
end;
$$;

-- A flexio_api az authenticated tagja lesz: így a meglévő "to authenticated"
-- policy-k és tábla-jogok érvényesek rá, külön policy-készlet nélkül.
grant authenticated to flexio_api;

grant usage on schema public to flexio_jobs;
grant select, insert, update, delete on
  public.foods, public.food_aliases, public.food_servings
  to flexio_jobs;
grant usage, select on sequence public.food_aliases_id_seq to flexio_jobs;
grant usage, select on sequence public.food_servings_id_seq to flexio_jobs;
grant select, update, delete on public.search_misses to flexio_jobs;
grant execute on function public.food_normalize(text) to flexio_jobs;

-- ---------------------------------------------------------------------------
-- Policy-k átállítása az illesztési pontra
-- ---------------------------------------------------------------------------
-- A (select ...) burkolás nem stílus: így a kifejezés InitPlan-ként egyszer
-- értékelődik ki, nem soronként.

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

drop policy if exists foods_update_own on public.foods;
create policy foods_update_own on public.foods
  for update to authenticated
  using (owner_id = (select public.flexio_current_user_id()))
  with check (owner_id = (select public.flexio_current_user_id()));

drop policy if exists foods_delete_own on public.foods;
create policy foods_delete_own on public.foods
  for delete to authenticated
  using (owner_id = (select public.flexio_current_user_id()));

drop policy if exists food_aliases_select on public.food_aliases;
create policy food_aliases_select on public.food_aliases
  for select using (
    exists (
      select 1 from public.foods f
      where f.id = food_id
        and (f.owner_id is null or f.owner_id = (select public.flexio_current_user_id()))
    )
  );

drop policy if exists food_aliases_write_own on public.food_aliases;
create policy food_aliases_write_own on public.food_aliases
  for all to authenticated
  using (
    exists (
      select 1 from public.foods f
      where f.id = food_id and f.owner_id = (select public.flexio_current_user_id())
    )
  )
  with check (
    exists (
      select 1 from public.foods f
      where f.id = food_id and f.owner_id = (select public.flexio_current_user_id())
    )
  );

drop policy if exists food_servings_select on public.food_servings;
create policy food_servings_select on public.food_servings
  for select using (
    exists (
      select 1 from public.foods f
      where f.id = food_id
        and (f.owner_id is null or f.owner_id = (select public.flexio_current_user_id()))
    )
  );

drop policy if exists food_servings_write_own on public.food_servings;
create policy food_servings_write_own on public.food_servings
  for all to authenticated
  using (
    exists (
      select 1 from public.foods f
      where f.id = food_id and f.owner_id = (select public.flexio_current_user_id())
    )
  )
  with check (
    exists (
      select 1 from public.foods f
      where f.id = food_id and f.owner_id = (select public.flexio_current_user_id())
    )
  );

drop policy if exists search_misses_insert on public.search_misses;
create policy search_misses_insert on public.search_misses
  for insert to authenticated
  with check (
    user_id is null or user_id = (select public.flexio_current_user_id())
  );

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
      'using (user_id = (select public.flexio_current_user_id())) '
      'with check (user_id = (select public.flexio_current_user_id()))',
      target
    );
  end loop;
end;
$$;

-- ---------------------------------------------------------------------------
-- A kötegelt munkák policy-i
-- ---------------------------------------------------------------------------
-- Az import kurátorolt és OFF sorokat ír, amiknek nincs tulajdonosuk, ezért a
-- felhasználói policy nem engedheti át. BYPASSRLS helyett szűk, nevesített
-- policy: így pontosan látszik, mihez van joga.

drop policy if exists foods_jobs_all on public.foods;
create policy foods_jobs_all on public.foods
  for all to flexio_jobs using (true) with check (true);

drop policy if exists food_aliases_jobs_all on public.food_aliases;
create policy food_aliases_jobs_all on public.food_aliases
  for all to flexio_jobs using (true) with check (true);

drop policy if exists food_servings_jobs_all on public.food_servings;
create policy food_servings_jobs_all on public.food_servings
  for all to flexio_jobs using (true) with check (true);

-- A kereséstelenségi napló összesítéséhez olvasás és takarítás kell.
drop policy if exists search_misses_jobs_read on public.search_misses;
create policy search_misses_jobs_read on public.search_misses
  for select to flexio_jobs using (true);

drop policy if exists search_misses_jobs_cleanup on public.search_misses;
create policy search_misses_jobs_cleanup on public.search_misses
  for delete to flexio_jobs using (true);
