-- Coach memory architecture foundation (Issue #51)
-- Apply this after base schema.sql in environments where Coach memory is enabled.

create extension if not exists vector;

create table if not exists coach_threads (
  id            uuid primary key default gen_random_uuid(),
  household_id  uuid not null references households(id) on delete cascade,
  user_id       uuid not null references profiles(id) on delete cascade,
  title         text,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create table if not exists coach_messages (
  id            uuid primary key default gen_random_uuid(),
  thread_id      uuid not null references coach_threads(id) on delete cascade,
  household_id  uuid not null references households(id) on delete cascade,
  user_id       uuid not null references profiles(id) on delete cascade,
  role          text not null check (role in ('system', 'user', 'assistant')),
  content       text not null,
  token_count   int,
  mode_used     text not null check (mode_used in ('eco', 'plus', 'pro')),
  created_at    timestamptz not null default now()
);

create index if not exists idx_coach_messages_thread_created
  on coach_messages(thread_id, created_at desc);

create table if not exists coach_memories (
  id                uuid primary key default gen_random_uuid(),
  household_id      uuid not null references households(id) on delete cascade,
  user_id           uuid not null references profiles(id) on delete cascade,
  source_message_id uuid references coach_messages(id) on delete set null,
  type              text not null check (type in ('goal', 'habit', 'fact', 'preference', 'event', 'insight')),
  content           text not null,
  importance        int not null default 1 check (importance between 1 and 5),
  embedding         vector(1536),
  created_at        timestamptz not null default now(),
  expires_at        timestamptz
);

create index if not exists idx_coach_memories_user_created
  on coach_memories(user_id, created_at desc);

create index if not exists idx_coach_memories_embedding
  on coach_memories using ivfflat (embedding vector_cosine_ops) with (lists = 100);

create table if not exists coach_memory_summaries (
  id            uuid primary key default gen_random_uuid(),
  thread_id      uuid not null references coach_threads(id) on delete cascade,
  household_id  uuid not null references households(id) on delete cascade,
  user_id       uuid not null references profiles(id) on delete cascade,
  summary       text not null,
  window_start  timestamptz not null,
  window_end    timestamptz not null,
  created_at    timestamptz not null default now()
);

create index if not exists idx_coach_summaries_thread_created
  on coach_memory_summaries(thread_id, created_at desc);

create table if not exists coach_usage_events (
  id                     uuid primary key default gen_random_uuid(),
  household_id           uuid not null references households(id) on delete cascade,
  user_id                uuid not null references profiles(id) on delete cascade,
  thread_id              uuid references coach_threads(id) on delete set null,
  requested_mode         text not null check (requested_mode in ('eco', 'plus', 'pro')),
  effective_mode         text not null check (effective_mode in ('eco', 'plus', 'pro')),
  used_fallback          boolean not null default false,
  fallback_reason        text,
  response_length_chars  int,
  created_at             timestamptz not null default now()
);

create index if not exists idx_coach_usage_events_user_created
  on coach_usage_events(user_id, created_at desc);

alter table coach_threads enable row level security;
alter table coach_messages enable row level security;
alter table coach_memories enable row level security;
alter table coach_memory_summaries enable row level security;
alter table coach_usage_events enable row level security;

create policy "read coach_threads" on coach_threads
  for select using (household_id = my_household_id());
create policy "insert coach_threads" on coach_threads
  for insert with check (household_id = my_household_id() and user_id = auth.uid());
create policy "update own coach_threads" on coach_threads
  for update using (household_id = my_household_id() and user_id = auth.uid());

create policy "read coach_messages" on coach_messages
  for select using (household_id = my_household_id());
create policy "insert coach_messages" on coach_messages
  for insert with check (household_id = my_household_id() and user_id = auth.uid());

create policy "read coach_memories" on coach_memories
  for select using (household_id = my_household_id());
create policy "insert coach_memories" on coach_memories
  for insert with check (household_id = my_household_id() and user_id = auth.uid());
create policy "update own coach_memories" on coach_memories
  for update using (household_id = my_household_id() and user_id = auth.uid());

create policy "read coach_memory_summaries" on coach_memory_summaries
  for select using (household_id = my_household_id());
create policy "insert coach_memory_summaries" on coach_memory_summaries
  for insert with check (household_id = my_household_id() and user_id = auth.uid());

create policy "read coach_usage_events" on coach_usage_events
  for select using (household_id = my_household_id());
create policy "insert coach_usage_events" on coach_usage_events
  for insert with check (household_id = my_household_id() and user_id = auth.uid());

create or replace function match_coach_memories(
  p_household_id uuid,
  p_user_id uuid,
  p_query_embedding vector(1536),
  p_limit int default 6
)
returns table (
  id uuid,
  content text,
  type text,
  importance int,
  score float
)
language sql
stable
security definer
set search_path = public
as $$
  select
    m.id,
    m.content,
    m.type,
    m.importance,
    1 - (m.embedding <=> p_query_embedding) as score
  from coach_memories m
  where m.household_id = p_household_id
    and m.user_id = p_user_id
    and m.embedding is not null
    and (m.expires_at is null or m.expires_at > now())
  order by m.embedding <=> p_query_embedding, m.importance desc
  limit greatest(1, least(coalesce(p_limit, 6), 20));
$$;
