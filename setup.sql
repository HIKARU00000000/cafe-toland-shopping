-- =====================================================
-- CAFE TOLAND 買い出しリスト Supabase セットアップ
-- Supabase の SQL Editor に貼り付けて実行してください
-- =====================================================

-- 商品テーブル
create table if not exists public.shopping_items (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  meta text,
  photo text,
  checked boolean not null default false,
  sort_order bigint not null default 0,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now()
);

create index if not exists shopping_items_sort_idx
  on public.shopping_items (sort_order, created_at);

-- 更新日時の自動セット
create or replace function public.set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists shopping_items_set_updated_at on public.shopping_items;
create trigger shopping_items_set_updated_at
  before update on public.shopping_items
  for each row execute function public.set_updated_at();

-- Row Level Security（匿名ユーザーに全操作許可：QR読める人は全員操作可）
alter table public.shopping_items enable row level security;

drop policy if exists "anon_full_access" on public.shopping_items;
create policy "anon_full_access"
  on public.shopping_items
  for all
  to anon
  using (true)
  with check (true);

-- Realtime 有効化（他端末での変更を即反映）
alter publication supabase_realtime add table public.shopping_items;

-- =====================================================
-- 追加の品物（一時アイテム）テーブル
-- 普段発注してるものが切れた時の買い出し用
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

-- =====================================================
-- Storage バケット（商品写真用）
-- 以下は Supabase ダッシュボードから手動で作成してください：
--   1. Storage → New bucket
--   2. Name: shopping-photos
--   3. Public bucket: ON（チェックを入れる）
--   4. Create
-- =====================================================

-- Storage への匿名アップロード/読み取り許可
drop policy if exists "anon_read_shopping_photos" on storage.objects;
create policy "anon_read_shopping_photos"
  on storage.objects for select
  to anon
  using (bucket_id = 'shopping-photos');

drop policy if exists "anon_insert_shopping_photos" on storage.objects;
create policy "anon_insert_shopping_photos"
  on storage.objects for insert
  to anon
  with check (bucket_id = 'shopping-photos');

drop policy if exists "anon_update_shopping_photos" on storage.objects;
create policy "anon_update_shopping_photos"
  on storage.objects for update
  to anon
  using (bucket_id = 'shopping-photos')
  with check (bucket_id = 'shopping-photos');

drop policy if exists "anon_delete_shopping_photos" on storage.objects;
create policy "anon_delete_shopping_photos"
  on storage.objects for delete
  to anon
  using (bucket_id = 'shopping-photos');
