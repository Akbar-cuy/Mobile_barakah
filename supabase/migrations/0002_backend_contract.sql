-- Barakah backend contracts and atomic operations (PRD v2.0).
begin;

create extension if not exists pgcrypto;

do $$
begin
  if exists (
    select lower(email)
    from public.users
    group by lower(email)
    having count(*) > 1
  ) then
    raise exception 'Resolve duplicate case-insensitive user emails before applying migration 0002.';
  end if;
  if exists (
    select lower(username)
    from public.users
    group by lower(username)
    having count(*) > 1
  ) then
    raise exception 'Resolve duplicate case-insensitive usernames before applying migration 0002.';
  end if;
end;
$$;

create unique index if not exists users_email_lower_uq
  on public.users (lower(email));
create unique index if not exists users_username_lower_uq
  on public.users (lower(username));
create unique index if not exists sessions_refresh_hash_uq
  on public.sessions (refresh_hash);
create unique index if not exists iot_devices_key_hash_uq
  on public.iot_devices (key_hash);

alter table public.tasbih_logs
  add column if not exists updated_at timestamptz not null default now();
create index if not exists tasbih_logs_user_updated_idx
  on public.tasbih_logs (user_id, updated_at);

alter table public.donations
  add column if not exists block_hash text;

create table if not exists public.user_settings (
  user_id uuid not null references public.users(id) on delete cascade,
  setting_key text not null,
  setting_value text not null,
  updated_at timestamptz not null default now(),
  primary key (user_id, setting_key)
);
create index if not exists user_settings_user_updated_idx
  on public.user_settings (user_id, updated_at);

alter table public.user_settings enable row level security;

-- Custom Barakah JWTs are validated by Edge Functions. No direct PostgREST
-- access is granted to app roles; Edge Functions use the service role only.
revoke all on public.users, public.sessions, public.device_tokens,
  public.campaigns, public.donations, public.ledger_blocks,
  public.ledger_heads, public.zakat_calcs, public.tasbih_logs,
  public.quiz_questions, public.quiz_attempts, public.game_scores,
  public.chat_messages, public.feedback, public.favorite_mosques,
  public.rate_cache, public.iot_devices, public.user_settings
  from anon, authenticated;

create or replace function public.record_failed_login(
  p_user_id uuid,
  p_max_attempts integer,
  p_lock_minutes integer
) returns boolean
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_locked_until timestamptz;
begin
  select locked_until into v_locked_until
  from public.users
  where id = p_user_id
  for update;

  if not found then
    return false;
  end if;
  if v_locked_until is not null and v_locked_until > now() then
    return true;
  end if;

  update public.users
  set failed_attempts = case
        when failed_attempts + 1 >= p_max_attempts then 0
        else failed_attempts + 1
      end,
      locked_until = case
        when failed_attempts + 1 >= p_max_attempts
          then now() + make_interval(mins => p_lock_minutes)
        else null
      end
  where id = p_user_id
  returning locked_until into v_locked_until;

  return v_locked_until is not null and v_locked_until > now();
end;
$$;

create or replace function public.change_password_and_revoke_sessions(
  p_user_id uuid,
  p_current_session_id uuid,
  p_current_device_id text,
  p_expected_password_hash text,
  p_password_hash text
) returns void
language plpgsql
security definer
set search_path = public, pg_temp
as $$
begin
  update public.users
  set password_hash = p_password_hash,
      failed_attempts = 0,
      locked_until = null
  where id = p_user_id
    and password_hash = p_expected_password_hash;
  if not found then
    raise exception 'password_changed' using errcode = 'P0001';
  end if;

  update public.sessions
  set revoked_at = now()
  where user_id = p_user_id
    and id <> p_current_session_id
    and revoked_at is null;

  update public.device_tokens
  set revoked_at = now()
  where user_id = p_user_id
    and device_id <> p_current_device_id
    and revoked_at is null;
end;
$$;

create or replace function public.sync_push(
  p_user_id uuid,
  p_changes jsonb
) returns jsonb
language plpgsql
security definer
set search_path = public, pg_temp
as $$
declare
  v_change jsonb;
  v_payload jsonb;
  v_entity text;
  v_op text;
  v_id uuid;
  v_key text;
  v_value text;
  v_updated_at timestamptz;
  v_processed integer := 0;
  v_rows integer;
