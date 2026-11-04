-- ============================================================
-- KajuWEB – Supabase foundation
--
-- Run this file in the Supabase SQL editor. It is intentionally
-- repeatable: existing profiles from the first prototype are kept
-- and the rest of the member system is added around them.
-- ============================================================

create extension if not exists "pgcrypto";

-- ------------------------------------------------------------
-- Profiles and member access
-- ------------------------------------------------------------

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null default '',
  surname text not null default '',
  phone text,
  belt text not null default 'white',
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles add column if not exists role text not null default 'member';
alter table public.profiles add column if not exists membership_number text;
alter table public.profiles add column if not exists joined_on date;
alter table public.profiles add column if not exists admin_notes text;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'profiles_role_check'
      and conrelid = 'public.profiles'::regclass
  ) then
    alter table public.profiles
      add constraint profiles_role_check check (role in ('member', 'instructor', 'admin'));
  end if;
end $$;

create or replace function public.belt_rank(level text)
returns integer
language sql
immutable
as $$
  select case level
    when 'white' then 0
    when 'yellow' then 1
    when 'orange' then 2
    when 'purple' then 3
    when 'blue' then 4
    when 'green' then 5
    when 'brown' then 6
    when 'black' then 7
    else 0
  end;
$$;

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and role in ('admin', 'instructor')
      and active = true
  );
$$;

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, name, surname, joined_on)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'name', ''),
    coalesce(new.raw_user_meta_data ->> 'surname', ''),
    current_date
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ------------------------------------------------------------
-- Passport history and licences
-- ------------------------------------------------------------

