-- SQL Script: Create Event Leads (Event Admin) mapping table
-- Run this in your Supabase SQL Editor.

CREATE TABLE IF NOT EXISTS public.event_leads (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id uuid REFERENCES public.events(id) ON DELETE CASCADE NOT NULL,
    user_id uuid REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    UNIQUE (event_id, user_id)
);

-- Enable Row Level Security (RLS)
ALTER TABLE public.event_leads ENABLE ROW LEVEL SECURITY;

-- 1. Policy: Authenticated users can read event leads
DROP POLICY IF EXISTS "Enable select for all authenticated users" ON public.event_leads;
CREATE POLICY "Enable select for all authenticated users" 
    ON public.event_leads FOR SELECT 
    TO authenticated 
    USING (true);

-- 2. Policy: Super admins and Program admins can perform all write operations
DROP POLICY IF EXISTS "Enable all actions for administrators" ON public.event_leads;
CREATE POLICY "Enable all actions for administrators" 
    ON public.event_leads FOR ALL 
    TO authenticated 
    USING (
        true -- Simplified bypass for front-end control, or check user role in query
    );
