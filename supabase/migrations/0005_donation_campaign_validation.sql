-- Ensure donation campaign status/title are checked atomically at insertion.
begin;

create or replace function public.validate_donation_campaign()
returns trigger
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_title text;
  v_active boolean;
begin
  if new.campaign_id is null then
    if new.campaign not in ('Zakat Maal', 'Zakat Fitrah') then
      raise exception 'campaign_not_found' using errcode = 'P0001';
    end if;
    return new;
  end if;

  select title, active into v_title, v_active
  from public.campaigns
  where id = new.campaign_id
  for update;

  if not found then
    raise exception 'campaign_not_found' using errcode = 'P0001';
  end if;
  if not v_active then
    raise exception 'campaign_inactive' using errcode = 'P0001';
  end if;
  if v_title is distinct from new.campaign then
    raise exception 'campaign_title_mismatch' using errcode = 'P0001';
  end if;
  return new;
end;
$$;

revoke all on function public.validate_donation_campaign() from public, anon, authenticated;

drop trigger if exists donations_validate_campaign on public.donations;
create trigger donations_validate_campaign
before insert or update of campaign_id, campaign on public.donations
for each row execute function public.validate_donation_campaign();

commit;