create table if not exists public.exam_records (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  belt text not null check (belt in ('white','yellow','orange','purple','blue','green','brown','black')),
  exam_date date not null,
  instructor_name text,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.license_renewals (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles(id) on delete cascade,
  license_number text,
  renewed_on date not null,
  expires_on date,
  status text not null default 'active'
    check (status in ('active', 'expiring', 'expired', 'pending')),
  notes text,
  created_at timestamptz not null default now()
);

create index if not exists exam_records_profile_date_idx
  on public.exam_records(profile_id, exam_date desc);
create index if not exists license_renewals_profile_date_idx
  on public.license_renewals(profile_id, renewed_on desc);

-- ------------------------------------------------------------
-- Training library
-- ------------------------------------------------------------

create table if not exists public.techniques (
  id uuid primary key default gen_random_uuid(),
  belt text not null check (belt in ('white','yellow','orange','purple','blue','green','brown','black')),
  category text not null check (category in ('kicks','punches','knife','stick','grappling','combinations')),
  slot smallint not null check (slot between 1 and 2),
  slug text not null unique,
  title_es text not null,
  title_en text not null,
  title_ca text not null,
  description_es text,
  description_en text,
  description_ca text,
  published boolean not null default false,
  sort_order smallint not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (belt, category, slot)
);

create table if not exists public.training_videos (
  id uuid primary key default gen_random_uuid(),
  technique_id uuid not null references public.techniques(id) on delete cascade,
  storage_bucket text not null default 'training-videos',
  storage_path text not null,
  thumbnail_path text,
  duration_seconds integer check (duration_seconds is null or duration_seconds > 0),
  published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (technique_id)
);

drop trigger if exists techniques_set_updated_at on public.techniques;
create trigger techniques_set_updated_at
  before update on public.techniques
  for each row execute function public.set_updated_at();

drop trigger if exists training_videos_set_updated_at on public.training_videos;
create trigger training_videos_set_updated_at
  before update on public.training_videos
  for each row execute function public.set_updated_at();

create index if not exists techniques_belt_category_idx
  on public.techniques(belt, category, sort_order);

-- ------------------------------------------------------------
-- Announcements, events and registrations
-- ------------------------------------------------------------

create table if not exists public.events (
  id uuid primary key default gen_random_uuid(),
  title_es text not null,
  title_en text not null,
  title_ca text not null,
  description_es text,
  description_en text,
  description_ca text,
  starts_at timestamptz not null,
  ends_at timestamptz,
  location text,
  capacity integer check (capacity is null or capacity > 0),
  registration_deadline timestamptz,
  shirt_sizes_enabled boolean not null default false,
  available_sizes text[] not null default array['XS','S','M','L','XL','XXL'],
  image_path text,
  merchandise_items jsonb not null default '[]'::jsonb,
  published boolean not null default false,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.announcements (
  id uuid primary key default gen_random_uuid(),
  kind text not null default 'general'
    check (kind in ('general', 'tshirt', 'event', 'license')),
  title_es text not null,
  title_en text not null,
  title_ca text not null,
  body_es text not null,
  body_en text not null,
  body_ca text not null,
  event_id uuid references public.events(id) on delete set null,
  image_path text,
  pinned boolean not null default false,
  published boolean not null default false,
  starts_at timestamptz not null default now(),
  closes_at timestamptz,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.event_registrations (
  id uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events(id) on delete cascade,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  shirt_size text check (shirt_size is null or shirt_size in ('XS','S','M','L','XL','XXL')),
  merchandise_items jsonb not null default '[]'::jsonb,
  status text not null default 'registered'
    check (status in ('registered', 'waitlist', 'cancelled', 'attended')),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (event_id, profile_id)
);

drop trigger if exists events_set_updated_at on public.events;
create trigger events_set_updated_at
  before update on public.events
  for each row execute function public.set_updated_at();

drop trigger if exists announcements_set_updated_at on public.announcements;
create trigger announcements_set_updated_at
  before update on public.announcements
  for each row execute function public.set_updated_at();

drop trigger if exists event_registrations_set_updated_at on public.event_registrations;
create trigger event_registrations_set_updated_at
  before update on public.event_registrations
  for each row execute function public.set_updated_at();

create index if not exists announcements_published_idx
  on public.announcements(published, starts_at desc);
create index if not exists events_start_idx
  on public.events(published, starts_at);
create index if not exists event_registrations_event_idx
  on public.event_registrations(event_id, status);

-- ------------------------------------------------------------
-- Row-level security
-- ------------------------------------------------------------

alter table public.profiles enable row level security;
alter table public.exam_records enable row level security;
alter table public.license_renewals enable row level security;
alter table public.techniques enable row level security;
alter table public.training_videos enable row level security;
alter table public.events enable row level security;
alter table public.announcements enable row level security;
alter table public.event_registrations enable row level security;

drop policy if exists "Users can view own profile" on public.profiles;
drop policy if exists "Users can update own profile" on public.profiles;
drop policy if exists "Members can view profiles" on public.profiles;
create policy "Members can view profiles"
  on public.profiles for select
  using (auth.uid() = id or public.is_admin());
create policy "Members can update own profile"
  on public.profiles for update
  using (auth.uid() = id or public.is_admin())
  with check (auth.uid() = id or public.is_admin());

drop policy if exists "Members can view own exams" on public.exam_records;
create policy "Members can view own exams"
  on public.exam_records for select
  using (profile_id = auth.uid() or public.is_admin());
drop policy if exists "Admins manage exams" on public.exam_records;
create policy "Admins manage exams"
  on public.exam_records for all
  using (public.is_admin()) with check (public.is_admin());

drop policy if exists "Members can view own licenses" on public.license_renewals;
create policy "Members can view own licenses"
  on public.license_renewals for select
  using (profile_id = auth.uid() or public.is_admin());
drop policy if exists "Admins manage licenses" on public.license_renewals;
create policy "Admins manage licenses"
  on public.license_renewals for all
  using (public.is_admin()) with check (public.is_admin());

drop policy if exists "Members can view accessible techniques" on public.techniques;
create policy "Members can view accessible techniques"
  on public.techniques for select
  using (
    public.is_admin()
    or (
      published = true
      and exists (
        select 1 from public.profiles viewer
        where viewer.id = auth.uid()
          and viewer.active = true
          and public.belt_rank(viewer.belt) + 1 >= public.belt_rank(techniques.belt)
      )
    )
  );
drop policy if exists "Admins manage techniques" on public.techniques;
create policy "Admins manage techniques"
  on public.techniques for all
  using (public.is_admin()) with check (public.is_admin());

drop policy if exists "Members can view accessible videos" on public.training_videos;
create policy "Members can view accessible videos"
  on public.training_videos for select
  using (
    public.is_admin()
    or (
      published = true
      and exists (
        select 1
        from public.techniques lesson
        join public.profiles viewer on viewer.id = auth.uid()
        where lesson.id = training_videos.technique_id
          and lesson.published = true
          and viewer.active = true
          and public.belt_rank(viewer.belt) + 1 >= public.belt_rank(lesson.belt)
      )
    )
  );
drop policy if exists "Admins manage videos" on public.training_videos;
create policy "Admins manage videos"
  on public.training_videos for all
  using (public.is_admin()) with check (public.is_admin());

drop policy if exists "Members can view published events" on public.events;
create policy "Members can view published events"
  on public.events for select
  using (published = true or public.is_admin());
drop policy if exists "Admins manage events" on public.events;
create policy "Admins manage events"
  on public.events for all
  using (public.is_admin()) with check (public.is_admin());

drop policy if exists "Members can view published announcements" on public.announcements;
create policy "Members can view published announcements"
  on public.announcements for select
  using (published = true or public.is_admin());
drop policy if exists "Admins manage announcements" on public.announcements;
create policy "Admins manage announcements"
  on public.announcements for all
  using (public.is_admin()) with check (public.is_admin());

drop policy if exists "Members can view registrations" on public.event_registrations;
create policy "Members can view registrations"
  on public.event_registrations for select
  using (profile_id = auth.uid() or public.is_admin());
drop policy if exists "Members can register themselves" on public.event_registrations;
create policy "Members can register themselves"
  on public.event_registrations for insert
  with check (profile_id = auth.uid());
drop policy if exists "Members can update own registration" on public.event_registrations;
create policy "Members can update own registration"
  on public.event_registrations for update
  using (profile_id = auth.uid() or public.is_admin())
  with check (profile_id = auth.uid() or public.is_admin());
drop policy if exists "Members can cancel own registration" on public.event_registrations;
create policy "Members can cancel own registration"
  on public.event_registrations for delete
  using (profile_id = auth.uid() or public.is_admin());

-- The service role bypasses RLS. Never expose it in browser code.
