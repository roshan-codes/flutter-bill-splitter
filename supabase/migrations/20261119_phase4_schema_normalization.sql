-- Migration: 20261119_phase4_schema_normalization.sql
-- Description: Phase 4 Database Schema Normalization & Zero-Downtime Migration.
--              Transforms monolithic JSONB stories into first-class relational tables:
--              `story_members`, `expenses`, `expense_shares`, and `settlements`.

-- 1. Helper Function: Check if current authenticated user is member/creator of a story
CREATE OR REPLACE FUNCTION public.is_story_member(p_story_id TEXT)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.stories s
        WHERE s.story_id = p_story_id
          AND (
              s.created_by = (SELECT auth.uid())::text
              OR s.user_id = (SELECT auth.uid())::text
              OR EXISTS (
                  SELECT 1 FROM public.story_members sm
                  WHERE sm.story_id = p_story_id
                    AND sm.user_id = (SELECT auth.uid())::text
              )
              OR (s.data->'members' IS NOT NULL AND s.data->'members' @> jsonb_build_array(jsonb_build_object('user_id', (SELECT auth.uid())::text)))
          )
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- 2. Create `story_members` Table
CREATE TABLE IF NOT EXISTS public.story_members (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    story_id TEXT NOT NULL REFERENCES public.stories(story_id) ON DELETE CASCADE,
    user_id TEXT NOT NULL,
    name TEXT NOT NULL,
    role TEXT DEFAULT 'member',
    avatar TEXT,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    phone TEXT,
    email TEXT,
    CONSTRAINT uq_story_members UNIQUE (story_id, user_id)
);

