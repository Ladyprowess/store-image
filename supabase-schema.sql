-- ============================================================
--  Prowess Digital Solutions — Tools Access System
--  Run this ONCE in your Supabase SQL Editor
-- ============================================================

create table if not exists public.client_codes (
  id           uuid primary key default gen_random_uuid(),
  code         text unique not null,
  name         text not null,
  phone        text,
  email        text,
  business     text,
  notes        text,
  type         text not null default '1year',   -- '1year' | 'forever'
  status       text not null default 'active',  -- 'active' | 'revoked'
  created_at   bigint not null,
  expires_at   bigint                            -- null = forever
);

create index if not exists idx_client_codes_code on public.client_codes (code);

alter table public.client_codes enable row level security;

-- Block all direct client access. API routes use the service role key which bypasses RLS.
create policy "No public access" on public.client_codes
  for all using (false);

-- Optional: readable view in your Supabase dashboard
create or replace view public.client_codes_view as
select
  code, name, business, phone, email, type, status,
  case
    when status = 'revoked' then 'revoked'
    when type = 'forever'   then 'forever'
    when expires_at is not null and expires_at < extract(epoch from now()) * 1000 then 'expired'
    else 'active'
  end as computed_status,
  to_timestamp(created_at / 1000) as created_date,
  to_timestamp(expires_at  / 1000) as expires_date,
  notes
from public.client_codes
order by created_at desc;
