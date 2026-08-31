-- Coach hívások költség- és kvótanaplója.
-- Nincs pillanatkép, nincs e-mail: csak azonosító, típus, modell, státusz, késleltetés.

create table if not exists public.coach_usage (
  id bigserial primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  kind text not null,
  model text,
  status text not null,
  latency_ms integer,
  created_at timestamptz not null default now()
);

create index if not exists coach_usage_user_created_idx
  on public.coach_usage (user_id, created_at desc);

create index if not exists coach_usage_created_idx
  on public.coach_usage (created_at desc);

alter table public.coach_usage enable row level security;

drop policy if exists coach_usage_owner on public.coach_usage;
create policy coach_usage_owner on public.coach_usage
  for all to authenticated
  using (user_id = (select public.flexio_current_user_id()))
  with check (user_id = (select public.flexio_current_user_id()));

grant select, insert on public.coach_usage to authenticated;
grant usage, select on sequence public.coach_usage_id_seq to authenticated;
