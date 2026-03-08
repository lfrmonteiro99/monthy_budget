-- ─── Household Activity Events ──────────────────────────────────────
-- Lightweight audit trail for household collaboration transparency.

create table household_activity_events (
  id                 uuid primary key default gen_random_uuid(),
  household_id       uuid not null references households(id) on delete cascade,
  actor_user_id      uuid not null references profiles(id),
  actor_display_name text not null,
  domain             text not null check (domain in ('shopping', 'meals', 'expenses', 'pantry', 'settings')),
  action             text not null check (action in ('added', 'removed', 'swapped', 'updated', 'checked', 'unchecked')),
  subject_id         text not null default '',
  subject_label      text not null default '',
  metadata           jsonb not null default '{}',
  created_at         timestamptz default now()
);

-- Primary query pattern: recent activity for a household
create index idx_activity_household_created
  on household_activity_events (household_id, created_at desc);

-- Filtered query pattern: activity by domain within a household
create index idx_activity_household_domain_created
  on household_activity_events (household_id, domain, created_at desc);

-- ─── RLS ─────────────────────────────────────────────────
alter table household_activity_events enable row level security;

create policy "read household activity"
  on household_activity_events for select
  using (household_id = my_household_id());

create policy "insert household activity"
  on household_activity_events for insert
  with check (household_id = my_household_id());