-- 3. Create `expenses` Table
CREATE TABLE IF NOT EXISTS public.expenses (
    expense_id TEXT PRIMARY KEY,
    story_id TEXT NOT NULL REFERENCES public.stories(story_id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    category TEXT NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    amount_paise BIGINT NOT NULL,
    paid_by TEXT NOT NULL,
    split_type TEXT DEFAULT 'equal',
    date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    notes TEXT,
    receipt_url TEXT
);

-- 4. Create `expense_shares` Table
CREATE TABLE IF NOT EXISTS public.expense_shares (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    expense_id TEXT NOT NULL REFERENCES public.expenses(expense_id) ON DELETE CASCADE,
    story_id TEXT NOT NULL REFERENCES public.stories(story_id) ON DELETE CASCADE,
    user_id TEXT NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    amount_paise BIGINT NOT NULL,
    percentage NUMERIC(5, 2),
    is_settled BOOLEAN DEFAULT FALSE,
    CONSTRAINT uq_expense_shares UNIQUE (expense_id, user_id)
);

-- 5. Create `settlements` Table
CREATE TABLE IF NOT EXISTS public.settlements (
    settlement_id TEXT PRIMARY KEY,
    story_id TEXT NOT NULL REFERENCES public.stories(story_id) ON DELETE CASCADE,
    from_user TEXT NOT NULL,
    to_user TEXT NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    amount_paise BIGINT NOT NULL,
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    proof_image_url TEXT
);

-- 6. Performance Indexes (Adhering to Supabase Query Performance Rules)
CREATE INDEX IF NOT EXISTS idx_story_members_story ON public.story_members(story_id);
CREATE INDEX IF NOT EXISTS idx_story_members_user ON public.story_members(user_id);

CREATE INDEX IF NOT EXISTS idx_expenses_story ON public.expenses(story_id);
CREATE INDEX IF NOT EXISTS idx_expenses_story_date ON public.expenses(story_id, date DESC);

CREATE INDEX IF NOT EXISTS idx_expense_shares_expense ON public.expense_shares(expense_id);
CREATE INDEX IF NOT EXISTS idx_expense_shares_user ON public.expense_shares(user_id);
CREATE INDEX IF NOT EXISTS idx_expense_shares_story ON public.expense_shares(story_id);

CREATE INDEX IF NOT EXISTS idx_settlements_story ON public.settlements(story_id);
CREATE INDEX IF NOT EXISTS idx_settlements_status ON public.settlements(story_id, status);

-- 7. Enable Row-Level Security (RLS) on all normalized tables
ALTER TABLE public.story_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.expense_shares ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settlements ENABLE ROW LEVEL SECURITY;

-- 8. Clean up old policies if re-running
DROP POLICY IF EXISTS "Story members select policy" ON public.story_members;
DROP POLICY IF EXISTS "Story members insert policy" ON public.story_members;
DROP POLICY IF EXISTS "Story members update policy" ON public.story_members;
DROP POLICY IF EXISTS "Story members delete policy" ON public.story_members;

DROP POLICY IF EXISTS "Expenses select policy" ON public.expenses;
DROP POLICY IF EXISTS "Expenses insert policy" ON public.expenses;
DROP POLICY IF EXISTS "Expenses update policy" ON public.expenses;
DROP POLICY IF EXISTS "Expenses delete policy" ON public.expenses;

DROP POLICY IF EXISTS "Expense shares select policy" ON public.expense_shares;
DROP POLICY IF EXISTS "Expense shares insert policy" ON public.expense_shares;
DROP POLICY IF EXISTS "Expense shares update policy" ON public.expense_shares;
DROP POLICY IF EXISTS "Expense shares delete policy" ON public.expense_shares;

DROP POLICY IF EXISTS "Settlements select policy" ON public.settlements;
DROP POLICY IF EXISTS "Settlements insert policy" ON public.settlements;
DROP POLICY IF EXISTS "Settlements update policy" ON public.settlements;
DROP POLICY IF EXISTS "Settlements delete policy" ON public.settlements;

-- 9. Define RLS Policies for Normalized Tables
-- A. story_members
CREATE POLICY "Story members select policy" ON public.story_members
    FOR SELECT TO authenticated
    USING (public.is_story_member(story_id));

CREATE POLICY "Story members insert policy" ON public.story_members
    FOR INSERT TO authenticated
    WITH CHECK (public.is_story_member(story_id));

CREATE POLICY "Story members update policy" ON public.story_members
    FOR UPDATE TO authenticated
    USING (public.is_story_member(story_id))
    WITH CHECK (public.is_story_member(story_id));

CREATE POLICY "Story members delete policy" ON public.story_members
    FOR DELETE TO authenticated
    USING (public.is_story_member(story_id));

-- B. expenses
CREATE POLICY "Expenses select policy" ON public.expenses
    FOR SELECT TO authenticated
    USING (public.is_story_member(story_id));

CREATE POLICY "Expenses insert policy" ON public.expenses
    FOR INSERT TO authenticated
    WITH CHECK (public.is_story_member(story_id));

CREATE POLICY "Expenses update policy" ON public.expenses
    FOR UPDATE TO authenticated
    USING (public.is_story_member(story_id))
    WITH CHECK (public.is_story_member(story_id));

CREATE POLICY "Expenses delete policy" ON public.expenses
    FOR DELETE TO authenticated
    USING (public.is_story_member(story_id));

-- C. expense_shares
CREATE POLICY "Expense shares select policy" ON public.expense_shares
    FOR SELECT TO authenticated
    USING (public.is_story_member(story_id));

CREATE POLICY "Expense shares insert policy" ON public.expense_shares
    FOR INSERT TO authenticated
    WITH CHECK (public.is_story_member(story_id));

CREATE POLICY "Expense shares update policy" ON public.expense_shares
    FOR UPDATE TO authenticated
    USING (public.is_story_member(story_id))
    WITH CHECK (public.is_story_member(story_id));

CREATE POLICY "Expense shares delete policy" ON public.expense_shares
    FOR DELETE TO authenticated
    USING (public.is_story_member(story_id));

-- D. settlements
CREATE POLICY "Settlements select policy" ON public.settlements
    FOR SELECT TO authenticated
    USING (public.is_story_member(story_id));

CREATE POLICY "Settlements insert policy" ON public.settlements
    FOR INSERT TO authenticated
    WITH CHECK (public.is_story_member(story_id));

CREATE POLICY "Settlements update policy" ON public.settlements
    FOR UPDATE TO authenticated
    USING (public.is_story_member(story_id))
    WITH CHECK (public.is_story_member(story_id));

CREATE POLICY "Settlements delete policy" ON public.settlements
    FOR DELETE TO authenticated
    USING (public.is_story_member(story_id));

-- 10. Bidirectional Synchronization Function & Trigger
-- Automatically unpacks legacy `data` JSONB into normalized tables on INSERT/UPDATE
CREATE OR REPLACE FUNCTION public.sync_story_jsonb_to_relational()
RETURNS TRIGGER AS $$
DECLARE
    m JSONB;
    e JSONB;
    s JSONB;
    sh JSONB;
    v_amount NUMERIC(12, 2);
    v_paise BIGINT;
BEGIN
    IF NEW.data IS NULL THEN
        RETURN NEW;
    END IF;

    -- A. Unpack Members
    IF NEW.data ? 'members' AND jsonb_typeof(NEW.data->'members') = 'array' THEN
        FOR m IN SELECT * FROM jsonb_array_elements(NEW.data->'members')
        LOOP
            IF (m->>'user_id') IS NOT NULL AND (m->>'user_id') != '' THEN
                INSERT INTO public.story_members (story_id, user_id, name, role, avatar, joined_at, phone, email)
                VALUES (
                    NEW.story_id,
                    m->>'user_id',
                    COALESCE(m->>'name', 'Member'),
                    COALESCE(m->>'role', 'member'),
                    m->>'avatar',
                    COALESCE((m->>'joined_at')::timestamptz, NOW()),
                    m->>'phone',
                    m->>'email'
                )
                ON CONFLICT (story_id, user_id) DO UPDATE SET
                    name = EXCLUDED.name,
                    role = EXCLUDED.role,
                    avatar = COALESCE(EXCLUDED.avatar, public.story_members.avatar);
            END IF;
        END LOOP;
    END IF;

    -- B. Unpack Expenses & Shares
    IF NEW.data ? 'expenses' AND jsonb_typeof(NEW.data->'expenses') = 'array' THEN
        FOR e IN SELECT * FROM jsonb_array_elements(NEW.data->'expenses')
        LOOP
            IF (e->>'expense_id') IS NOT NULL THEN
                v_amount := COALESCE((e->>'amount')::numeric, 0.0);
                v_paise := ROUND(v_amount * 100)::bigint;

                INSERT INTO public.expenses (expense_id, story_id, title, category, amount, amount_paise, paid_by, split_type, date, created_at, notes, receipt_url)
                VALUES (
                    e->>'expense_id',
                    NEW.story_id,
                    COALESCE(e->>'title', 'Expense'),
                    COALESCE(e->>'category', 'general'),
                    v_amount,
                    v_paise,
                    COALESCE(e->>'paid_by', 'unknown'),
                    COALESCE(e->>'split_type', 'equal'),
                    COALESCE((e->>'date')::timestamptz, NOW()),
                    NOW(),
                    e->>'notes',
                    e->>'receipt_url'
                )
                ON CONFLICT (expense_id) DO UPDATE SET
                    title = EXCLUDED.title,
                    category = EXCLUDED.category,
                    amount = EXCLUDED.amount,
                    amount_paise = EXCLUDED.amount_paise,
                    paid_by = EXCLUDED.paid_by,
                    split_type = EXCLUDED.split_type,
                    date = EXCLUDED.date;

                -- Unpack individual shares for this expense
                IF e ? 'shares' AND jsonb_typeof(e->'shares') = 'array' THEN
                    FOR sh IN SELECT * FROM jsonb_array_elements(e->'shares')
                    LOOP
                        IF (sh->>'user_id') IS NOT NULL THEN
                            INSERT INTO public.expense_shares (expense_id, story_id, user_id, amount, amount_paise, percentage, is_settled)
                            VALUES (
                                e->>'expense_id',
                                NEW.story_id,
                                sh->>'user_id',
                                COALESCE((sh->>'amount')::numeric, 0.0),
                                ROUND(COALESCE((sh->>'amount')::numeric, 0.0) * 100)::bigint,
                                (sh->>'percentage')::numeric,
                                COALESCE((sh->>'is_settled')::boolean, FALSE)
                            )
                            ON CONFLICT (expense_id, user_id) DO UPDATE SET
                                amount = EXCLUDED.amount,
                                amount_paise = EXCLUDED.amount_paise,
                                is_settled = EXCLUDED.is_settled;
                        END IF;
                    END LOOP;
                END IF;
            END IF;
        END LOOP;
    END IF;

    -- C. Unpack Settlements
    IF NEW.data ? 'settlements' AND jsonb_typeof(NEW.data->'settlements') = 'array' THEN
        FOR s IN SELECT * FROM jsonb_array_elements(NEW.data->'settlements')
        LOOP
            IF (s->>'settlement_id') IS NOT NULL THEN
                v_amount := COALESCE((s->>'amount')::numeric, 0.0);
                v_paise := ROUND(v_amount * 100)::bigint;

                INSERT INTO public.settlements (settlement_id, story_id, from_user, to_user, amount, amount_paise, status, created_at, completed_at, proof_image_url)
                VALUES (
                    s->>'settlement_id',
                    NEW.story_id,
                    COALESCE(s->>'from_user', 'unknown'),
                    COALESCE(s->>'to_user', 'unknown'),
                    v_amount,
                    v_paise,
                    COALESCE(s->>'status', 'pending'),
                    COALESCE((s->>'created_at')::timestamptz, NOW()),
                    (s->>'completed_at')::timestamptz,
                    s->>'proof_image_url'
                )
                ON CONFLICT (settlement_id) DO UPDATE SET
                    status = EXCLUDED.status,
                    amount = EXCLUDED.amount,
                    amount_paise = EXCLUDED.amount_paise,
                    completed_at = EXCLUDED.completed_at;
            END IF;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 11. Attach Trigger on `public.stories`
DROP TRIGGER IF EXISTS trg_sync_story_jsonb_to_relational ON public.stories;
CREATE TRIGGER trg_sync_story_jsonb_to_relational
    AFTER INSERT OR UPDATE ON public.stories
    FOR EACH ROW
    EXECUTE FUNCTION public.sync_story_jsonb_to_relational();

-- 12. Run One-Time Backfill for all existing stories
DO $$
DECLARE
    story_row RECORD;
BEGIN
    FOR story_row IN SELECT * FROM public.stories WHERE data IS NOT NULL
    LOOP
        -- Trigger unpacking for each existing story
        UPDATE public.stories
        SET updated_at = NOW()
        WHERE story_id = story_row.story_id;
    END LOOP;
END;
$$ LANGUAGE plpgsql;