begin
  if p_user_id is null
    or p_changes is null
    or jsonb_typeof(p_changes) is distinct from 'array' then
    raise exception 'invalid_sync_batch' using errcode = 'P0001';
  end if;
  if jsonb_array_length(p_changes) > 200 then
    raise exception 'invalid_sync_batch' using errcode = 'P0001';
  end if;

  for v_change in select value from jsonb_array_elements(p_changes)
  loop
    if jsonb_typeof(v_change) <> 'object'
      or jsonb_typeof(v_change->'payload') <> 'object' then
      raise exception 'invalid_sync_change' using errcode = 'P0001';
    end if;
    v_entity := v_change->>'entity';
    v_op := v_change->>'op';
    v_payload := v_change->'payload';

    if v_entity = 'tasbih_log' then
      if v_op not in ('create', 'update', 'delete')
        or (v_payload->>'id') !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$' then
        raise exception 'invalid_tasbih_change' using errcode = 'P0001';
      end if;
      v_id := (v_payload->>'id')::uuid;

      if v_op = 'delete' then
        delete from public.tasbih_logs
        where id = v_id and user_id = p_user_id;
      else
        if (v_payload->>'log_date') !~ '^\d{4}-\d{2}-\d{2}$'
          or coalesce((v_payload->>'target')::integer, 0) <= 0
          or coalesce((v_payload->>'count')::integer, -1) < 0
          or v_payload->>'source' not in ('app', 'iot') then
          raise exception 'invalid_tasbih_change' using errcode = 'P0001';
        end if;

        insert into public.tasbih_logs (
          id, user_id, log_date, target, count, source, updated_at
        ) values (
          v_id, p_user_id, (v_payload->>'log_date')::date,
          (v_payload->>'target')::integer, (v_payload->>'count')::integer,
          v_payload->>'source', now()
        )
        on conflict (id) do update
          set log_date = excluded.log_date,
              target = excluded.target,
              count = excluded.count,
              source = excluded.source,
              updated_at = excluded.updated_at
          where public.tasbih_logs.user_id = excluded.user_id;
        get diagnostics v_rows = row_count;
        if v_rows = 0 then
          raise exception 'sync_id_conflict' using errcode = 'P0001';
        end if;
      end if;
    elsif v_entity = 'setting' then
      v_key := v_payload->>'key';
      if v_key not in (
        'theme_mode', 'notification_prefs', 'tasbih_mode',
        'tasbih_sensitivity', 'tasbih_vibrate', 'tasbih_target'
      ) then
        raise exception 'invalid_setting_key' using errcode = 'P0001';
      end if;

      if v_op = 'delete' then
        delete from public.user_settings
        where user_id = p_user_id and setting_key = v_key;
      elsif v_op = 'update' then
        v_value := v_payload->>'value';
        v_updated_at := (v_payload->>'updated_at')::timestamptz;
        if v_value is null or length(v_value) > 10000 then
          raise exception 'invalid_setting_value' using errcode = 'P0001';
        end if;
        insert into public.user_settings (
          user_id, setting_key, setting_value, updated_at
        ) values (
          p_user_id, v_key, v_value, v_updated_at
        )
        on conflict (user_id, setting_key) do update
          set setting_value = excluded.setting_value,
              updated_at = excluded.updated_at
          where public.user_settings.updated_at <= excluded.updated_at;
      else
        raise exception 'invalid_setting_operation' using errcode = 'P0001';
      end if;
    else
      raise exception 'unsupported_sync_entity' using errcode = 'P0001';
    end if;
    v_processed := v_processed + 1;
  end loop;

  return jsonb_build_object('ok', true, 'processed', v_processed);
end;
$$;

