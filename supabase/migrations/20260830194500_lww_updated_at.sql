-- LWW: ha a kliens / API explicit updated_at-et küld, a trigger ne írja felül.
-- Korábban minden UPDATE now()-ra cserélte, ami a telefon oldali
-- last-write-wins összehasonlítást elrontotta.

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

comment on function public.touch_updated_at() is
  'UPDATE-nél only then now(), ha a hívó nem adott új updated_at-et. Az API LWW-je így a kliens időbélyegét megtartja.';
