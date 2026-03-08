-- Run this in your Supabase SQL Editor
-- Stores each client's tool data, keyed by their access code

create table if not exists public.client_tool_data (
  code       text    not null,
  tool       text    not null,
  data       jsonb   not null default '{}',
  updated_at bigint  not null,
  primary key (code, tool)
);

alter table public.client_tool_data enable row level security;

-- Block all direct client access. API uses service role key which bypasses RLS.
create policy "block_direct_access"
  on public.client_tool_data
  for all
  using (false);
