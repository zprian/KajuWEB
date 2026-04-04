-- ============================================================
-- KajuWEB – Supabase Schema
-- Run this in the Supabase SQL editor (project > SQL editor)
-- ============================================================

-- Profiles table (extends auth.users)
CREATE TABLE public.profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name        TEXT NOT NULL DEFAULT '',
  surname     TEXT NOT NULL DEFAULT '',
  phone       TEXT,
  belt        TEXT NOT NULL DEFAULT 'white'
                CHECK (belt IN ('white','yellow','orange','purple','blue','green','brown','black')),
  active      BOOLEAN NOT NULL DEFAULT true,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- Auto-create profile on new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, name, surname)
  VALUES (NEW.id, '', '');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Row Level Security
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Users can read and update only their own profile
CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Admins (service role) can do everything
-- The service role bypasses RLS by default

-- ============================================================
-- NOTES:
-- Belt order for access control:
--   white=0, yellow=1, orange=2, purple=3
--   blue=4, green=5, brown=6, black=7
--
-- To add a new member (admin only):
--   1. Go to Supabase > Authentication > Users > Invite user
--   2. After they accept, update their profile:
--      UPDATE profiles SET name='...', surname='...', belt='yellow' WHERE id='...';
--
-- To change a member's belt (admin only):
--   UPDATE profiles SET belt='blue' WHERE id='...';
-- ============================================================
