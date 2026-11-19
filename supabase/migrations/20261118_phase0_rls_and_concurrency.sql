-- Migration: 20261118_phase0_rls_and_concurrency.sql
-- Description: Phase 0 Security Hardening - Add optimistic locking version column,
--              enable Row Level Security (RLS) on public tables, and apply tenant isolation policies.

-- 1. Ensure concurrency locking column exists on stories table
ALTER TABLE public.stories ADD COLUMN IF NOT EXISTS version INT DEFAULT 1;
ALTER TABLE public.stories ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- 2. Trigger to automatically update updated_at timestamp on row mutation
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_stories_updated_at ON public.stories;
CREATE TRIGGER trg_stories_updated_at
    BEFORE UPDATE ON public.stories
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- 3. Enable Row-Level Security on exposed public tables
ALTER TABLE public.stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- 4. Clean up any existing permissive or conflicting policies
DROP POLICY IF EXISTS "Stories are viewable by story members" ON public.stories;
DROP POLICY IF EXISTS "Stories are editable by story members" ON public.stories;
DROP POLICY IF EXISTS "Stories are deletable by creator" ON public.stories;
DROP POLICY IF EXISTS "Stories select policy" ON public.stories;
DROP POLICY IF EXISTS "Stories upsert policy" ON public.stories;

DROP POLICY IF EXISTS "Activities are viewable by group members" ON public.activities;
DROP POLICY IF EXISTS "Activities are insertable by group members" ON public.activities;

DROP POLICY IF EXISTS "Profiles are viewable by everyone" ON public.profiles;
DROP POLICY IF EXISTS "Profiles are editable by owner" ON public.profiles;

-- 5. Stories Table Policies (Optimized with cached subqueries (select auth.uid()))
-- A. SELECT: Users can only view stories where they are creator, owner, or listed in the JSON members array
CREATE POLICY "Stories select policy" ON public.stories
    FOR SELECT
    TO authenticated
    USING (
        created_by = (SELECT auth.uid())::text
        OR user_id = (SELECT auth.uid())::text
        OR (data->'members' IS NOT NULL AND data->'members' @> jsonb_build_array(jsonb_build_object('user_id', (SELECT auth.uid())::text)))
    );

-- B. INSERT: Users can create stories assigned to their own user id
CREATE POLICY "Stories insert policy" ON public.stories
    FOR INSERT
    TO authenticated
    WITH CHECK (
        created_by = (SELECT auth.uid())::text
        OR user_id = (SELECT auth.uid())::text
    );

-- C. UPDATE: Members and creators can update group stories
CREATE POLICY "Stories update policy" ON public.stories
    FOR UPDATE
    TO authenticated
    USING (
        created_by = (SELECT auth.uid())::text
        OR user_id = (SELECT auth.uid())::text
        OR (data->'members' IS NOT NULL AND data->'members' @> jsonb_build_array(jsonb_build_object('user_id', (SELECT auth.uid())::text)))
    )
    WITH CHECK (
        created_by = (SELECT auth.uid())::text
        OR user_id = (SELECT auth.uid())::text
        OR (data->'members' IS NOT NULL AND data->'members' @> jsonb_build_array(jsonb_build_object('user_id', (SELECT auth.uid())::text)))
    );

-- D. DELETE: Only story creator can delete the story
CREATE POLICY "Stories delete policy" ON public.stories
    FOR DELETE
    TO authenticated
    USING (
        created_by = (SELECT auth.uid())::text
        OR user_id = (SELECT auth.uid())::text
    );

-- 6. Activities Table Policies
CREATE POLICY "Activities select policy" ON public.activities
    FOR SELECT
    TO authenticated
    USING (
        user_id = (SELECT auth.uid())::text
        OR (data->'members' IS NOT NULL AND data->'members' @> jsonb_build_array(jsonb_build_object('user_id', (SELECT auth.uid())::text)))
    );

CREATE POLICY "Activities insert policy" ON public.activities
    FOR INSERT
    TO authenticated
    WITH CHECK (
        user_id = (SELECT auth.uid())::text
        OR (SELECT auth.uid()) IS NOT NULL
    );

-- 7. Profiles Table Policies
CREATE POLICY "Profiles select policy" ON public.profiles
    FOR SELECT
    TO authenticated, anon
    USING (true);

CREATE POLICY "Profiles update policy" ON public.profiles
    FOR UPDATE
    TO authenticated
    USING (id = (SELECT auth.uid()))
    WITH CHECK (id = (SELECT auth.uid()));

CREATE POLICY "Profiles insert policy" ON public.profiles
    FOR INSERT
    TO authenticated
    WITH CHECK (id = (SELECT auth.uid()));
