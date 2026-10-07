-- =====================================================
-- 商品に個数（qty）列を追加
-- =====================================================

alter table public.shopping_items
  add column if not exists qty integer not null default 1;

-- 制約: 1以上
alter table public.shopping_items
  drop constraint if exists shopping_items_qty_check;
alter table public.shopping_items
  add constraint shopping_items_qty_check check (qty >= 1);
