-- =====================================================
-- 作成したメモをホーム画面に残しておくためのテーブル
-- 常に1件のみ保持（新規作成時に既存を削除）
-- =====================================================

create table if not exists public.saved_memo (
  id uuid primary key default gen_random_uuid(),
  text text not null,
  created_at timestamp with time zone not null default now()
);

alter table public.saved_memo enable row level security;

drop policy if exists "anon_full_access_saved_memo" on public.saved_memo;
create policy "anon_full_access_saved_memo"
  on public.saved_memo
  for all
  to anon
  using (true)
  with check (true);

alter publication supabase_realtime add table public.saved_memo;
