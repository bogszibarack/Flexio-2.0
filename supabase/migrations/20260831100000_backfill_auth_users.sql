-- Meglévő auth.users sorokhoz profil és cél rekord, ha a trigger előtt regisztráltak.

insert into public.profiles (user_id, first_name)
select
  u.id,
  nullif(btrim(coalesce(u.raw_user_meta_data ->> 'first_name', '')), '')
from auth.users u
on conflict (user_id) do nothing;

insert into public.goals (user_id)
select u.id
from auth.users u
on conflict (user_id) do nothing;
