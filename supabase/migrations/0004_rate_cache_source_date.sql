-- Preserve the source observation date separately from the time our server
-- refreshed the cached rate rows. Existing cache records remain valid but are
-- ignored until refreshed because source_date is null.
begin;

alter table public.rate_cache
  add column if not exists source_date date;

commit;