create or replace function public.apply_donation(
  p_user_id uuid,
  p_donation jsonb
) returns jsonb
language plpgsql
security definer
set search_path = public, extensions, pg_temp
as $$
declare
  v_id uuid;
  v_existing_user uuid;
  v_existing_hash text;
  v_head_idx integer;
  v_head_hash text;
  v_block jsonb;
  v_genesis jsonb;
  v_idx integer;
  v_nonce bigint;
  v_hash text;
  v_expected_hash text;
  v_prefix text;
  v_expected_prev text;
  v_amount text;
  v_amount_idr text;
  v_rate text;
  v_campaign_id uuid;
  v_created_at timestamptz;
begin
  v_id := (p_donation->>'id')::uuid;
  v_block := p_donation->'block';
  v_genesis := p_donation->'genesis';

  if v_block is null or jsonb_typeof(v_block) <> 'object' then
    raise exception 'invalid_block' using errcode = 'P0001';
  end if;
  if p_donation->>'created_at' is null then
    raise exception 'invalid_created_at' using errcode = 'P0001';
  end if;
  v_created_at := (p_donation->>'created_at')::timestamptz;

  perform pg_advisory_xact_lock(hashtextextended(p_user_id::text, 0));
  perform pg_advisory_xact_lock(hashtextextended(v_id::text, 1));

  select user_id, block_hash into v_existing_user, v_existing_hash
  from public.donations where id = v_id;
  if found then
    if v_existing_user <> p_user_id
      or v_existing_hash is distinct from v_block->>'hash' then
      raise exception 'donation_id_conflict' using errcode = 'P0001';
    end if;
    return jsonb_build_object('ok', true, 'duplicate', true);
  end if;

  select head_idx, head_hash into v_head_idx, v_head_hash
  from public.ledger_heads where user_id = p_user_id;

  if v_head_idx is null then
    if v_genesis is null then
      raise exception 'missing_genesis' using errcode = 'P0001';
    end if;
    v_expected_prev := repeat('0', 64);
    v_idx := 0;
    if v_genesis->>'donor_alias' <> 'Genesis'
      or v_genesis->>'campaign' <> 'genesis'
      or v_genesis->>'amount' <> '0'
      or v_genesis->>'currency' <> 'IDR'
      or v_genesis->>'amount_idr' <> '0'
      or v_genesis->>'rate_used' <> '1' then
      raise exception 'invalid_genesis' using errcode = 'P0001';
    end if;

    v_prefix := concat_ws('|',
      v_idx::text,
      v_genesis->>'ts',
      p_user_id::text,
      v_genesis->>'donor_alias',
      v_genesis->>'campaign',
      v_genesis->>'amount',
      v_genesis->>'currency',
      v_genesis->>'amount_idr',
      v_genesis->>'rate_used',
      v_expected_prev
    ) || '|';
    v_nonce := (v_genesis->>'nonce')::bigint;
    v_expected_hash := encode(
      digest(convert_to(v_prefix || v_nonce::text, 'UTF8'), 'sha256'),
      'hex'
    );
    if (v_genesis->>'idx')::integer <> v_idx
      or v_genesis->>'prev_hash' <> v_expected_prev
      or v_genesis->>'hash' <> v_expected_hash
      or left(v_expected_hash, 3) <> '000' then
      raise exception 'invalid_genesis' using errcode = 'P0001';
    end if;

    insert into public.ledger_blocks (
      idx, user_id, ts, donor_alias, campaign, amount, currency,
      amount_idr, rate_used, prev_hash, nonce, hash
    ) values (
      v_idx, p_user_id, v_genesis->>'ts', v_genesis->>'donor_alias',
      v_genesis->>'campaign', v_genesis->>'amount', v_genesis->>'currency',
      v_genesis->>'amount_idr', v_genesis->>'rate_used',
      v_expected_prev, v_nonce, v_expected_hash
    );
    insert into public.ledger_heads (user_id, head_idx, head_hash, updated_at)
      values (p_user_id, v_idx, v_expected_hash, now())
      on conflict (user_id) do update
        set head_idx = excluded.head_idx,
            head_hash = excluded.head_hash,
            updated_at = excluded.updated_at;
    v_head_idx := v_idx;
    v_head_hash := v_expected_hash;
  elsif v_genesis is not null then
    if (v_genesis->>'idx')::integer <> 0
      or not exists (
        select 1 from public.ledger_blocks
        where user_id = p_user_id
          and idx = 0
          and hash = v_genesis->>'hash'
          and ts = v_genesis->>'ts'
          and donor_alias = 'Genesis'
          and campaign = 'genesis'
          and amount = '0'
          and currency = 'IDR'
          and amount_idr = '0'
          and rate_used = '1'
      ) then
      raise exception 'genesis_conflict' using errcode = 'P0001';
    end if;
  end if;

  v_idx := (v_block->>'idx')::integer;
  v_nonce := (v_block->>'nonce')::bigint;
  v_expected_prev := v_head_hash;
  v_amount := v_block->>'amount';
  v_amount_idr := v_block->>'amount_idr';
  v_rate := v_block->>'rate_used';
  if v_idx <> v_head_idx + 1 or v_block->>'prev_hash' <> v_expected_prev then
    raise exception 'ledger_conflict' using errcode = 'P0001';
  end if;
  if v_block->>'currency' not in ('IDR', 'USD', 'SAR')
    or v_amount !~ '^[0-9]+(\.[0-9]+)?$'
    or v_amount_idr !~ '^[0-9]+(\.[0-9]+)?$'
    or v_rate !~ '^[0-9]+(\.[0-9]+)?$'
    or v_amount::numeric <= 0
    or v_amount_idr::numeric <= 0
    or v_rate::numeric <= 0 then
    raise exception 'invalid_donation_amount' using errcode = 'P0001';
  end if;

  v_prefix := concat_ws('|',
    v_idx::text,
    v_block->>'ts',
    p_user_id::text,
    v_block->>'donor_alias',
    v_block->>'campaign',
    v_amount,
    v_block->>'currency',
    v_amount_idr,
    v_rate,
    v_expected_prev
  ) || '|';
  v_expected_hash := encode(
    digest(convert_to(v_prefix || v_nonce::text, 'UTF8'), 'sha256'),
    'hex'
  );
  if v_block->>'hash' <> v_expected_hash
    or left(v_expected_hash, 3) <> '000' then
    raise exception 'invalid_block_hash_or_pow' using errcode = 'P0001';
  end if;

  if nullif(p_donation->>'campaign_id', '') is not null then
    v_campaign_id := (p_donation->>'campaign_id')::uuid;
  end if;

  insert into public.donations (
    id, user_id, campaign, campaign_id, amount, currency, amount_idr,
    rate_used, created_at, block_hash
  ) values (
    v_id, p_user_id, v_block->>'campaign', v_campaign_id,
    v_amount, v_block->>'currency', v_amount_idr, v_rate,
    v_created_at, v_expected_hash
  );

  insert into public.ledger_blocks (
    idx, user_id, ts, donor_alias, campaign, amount, currency,
    amount_idr, rate_used, prev_hash, nonce, hash
  ) values (
    v_idx, p_user_id, v_block->>'ts', v_block->>'donor_alias',
    v_block->>'campaign', v_amount, v_block->>'currency',
    v_amount_idr, v_rate, v_expected_prev, v_nonce, v_expected_hash
  );

  update public.ledger_heads
  set head_idx = v_idx, head_hash = v_expected_hash, updated_at = now()
  where user_id = p_user_id;

  return jsonb_build_object(
    'ok', true,
    'duplicate', false,
    'donation_id', v_id,
    'idx', v_idx,
    'hash', v_expected_hash
  );
end;
$$;

revoke all on function public.record_failed_login(uuid, integer, integer)
  from public, anon, authenticated;
revoke all on function public.change_password_and_revoke_sessions(uuid, uuid, text, text, text)
  from public, anon, authenticated;
revoke all on function public.sync_push(uuid, jsonb)
  from public, anon, authenticated;
revoke all on function public.apply_donation(uuid, jsonb)
  from public, anon, authenticated;
grant execute on function public.record_failed_login(uuid, integer, integer)
  to service_role;
grant execute on function public.change_password_and_revoke_sessions(uuid, uuid, text, text, text)
  to service_role;
grant execute on function public.sync_push(uuid, jsonb)
  to service_role;
grant execute on function public.apply_donation(uuid, jsonb)
  to service_role;

commit;
