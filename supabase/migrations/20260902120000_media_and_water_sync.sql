-- Profilkép URL, vízbevitel és haladásfotók szinkronizálása.

alter table public.profiles
  add column if not exists avatar_url text,
  add column if not exists avatar_updated_at timestamptz;

create table if not exists public.water_entries (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  logged_at timestamptz not null,
  local_date date not null,
  ml integer not null check (ml > 0),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index if not exists water_entries_user_day_idx
  on public.water_entries (user_id, local_date);

create table if not exists public.progress_photos (
  id uuid primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  taken_at timestamptz not null,
  pose text not null check (pose in ('front', 'back', 'left', 'right')),
  storage_path text not null,
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index if not exists progress_photos_user_taken_idx
  on public.progress_photos (user_id, taken_at desc);

-- RLS
alter table public.water_entries enable row level security;
alter table public.progress_photos enable row level security;

do $$
declare
  target text;
begin
  foreach target in array array['water_entries', 'progress_photos']
  loop
    execute format(
      'drop policy if exists %I on public.%I',
      target || '_owner_all',
      target
    );
    execute format(
      'create policy %I on public.%I for all using (user_id = auth.uid()) with check (user_id = auth.uid())',
      target || '_owner_all',
      target
    );
  end loop;
end $$;

grant select, insert, update, delete on public.water_entries to authenticated;
grant select, insert, update, delete on public.progress_photos to authenticated;

-- Storage
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values
  ('avatars', 'avatars', true, 5242880, array['image/jpeg', 'image/png', 'image/webp']),
  ('progress-photos', 'progress-photos', false, 10485760, array['image/jpeg', 'image/png', 'image/webp'])
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists avatars_public_read on storage.objects;
create policy avatars_public_read
  on storage.objects for select
  using (bucket_id = 'avatars');

drop policy if exists avatars_owner_write on storage.objects;
create policy avatars_owner_write
  on storage.objects for insert
  with check (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists avatars_owner_update on storage.objects;
create policy avatars_owner_update
  on storage.objects for update
  using (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists avatars_owner_delete on storage.objects;
create policy avatars_owner_delete
  on storage.objects for delete
  using (
    bucket_id = 'avatars'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists progress_photos_owner_read on storage.objects;
create policy progress_photos_owner_read
  on storage.objects for select
  using (
    bucket_id = 'progress-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists progress_photos_owner_write on storage.objects;
create policy progress_photos_owner_write
  on storage.objects for insert
  with check (
    bucket_id = 'progress-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists progress_photos_owner_update on storage.objects;
create policy progress_photos_owner_update
  on storage.objects for update
  using (
    bucket_id = 'progress-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

drop policy if exists progress_photos_owner_delete on storage.objects;
create policy progress_photos_owner_delete
  on storage.objects for delete
  using (
    bucket_id = 'progress-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

-- Fióktörlés bővítése
create or replace function public.delete_account()
returns void
language plpgsql
security definer
set search_path = public, auth, storage
as $$
declare
  uid uuid := auth.uid();
begin
  if uid is null then
    raise exception 'Bejelentkezés szükséges';
  end if;

  delete from public.diary_entries where user_id = uid;
  delete from public.food_favorites where user_id = uid;
  delete from public.workout_exercise_sets where user_id = uid;
  delete from public.workout_sessions where user_id = uid;
  delete from public.sleep_entries where user_id = uid;
  delete from public.water_entries where user_id = uid;
  delete from public.progress_photos where user_id = uid;
  delete from public.goals where user_id = uid;
  delete from public.profiles where user_id = uid;
  delete from public.foods where owner_id = uid;
  update public.search_misses set user_id = null where user_id = uid;

  delete from storage.objects
  where bucket_id in ('avatars', 'progress-photos')
    and (storage.foldername(name))[1] = uid::text;

  delete from auth.users where id = uid;
end;
$$;
