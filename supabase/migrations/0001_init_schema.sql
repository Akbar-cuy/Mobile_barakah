-- Barakah: skema awal (PRD v2.0, bagian 12.1).

-- ---------------------------------------------------------------- Akun (M1-M3)

create table public.users (
  id              uuid primary key default gen_random_uuid(),
  name            text not null,
  username        text not null unique,
  email           text not null unique,
  password_hash   text not null,
  avatar_url      text,
  failed_attempts int  not null default 0,
  locked_until    timestamptz,
  created_at      timestamptz not null default now()
);

create table public.sessions (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references public.users(id) on delete cascade,
  device_id    text not null,
  refresh_hash text not null,
  expires_at   timestamptz not null,
  revoked_at   timestamptz,
  created_at   timestamptz not null default now()
);
create index sessions_user_idx on public.sessions (user_id);
create index sessions_refresh_idx on public.sessions (refresh_hash);

create table public.device_tokens (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.users(id) on delete cascade,
  device_id  text not null,
  token_hash text not null,
  created_at timestamptz not null default now(),
  revoked_at timestamptz
);
create index device_tokens_user_idx on public.device_tokens (user_id, device_id);

-- ------------------------------------------------------- Donasi dan ledger (M11, M12)

create table public.campaigns (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  description text not null default '',
  category    text not null default 'umum',
  target_idr  numeric,
  version     int  not null default 1,
  active      boolean not null default true
);

-- Nilai uang disimpan sebagai teks desimal kanonik (bukan numeric) agar hash
create table public.donations (
  id          uuid primary key,                -- UUID klien (FR-SYNC-05)
  user_id     uuid not null references public.users(id) on delete cascade,
  campaign    text not null,
  campaign_id uuid references public.campaigns(id),
  amount      text not null,
  currency    text not null check (currency in ('IDR','USD','SAR')),
  amount_idr  text not null,
  rate_used   text not null,
  created_at  timestamptz not null
);
create index donations_user_idx on public.donations (user_id, created_at desc);

create table public.ledger_blocks (
  idx         int  not null,
  user_id     uuid not null references public.users(id),
  ts          text not null,                   -- ISO 8601 UTC, persis seperti yang di-hash
  donor_alias text not null,
  campaign    text not null,
  amount      text not null check (amount ~ '^[0-9]+(\.[0-9]+)?$'),
  currency    text not null check (currency in ('IDR','USD','SAR')),
  amount_idr  text not null check (amount_idr ~ '^[0-9]+(\.[0-9]+)?$'),
  rate_used   text not null check (rate_used ~ '^[0-9]+(\.[0-9]+)?$'),
  prev_hash   text not null,
  nonce       bigint not null,
  hash        text not null unique check (char_length(hash) = 64),
  primary key (user_id, idx)
);
-- Syarat proof of work (jumlah digit nol di awal hash) divalidasi di Edge

create or replace function public.forbid_ledger_change() returns trigger as $$
begin
  raise exception 'ledger_blocks bersifat append only';
end;
$$ language plpgsql;

create trigger ledger_no_update_delete
  before update or delete on public.ledger_blocks
  for each row execute function public.forbid_ledger_change();

create table public.ledger_heads (
  user_id    uuid primary key references public.users(id) on delete cascade,
  head_idx   int  not null,
  head_hash  text not null,
  updated_at timestamptz not null default now()
);

create table public.zakat_calcs (
  id         uuid primary key,
  user_id    uuid not null references public.users(id) on delete cascade,
  type       text not null check (type in ('maal','fitrah')),
  input_idr  text not null,
  nisab_idr  text,
  result_idr text not null,
  created_at timestamptz not null
);

-- ------------------------------------------------------------ Ibadah dan game

create table public.tasbih_logs (
  id       uuid primary key,
  user_id  uuid not null references public.users(id) on delete cascade,
  log_date date not null,
  target   int  not null,
  count    int  not null,
  source   text not null default 'app' check (source in ('app','iot'))
);
create index tasbih_user_idx on public.tasbih_logs (user_id, log_date desc);

create table public.quiz_questions (
  id           uuid primary key default gen_random_uuid(),
  category     text not null,
  difficulty   int  not null check (difficulty between 1 and 3),
  question     text not null,
  options      jsonb not null,
  answer_index int  not null,
  explanation  text not null,
  version      int  not null default 1
);

create table public.quiz_attempts (
  id         uuid primary key,
  user_id    uuid not null references public.users(id) on delete cascade,
  category   text not null,
  score      int  not null,
  correct    int  not null,
  total      int  not null,
  avg_time   real,
  created_at timestamptz not null
);
create index quiz_attempts_user_idx on public.quiz_attempts (user_id, created_at desc);

create table public.game_scores (
  id         uuid primary key,
  user_id    uuid not null references public.users(id) on delete cascade,
  game       text not null,
  score      int  not null,
  created_at timestamptz not null
);

create table public.chat_messages (
  id         uuid primary key,
  user_id    uuid not null references public.users(id) on delete cascade,
  role       text not null check (role in ('user','assistant')),
  content    text not null,
  created_at timestamptz not null
);
create index chat_user_idx on public.chat_messages (user_id, created_at);

create table public.feedback (
  id         uuid primary key,
  user_id    uuid not null references public.users(id) on delete cascade,
  rating     int  not null check (rating between 1 and 5),
  impression text not null check (char_length(impression) between 10 and 500),
  suggestion text not null check (char_length(suggestion) between 10 and 500),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.favorite_mosques (
  id      uuid primary key,
  user_id uuid not null references public.users(id) on delete cascade,
  osm_id  text not null,
  name    text not null,
  lat     double precision not null,
  lon     double precision not null,
  unique (user_id, osm_id)
);

create table public.rate_cache (
  base       text not null,
  quote      text not null,
  rate       numeric not null,
  fetched_at timestamptz not null,
  primary key (base, quote)
);

-- ------------------------------------------------------------------ IoT (M21)

create table public.iot_devices (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.users(id) on delete cascade,
  name       text not null,
  key_hash   text not null,
  last_seen  timestamptz,
  revoked_at timestamptz
);

-- --------------------------------------------------------------------- RLS

alter table public.users          enable row level security;
alter table public.sessions       enable row level security;
alter table public.device_tokens  enable row level security;
alter table public.campaigns      enable row level security;
alter table public.donations      enable row level security;
alter table public.ledger_blocks  enable row level security;
alter table public.ledger_heads   enable row level security;
alter table public.zakat_calcs    enable row level security;
alter table public.tasbih_logs    enable row level security;
alter table public.quiz_questions enable row level security;
alter table public.quiz_attempts  enable row level security;
alter table public.game_scores    enable row level security;
alter table public.chat_messages  enable row level security;
alter table public.feedback       enable row level security;
alter table public.favorite_mosques enable row level security;
alter table public.rate_cache     enable row level security;
alter table public.iot_devices    enable row level security;
