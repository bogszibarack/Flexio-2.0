-- Ételkeresés: normalizálás, prefix, magyar szótövezés, trigram elírás-tűrés,
-- majd forrás és népszerűség szerinti rangsor.

create or replace function public.search_foods(
  q text,
  max_results integer default 30
)
returns table (
  id uuid,
  source text,
  barcode text,
  name text,
  brand text,
  category text,
  kcal numeric,
  protein numeric,
  fat numeric,
  carbs numeric,
  sugar numeric,
  saturated_fat numeric,
  salt numeric,
  fiber numeric,
  image_url text,
  popularity integer,
  quality_score numeric,
  owner_id uuid,
  score real,
  match_kind text
)
language sql
stable
set search_path = public, extensions
as $$
  with params as (
    select public.food_normalize(q) as nq,
           nullif(btrim(coalesce(q, '')), '') as raw
  ),
  matches as (
    -- 1. pontos, prefix vagy részleges egyezés a névre
    select f.id as food_id,
           (case
              when public.food_normalize(f.name) = p.nq then 100
              when public.food_normalize(f.name) like p.nq || '%' then 80
              else 60
            end)::real as base,
           'name'::text as kind
    from public.foods f
    cross join params p
    where p.nq <> ''
      and public.food_normalize(f.name) like '%' || p.nq || '%'

    union all

    -- 2. alias egyezés (szinonimák, ékezet nélküli és angol írásmód)
    select a.food_id,
           (case
              when a.normalized = p.nq then 90
              when a.normalized like p.nq || '%' then 70
              else 55
            end)::real,
           'alias'
    from public.food_aliases a
    cross join params p
    where p.nq <> ''
      and a.normalized like '%' || p.nq || '%'

    union all

    -- 3. szavas keresés magyar szótövezéssel ("csirkemellet" is találjon)
    select f.id, 45::real, 'fts'
    from public.foods f
    cross join params p
    where p.raw is not null
      and to_tsvector('hungarian', coalesce(f.name, '') || ' ' || coalesce(f.brand, ''))
          @@ websearch_to_tsquery('hungarian', p.raw)

    union all

    -- 4. trigram hasonlóság elírásra ("turo rudi", "csirimell")
    select f.id,
           (20 + 25 * similarity(public.food_normalize(f.name), p.nq))::real,
           'fuzzy'
    from public.foods f
    cross join params p
    where p.nq <> ''
      and public.food_normalize(f.name) % p.nq
  ),
  best as (
    select food_id,
           max(base) as base,
           (array_agg(kind order by base desc))[1] as kind
    from matches
    group by food_id
  )
  select f.id,
         f.source,
         f.barcode,
         f.name,
         f.brand,
         f.category,
         f.kcal,
         f.protein,
         f.fat,
         f.carbs,
         f.sugar,
         f.saturated_fat,
         f.salt,
         f.fiber,
         f.image_url,
         f.popularity,
         f.quality_score,
         f.owner_id,
         (b.base
           + case f.source when 'curated' then 12 when 'user' then 8 else 0 end
           + least(f.popularity, 100) * 0.15
           + coalesce(f.quality_score, 0) * 2
           + case when f.lang = 'hu' then 3 else 0 end)::real as score,
         b.kind
  from best b
  join public.foods f on f.id = b.food_id
  where f.owner_id is null or f.owner_id = auth.uid()
  order by score desc, f.popularity desc, f.name
  limit greatest(coalesce(max_results, 30), 1);
$$;

comment on function public.search_foods(text, integer) is
  'Rétegzett ételkeresés: név, alias, magyar szótövezés, majd trigram elírás-tűrés.';

-- Vonalkód feloldása. Külön függvény, mert a barcode egyezés mindig pontos.
create or replace function public.food_by_barcode(code text)
returns setof public.foods
language sql
stable
set search_path = public
as $$
  select *
  from public.foods
  where barcode = btrim(code)
    and (owner_id is null or owner_id = auth.uid())
  limit 1;
$$;

