-- =====================================================
-- 「追加の品物」機能用テーブル追加
-- 既存の Supabase プロジェクトの SQL Editor で実行してください
-- =====================================================

create table if not exists public.memo_extras (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamp with time zone not null default now()
);

create index if not exists memo_extras_created_idx
  on public.memo_extras (created_at);

alter table public.memo_extras enable row level security;

drop policy if exists "anon_full_access_memo_extras" on public.memo_extras;
create policy "anon_full_access_memo_extras"
  on public.memo_extras
  for all
  to anon
  using (true)
  with check (true);

alter publication supabase_realtime add table public.memo_extras;
