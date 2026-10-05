-- =====================================================
-- 店舗（カテゴリ）機能用テーブル追加
-- =====================================================

create table if not exists public.stores (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  sort_order bigint not null default 0,
  created_at timestamp with time zone not null default now()
);

create index if not exists stores_sort_idx on public.stores (sort_order, created_at);

alter table public.stores enable row level security;

drop policy if exists "anon_full_access_stores" on public.stores;
create policy "anon_full_access_stores"
  on public.stores
  for all
  to anon
  using (true)
  with check (true);

alter publication supabase_realtime add table public.stores;

-- shopping_items に店舗参照カラムを追加
alter table public.shopping_items
  add column if not exists store_id uuid references public.stores(id) on delete set null;

create index if not exists shopping_items_store_idx
  on public.shopping_items (store_id);
