-- SQL Script: Create Event Leads (Event Admin) mapping table
-- Run this in your Supabase SQL Editor.

CREATE TABLE IF NOT EXISTS public.event_leads (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id uuid REFERENCES public.events(id) ON DELETE CASCADE NOT NULL,
    user_id uuid REFERENCES public.users(id) ON DELETE CASCADE NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    UNIQUE (event_id, user_id)
);

-- Disable Row Level Security (RLS) to match the project's architecture
ALTER TABLE public.event_leads DISABLE ROW LEVEL SECURITY;
