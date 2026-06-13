-- Memory Atlas Supabase schema and starter RLS
create extension if not exists "pgcrypto";

create table if not exists public.accounts (
  id uuid primary key default gen_random_uuid(),
  auth_user_id uuid not null unique references auth.users (id) on delete cascade,
  display_name text,
  email text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_accounts_auth_user_id on public.accounts (auth_user_id);

create table if not exists public.organizations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.organization_members (
  id uuid primary key default gen_random_uuid(),
  organization_id uuid not null references public.organizations (id) on delete cascade,
  account_id uuid not null references public.accounts (id) on delete cascade,
  role text not null default 'member' check (role in ('owner','admin','member')),
  created_at timestamptz not null default now(),
  unique (organization_id, account_id)
);
create index if not exists idx_org_members_org on public.organization_members (organization_id);
create index if not exists idx_org_members_account on public.organization_members (account_id);

create table if not exists public.person_profiles (
  id uuid primary key default gen_random_uuid(),
  account_id uuid not null references public.accounts (id) on delete cascade,
  organization_id uuid references public.organizations (id) on delete set null,
  full_name text not null,
  preferred_name text,
  birth_year int,
  diagnosis_notes text,
  primary_language text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_person_profiles_account on public.person_profiles (account_id);
create index if not exists idx_person_profiles_org on public.person_profiles (organization_id);

create table if not exists public.caregiver_links (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.person_profiles (id) on delete cascade,
  account_id uuid not null references public.accounts (id) on delete cascade,
  relationship text,
  role text default 'secondary' check (role in ('primary','secondary','staff')),
  created_at timestamptz not null default now(),
  unique (profile_id, account_id)
);
create index if not exists idx_caregiver_links_profile on public.caregiver_links (profile_id);
create index if not exists idx_caregiver_links_account on public.caregiver_links (account_id);

create table if not exists public.memory_artifacts (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.person_profiles (id) on delete cascade,
  account_id uuid not null references public.accounts (id) on delete cascade,
  title text not null,
  kind text not null check (kind in ('photo','audio','video','story')),
  description text,
  source_url text,
  thumbnail_url text,
  captured_at timestamptz,
  tags text[] not null default '{}',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_memory_artifacts_profile on public.memory_artifacts (profile_id);
create index if not exists idx_memory_artifacts_account on public.memory_artifacts (account_id);
create index if not exists idx_memory_artifacts_tags on public.memory_artifacts using gin (tags);

create table if not exists public.memory_prompts (
  id uuid primary key default gen_random_uuid(),
  artifact_id uuid not null references public.memory_artifacts (id) on delete cascade,
  prompt_text text not null,
  order_index int not null default 0,
  created_at timestamptz not null default now()
);
create index if not exists idx_memory_prompts_artifact on public.memory_prompts (artifact_id);

create table if not exists public.guided_sessions (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.person_profiles (id) on delete cascade,
  account_id uuid not null references public.accounts (id) on delete cascade,
  title text not null,
  goal text,
  estimated_duration_minutes int,
  is_system_template boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists idx_guided_sessions_profile on public.guided_sessions (profile_id);
create index if not exists idx_guided_sessions_account on public.guided_sessions (account_id);

create table if not exists public.guided_session_steps (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.guided_sessions (id) on delete cascade,
  artifact_id uuid references public.memory_artifacts (id) on delete set null,
  prompt_text text not null,
  order_index int not null default 0,
  duration_seconds int,
  created_at timestamptz not null default now()
);
create index if not exists idx_session_steps_session on public.guided_session_steps (session_id);

create table if not exists public.session_runs (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.guided_sessions (id) on delete cascade,
  profile_id uuid not null references public.person_profiles (id) on delete cascade,
  account_id uuid not null references public.accounts (id) on delete cascade,
  started_at timestamptz not null,
  ended_at timestamptz,
  mood_before text,
  mood_after text,
  notes text,
  environment_context jsonb,
  created_at timestamptz not null default now()
);
create index if not exists idx_session_runs_profile on public.session_runs (profile_id);
create index if not exists idx_session_runs_session on public.session_runs (session_id);

create table if not exists public.session_run_events (
  id uuid primary key default gen_random_uuid(),
  session_run_id uuid not null references public.session_runs (id) on delete cascade,
  step_id uuid references public.guided_session_steps (id) on delete set null,
  event_type text not null,
  payload jsonb,
  created_at timestamptz not null default now()
);
create index if not exists idx_session_run_events_run on public.session_run_events (session_run_id);

create table if not exists public.reminders (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.person_profiles (id) on delete cascade,
  account_id uuid not null references public.accounts (id) on delete cascade,
  session_id uuid references public.guided_sessions (id) on delete set null,
  kind text not null,
  cron_expression text,
  scheduled_at timestamptz,
  time_zone text,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);
create index if not exists idx_reminders_profile on public.reminders (profile_id);
create index if not exists idx_reminders_account on public.reminders (account_id);

create table if not exists public.audit_log (
  id uuid primary key default gen_random_uuid(),
  account_id uuid references public.accounts (id) on delete set null,
  organization_id uuid references public.organizations (id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id uuid,
  payload jsonb,
  created_at timestamptz not null default now()
);
create index if not exists idx_audit_log_account on public.audit_log (account_id);
create index if not exists idx_audit_log_org on public.audit_log (organization_id);

create or replace function public.current_account_id()
returns uuid
language sql
stable
as $$
  select id from public.accounts where auth_user_id = auth.uid()
$$;

create or replace function public.is_org_member(org uuid)
returns boolean
language sql
stable
as $$
  select exists (
    select 1 from public.organization_members
    where organization_id = org and account_id = public.current_account_id()
  )
$$;

alter table public.accounts enable row level security;
alter table public.organizations enable row level security;
alter table public.organization_members enable row level security;
alter table public.person_profiles enable row level security;
alter table public.caregiver_links enable row level security;
alter table public.memory_artifacts enable row level security;
alter table public.memory_prompts enable row level security;
alter table public.guided_sessions enable row level security;
alter table public.guided_session_steps enable row level security;
alter table public.session_runs enable row level security;
alter table public.session_run_events enable row level security;
alter table public.reminders enable row level security;
alter table public.audit_log enable row level security;

create policy accounts_self_select on public.accounts for select using (auth_user_id = auth.uid());
create policy accounts_self_insert on public.accounts for insert with check (auth_user_id = auth.uid());
create policy accounts_self_update on public.accounts for update using (auth_user_id = auth.uid());

create policy profiles_select on public.person_profiles for select using (
  account_id = public.current_account_id() or public.is_org_member(organization_id)
);
create policy profiles_insert on public.person_profiles for insert with check (account_id = public.current_account_id());
create policy profiles_update on public.person_profiles for update using (account_id = public.current_account_id());
create policy profiles_delete on public.person_profiles for delete using (account_id = public.current_account_id());

create policy caregiver_links_select on public.caregiver_links for select using (
  account_id = public.current_account_id() or profile_id in (select id from public.person_profiles where account_id = public.current_account_id())
);
create policy caregiver_links_modify_owner on public.caregiver_links for all using (
  profile_id in (select id from public.person_profiles where account_id = public.current_account_id())
);

create policy artifacts_select on public.memory_artifacts for select using (
  account_id = public.current_account_id() or profile_id in (select profile_id from public.caregiver_links where account_id = public.current_account_id())
);
create policy artifacts_insert on public.memory_artifacts for insert with check (account_id = public.current_account_id());
create policy artifacts_update on public.memory_artifacts for update using (account_id = public.current_account_id());
create policy artifacts_delete on public.memory_artifacts for delete using (account_id = public.current_account_id());

create policy artifact_prompts_select on public.memory_prompts for select using (
  artifact_id in (select id from public.memory_artifacts where account_id = public.current_account_id())
);
create policy artifact_prompts_modify on public.memory_prompts for all using (
  artifact_id in (select id from public.memory_artifacts where account_id = public.current_account_id())
);

create policy guided_sessions_select on public.guided_sessions for select using (
  account_id = public.current_account_id() or profile_id in (select profile_id from public.caregiver_links where account_id = public.current_account_id())
);
create policy guided_sessions_modify on public.guided_sessions for all using (account_id = public.current_account_id());

create policy session_steps_select on public.guided_session_steps for select using (
  session_id in (select id from public.guided_sessions where account_id = public.current_account_id())
);
create policy session_steps_modify on public.guided_session_steps for all using (
  session_id in (select id from public.guided_sessions where account_id = public.current_account_id())
);

create policy session_runs_select on public.session_runs for select using (
  account_id = public.current_account_id() or profile_id in (select profile_id from public.caregiver_links where account_id = public.current_account_id())
);
create policy session_runs_modify on public.session_runs for all using (account_id = public.current_account_id());

create policy session_events_select on public.session_run_events for select using (
  session_run_id in (select id from public.session_runs where account_id = public.current_account_id())
);
create policy session_events_insert on public.session_run_events for insert with check (
  session_run_id in (select id from public.session_runs where account_id = public.current_account_id())
);

create policy reminders_select on public.reminders for select using (account_id = public.current_account_id());
create policy reminders_modify on public.reminders for all using (account_id = public.current_account_id());

create policy audit_select_own on public.audit_log for select using (
  account_id = public.current_account_id() or public.is_org_member(organization_id)
);
