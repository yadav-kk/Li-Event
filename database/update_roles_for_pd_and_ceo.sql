-- SQL Migration: Add Project Director and CEO roles and seed accounts
-- Run this in your Supabase SQL Editor.

-- 1. Alter check constraint for roles
ALTER TABLE public.user_roles DROP CONSTRAINT IF EXISTS user_roles_role_id_check;
ALTER TABLE public.user_roles ADD CONSTRAINT user_roles_role_id_check CHECK (
    role_id IN ('super_admin', 'prog_admin', 'centre_incharge', 'judge', 'academic_lead', 'final_judge', 'coordinator', 'management', 'project_director', 'ceo')
);

-- 2. Insert Users into public.users with password 'password123'
-- Sunil Kumar Singh
INSERT INTO public.users (id, name, email, password, mobile, status)
VALUES ('70000000-0000-0000-0000-000000000001', 'Sunil Kumar Singh', 'sunilkumarsingh@literacyindia.org', 'password123', '9999999901', 'active')
ON CONFLICT (email) DO UPDATE SET password = 'password123';

-- Satya Prakash
INSERT INTO public.users (id, name, email, password, mobile, status)
VALUES ('70000000-0000-0000-0000-000000000002', 'Satya Prakash', 'satya@literacyindia.org', 'password123', '9999999902', 'active')
ON CONFLICT (email) DO UPDATE SET password = 'password123';

-- Sohit Yadav
INSERT INTO public.users (id, name, email, password, mobile, status)
VALUES ('70000000-0000-0000-0000-000000000003', 'Sohit Yadav', 'sohit.yadav@literacyindia.org', 'password123', '9999999903', 'active')
ON CONFLICT (email) DO UPDATE SET password = 'password123';

-- Sanghamitra Chanda
INSERT INTO public.users (id, name, email, password, mobile, status)
VALUES ('70000000-0000-0000-0000-000000000004', 'Sanghamitra Chanda', 'sangha.mitra@literacyindia.org', 'password123', '9999999904', 'active')
ON CONFLICT (email) DO UPDATE SET password = 'password123';

-- CAPT INDRAANI SINGH (CEO)
INSERT INTO public.users (id, name, email, password, mobile, status)
VALUES ('70000000-0000-0000-0000-000000000005', 'CAPT INDRAANI SINGH', 'indraani@literacyindia.org', 'password123', '9999999905', 'active')
ON CONFLICT (email) DO UPDATE SET password = 'password123';


-- 3. Map Roles in public.user_roles
INSERT INTO public.user_roles (user_id, role_id)
VALUES 
('70000000-0000-0000-0000-000000000001', 'project_director'),
('70000000-0000-0000-0000-000000000002', 'project_director'),
('70000000-0000-0000-0000-000000000003', 'project_director'),
('70000000-0000-0000-0000-000000000004', 'project_director'),
('70000000-0000-0000-0000-000000000005', 'ceo')
ON CONFLICT DO NOTHING;


-- 4. Seed Centre mappings in public.user_centres
-- Sunil Kumar Singh: Noida ('c1000000-0000-0000-0000-000000000002')
INSERT INTO public.user_centres (user_id, centre_id)
VALUES ('70000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000002')
ON CONFLICT DO NOTHING;

-- Satya Prakash: Delhi ('c1000000-0000-0000-0000-000000000001'), Noida ('c1000000-0000-0000-0000-000000000002')
INSERT INTO public.user_centres (user_id, centre_id)
VALUES 
('70000000-0000-0000-0000-000000000002', 'c1000000-0000-0000-0000-000000000001'),
('70000000-0000-0000-0000-000000000002', 'c1000000-0000-0000-0000-000000000002')
ON CONFLICT DO NOTHING;

-- Sohit Yadav: Gurugram ('c1000000-0000-0000-0000-000000000003')
INSERT INTO public.user_centres (user_id, centre_id)
VALUES ('70000000-0000-0000-0000-000000000003', 'c1000000-0000-0000-0000-000000000003')
ON CONFLICT DO NOTHING;

-- Sanghamitra Chanda: Noida ('c1000000-0000-0000-0000-000000000002'), Gurugram ('c1000000-0000-0000-0000-000000000003')
INSERT INTO public.user_centres (user_id, centre_id)
VALUES 
('70000000-0000-0000-0000-000000000004', 'c1000000-0000-0000-0000-000000000002'),
('70000000-0000-0000-0000-000000000004', 'c1000000-0000-0000-0000-000000000003')
ON CONFLICT DO NOTHING;
