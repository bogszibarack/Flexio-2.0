-- Fiók életciklus: profil létrehozása regisztrációnál és teljes adattörlés.

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (user_id, first_name)
  values (new.id, nullif(btrim(coalesce(new.raw_user_meta_data ->> 'first_name', '')), ''))
  on conflict (user_id) do nothing;

  insert into public.goals (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- GDPR és App Store követelmény: a felhasználó saját maga törölheti a fiókját
-- és minden hozzá tartozó adatot.
create or replace function public.delete_account()
returns void
language plpgsql
security definer
set search_path = public, auth
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
  delete from public.goals where user_id = uid;
  delete from public.profiles where user_id = uid;
  delete from public.foods where owner_id = uid;
  update public.search_misses set user_id = null where user_id = uid;

  delete from auth.users where id = uid;
end;
$$;

grant execute on function public.delete_account() to authenticated;