-- A találat nélküli keresések naplózása. Definer, hogy a tábla írása
-- kontrollált maradjon.
create or replace function public.log_search_miss(q text, result_count integer default 0)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if nullif(btrim(coalesce(q, '')), '') is null then
    return;
  end if;

  insert into public.search_misses (user_id, query, normalized, result_count)
  values (auth.uid(), btrim(q), public.food_normalize(q), greatest(coalesce(result_count, 0), 0));
end;
$$;

-- Naplózásnál növeljük a népszerűséget: ez rangsorolja a keresést.
create or replace function public.increment_food_popularity(target uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if target is null then
    return;
  end if;

  update public.foods
  set popularity = popularity + 1
  where id = target;
end;
$$;

-- Az Open Food Facts API-ból élőben behozott termék beírása a publikus
-- katalógusba (cache-on-write). Csak bejelentkezett felhasználó hívhatja.
create or replace function public.upsert_off_food(
  p_barcode text,
  p_name text,
  p_brand text default null,
  p_quantity text default null,
  p_image_url text default null,
  p_kcal numeric default 0,
  p_protein numeric default 0,
  p_fat numeric default 0,
  p_carbs numeric default 0,
  p_sugar numeric default null,
  p_saturated_fat numeric default null,
  p_salt numeric default null,
  p_fiber numeric default null,
  p_servings jsonb default '[]'::jsonb
)
returns public.foods
language plpgsql
security definer
set search_path = public
as $$
declare
  result public.foods;
  quality numeric;
  serving jsonb;
begin
  if auth.uid() is null then
    raise exception 'Bejelentkezés szükséges';
  end if;

  if nullif(btrim(coalesce(p_barcode, '')), '') is null
     or nullif(btrim(coalesce(p_name, '')), '') is null then
    raise exception 'Hiányzó vonalkód vagy név';
  end if;

  quality := 0.4
    + case when coalesce(p_kcal, 0) > 0 then 0.2 else 0 end
    + case when coalesce(p_protein, 0) + coalesce(p_fat, 0) + coalesce(p_carbs, 0) > 0 then 0.2 else 0 end
    + case when p_fiber is not null or p_salt is not null then 0.2 else 0 end;

  insert into public.foods as f (
    source, external_id, barcode, name, brand, quantity, lang,
    kcal, protein, fat, carbs, sugar, saturated_fat, salt, fiber,
    image_url, quality_score
  )
  values (
    'off', btrim(p_barcode), btrim(p_barcode), btrim(p_name), p_brand, p_quantity, 'hu',
    coalesce(p_kcal, 0), coalesce(p_protein, 0), coalesce(p_fat, 0), coalesce(p_carbs, 0),
    p_sugar, p_saturated_fat, p_salt, p_fiber, p_image_url, quality
  )
  on conflict (barcode) do update
    set name = excluded.name,
        brand = coalesce(excluded.brand, f.brand),
        quantity = coalesce(excluded.quantity, f.quantity),
        kcal = excluded.kcal,
        protein = excluded.protein,
        fat = excluded.fat,
        carbs = excluded.carbs,
        sugar = coalesce(excluded.sugar, f.sugar),
        saturated_fat = coalesce(excluded.saturated_fat, f.saturated_fat),
        salt = coalesce(excluded.salt, f.salt),
        fiber = coalesce(excluded.fiber, f.fiber),
        image_url = coalesce(excluded.image_url, f.image_url),
        quality_score = greatest(f.quality_score, excluded.quality_score)
  returning * into result;

  for serving in select * from jsonb_array_elements(coalesce(p_servings, '[]'::jsonb))
  loop
    insert into public.food_servings (food_id, label, grams)
    values (result.id, serving ->> 'label', (serving ->> 'grams')::numeric)
    on conflict (food_id, label) do nothing;
  end loop;

  return result;
end;
$$;

grant execute on function public.search_foods(text, integer) to anon, authenticated;
grant execute on function public.food_by_barcode(text) to anon, authenticated;
grant execute on function public.log_search_miss(text, integer) to authenticated;
grant execute on function public.increment_food_popularity(uuid) to authenticated;
grant execute on function public.upsert_off_food(
  text, text, text, text, text, numeric, numeric, numeric, numeric,
  numeric, numeric, numeric, numeric, jsonb
) to authenticated;
