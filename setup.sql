-- Our Card — run this once in the Supabase SQL editor (paste all of it, click Run).
--
-- Security model: the table is sealed off from the browser entirely.
-- All access goes through the functions below, and every one of them
-- requires knowing the exact ledger ID — which is derived from your
-- password. Nothing can be listed, browsed, or enumerated.

create table if not exists public.ledgers (
  id text primary key,
  data jsonb not null,
  version bigint not null default 1,
  updated_at timestamptz not null default now()
);

-- Seal the table: no direct access from the anon (browser) role.
alter table public.ledgers enable row level security;
revoke all on table public.ledgers from anon, authenticated;

-- Read a ledger (returns null if the ID doesn't exist).
create or replace function public.get_ledger(p_id text)
returns json
language sql
security definer
set search_path = public
as $$
  select json_build_object('data', data, 'version', version)
  from public.ledgers
  where id = p_id;
$$;

-- Create a ledger; returns false if that ID is already taken.
create or replace function public.create_ledger(p_id text, p_data jsonb)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.ledgers (id, data) values (p_id, p_data);
  return true;
exception when unique_violation then
  return false;
end;
$$;

-- Save, but only if nobody else saved first (optimistic concurrency).
create or replace function public.put_ledger(p_id text, p_data jsonb, p_version bigint)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.ledgers
     set data = p_data,
         version = version + 1,
         updated_at = now()
   where id = p_id
     and version = p_version;
  return found;
end;
$$;

-- Move a ledger to a new ID (password change). Atomic.
create or replace function public.move_ledger(p_old text, p_new text)
returns text
language plpgsql
security definer
set search_path = public
as $$
begin
  if exists (select 1 from public.ledgers where id = p_new) then
    return 'exists';
  end if;
  update public.ledgers set id = p_new, updated_at = now() where id = p_old;
  if found then
    return 'moved';
  else
    return 'missing';
  end if;
end;
$$;

-- Let the browser call the functions (and nothing else).
grant execute on function public.get_ledger(text) to anon;
grant execute on function public.create_ledger(text, jsonb) to anon;
grant execute on function public.put_ledger(text, jsonb, bigint) to anon;
grant execute on function public.move_ledger(text, text) to anon;
