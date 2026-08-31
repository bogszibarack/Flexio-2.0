-- A kereső RPC-k is a közös illesztési pontot használják, hogy a C# API
-- tranzakció-lokális felhasználói kontextusa ugyanúgy lássa a saját ételeket,
-- mint a telefon a JWT-n keresztül.

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

    select f.id, 45::real, 'fts'
    from public.foods f
    cross join params p
    where p.raw is not null
      and to_tsvector('hungarian', coalesce(f.name, '') || ' ' || coalesce(f.brand, ''))
          @@ websearch_to_tsquery('hungarian', p.raw)

    union all

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
  where f.owner_id is null or f.owner_id = (select public.flexio_current_user_id())
  order by score desc, f.popularity desc, f.name
  limit greatest(coalesce(max_results, 30), 1);
$$;

create or replace function public.food_by_barcode(code text)
returns setof public.foods
language sql
stable
set search_path = public
as $$
  select *
  from public.foods
  where barcode = btrim(code)
    and (owner_id is null or owner_id = (select public.flexio_current_user_id()))
  limit 1;
$$;

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
  values (
    (select public.flexio_current_user_id()),
    btrim(q),
    public.food_normalize(q),
    greatest(coalesce(result_count, 0), 0)
  );
end;
$$;
