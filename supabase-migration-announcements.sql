-- Run this migration once in the Supabase SQL editor.
-- It adds image support and flexible merchandise selections to announcements.

alter table public.announcements add column if not exists image_path text;
alter table public.events add column if not exists image_path text;
alter table public.events add column if not exists merchandise_items jsonb not null default '[]'::jsonb;
alter table public.event_registrations add column if not exists merchandise_items jsonb not null default '[]'::jsonb;

-- Keep existing RLS policies. The existing staff policies cover these columns.
