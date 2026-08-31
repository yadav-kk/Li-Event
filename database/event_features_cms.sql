-- ==========================================
-- EVENT FEATURES CMS DATABASE MIGRATION
-- Run this in your Supabase SQL Editor
-- ==========================================

-- 1. Create System Features catalog table
CREATE TABLE IF NOT EXISTS public.features (
    code text PRIMARY KEY,
    name text NOT NULL,
    description text,
    default_enabled boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

-- Enable RLS and add policies
ALTER TABLE public.features ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access to features" ON public.features;
CREATE POLICY "Allow public read access to features" ON public.features FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow write access to admins only" ON public.features;
CREATE POLICY "Allow write access to admins only" ON public.features FOR ALL TO authenticated USING (true);

-- 2. Create Event Features Mapping table
CREATE TABLE IF NOT EXISTS public.event_features_mapping (
    event_id uuid REFERENCES public.events(id) ON DELETE CASCADE NOT NULL,
    feature_code text REFERENCES public.features(code) ON DELETE CASCADE NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    PRIMARY KEY (event_id, feature_code)
);

-- Enable RLS and add policies
ALTER TABLE public.event_features_mapping ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Allow public read access to event_features_mapping" ON public.event_features_mapping;
CREATE POLICY "Allow public read access to event_features_mapping" ON public.event_features_mapping FOR SELECT USING (true);

DROP POLICY IF EXISTS "Allow write access to authenticated users" ON public.event_features_mapping;
CREATE POLICY "Allow write access to authenticated users" ON public.event_features_mapping FOR ALL TO authenticated USING (true);

-- 3. Seed our first feature: Direct Centre Grading
INSERT INTO public.features (code, name, description, default_enabled)
VALUES (
    'allow_centre_marking',
    'Allow Centres to Grade (Direct Assessor Access)',
    'Allows local coordinators and teachers belonging to the event centres to enter grades directly on the Judge Panel during active stage dates without explicit judge assignments.',
    false
) ON CONFLICT (code) DO UPDATE 
SET name = EXCLUDED.name, description = EXCLUDED.description;
