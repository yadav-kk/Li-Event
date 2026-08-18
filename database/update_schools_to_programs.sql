-- SQL Migration: Refactor Schools to Programs
-- Run this in your Supabase SQL Editor to update your database schema.

-- 1. Rename schools table to programs
ALTER TABLE public.schools RENAME TO programs;

-- 2. Rename columns in programs
ALTER TABLE public.programs RENAME COLUMN school_name TO program_name;
ALTER TABLE public.programs RENAME COLUMN school_code TO program_code;
ALTER TABLE public.programs RENAME COLUMN school_type TO program_type;

-- 3. Reconfigure program_type check constraint
ALTER TABLE public.programs DROP CONSTRAINT IF EXISTS schools_school_type_check;
ALTER TABLE public.programs ADD CONSTRAINT programs_program_type_check CHECK (program_type IN ('SMART_CLASS_PATHASHALA', 'BASIC_IT', 'VOCATIONAL', 'GYANTANTRA', 'GOVERNMENT', 'NGO', 'COMMUNITY', 'OTHER'));

-- 4. Rename primary and unique constraints
ALTER TABLE public.programs RENAME CONSTRAINT schools_pkey TO programs_pkey;
ALTER TABLE public.programs RENAME CONSTRAINT schools_school_code_key TO programs_program_code_key;

-- 5. Rename school_id referencing column to program_id in students (participants) table
ALTER TABLE public.students RENAME COLUMN school_id TO program_id;

-- 6. Rename foreign key constraint referencing students table
ALTER TABLE public.students RENAME CONSTRAINT students_school_id_fkey TO students_program_id_fkey;

-- 7. Migrate default seeded data to Program definitions
UPDATE public.programs SET program_name = 'Smart Class/Pathashala', program_code = 'SC-01', program_type = 'SMART_CLASS_PATHASHALA' WHERE id = 'a1000000-0000-0000-0000-000000000001';
UPDATE public.programs SET program_name = 'Basic IT', program_code = 'IT-01', program_type = 'BASIC_IT' WHERE id = 'a1000000-0000-0000-0000-000000000002';
UPDATE public.programs SET program_name = 'Vocational', program_code = 'VC-01', program_type = 'VOCATIONAL' WHERE id = 'a1000000-0000-0000-0000-000000000003';
UPDATE public.programs SET program_name = 'Gyantantra', program_code = 'GT-01', program_type = 'GYANTANTRA' WHERE id = 'a1000000-0000-0000-0000-000000000004';
