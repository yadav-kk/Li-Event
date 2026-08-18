-- =====================================================================
-- LITERACY INDIA EVENT PORTAL - COMPLETE DATABASE SETUP & SEED SCRIPT
-- Run this entire script ONCE in your Supabase SQL Editor.
-- =====================================================================

-- 1. CLEAN & RESET SCHEMA
drop schema if exists public cascade;
create schema public;

-- 2. RESTORE SCHEMA PERMISSIONS FOR SUPABASE API ROLES
grant usage on schema public to postgres, anon, authenticated, service_role;
grant all privileges on all tables in schema public to postgres, anon, authenticated, service_role;
grant all privileges on all sequences in schema public to postgres, anon, authenticated, service_role;
grant all privileges on all functions in schema public to postgres, anon, authenticated, service_role;
alter default privileges in schema public grant all on tables to postgres, anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to postgres, anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to postgres, anon, authenticated, service_role;

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- =====================================================================
-- 3. SCHEMA TABLES DEFINITION
-- =====================================================================

-- Centres table
create table public.centres (
    id uuid primary key default gen_random_uuid(),
    centre_code text unique not null,
    centre_name text not null,
    district text,
    state text,
    address text,
    centre_incharge_id uuid, -- Reference added later to avoid circular dependency
    coordinator_id uuid, -- Reference added later
    status text default 'active' check (status in ('active', 'inactive')),
    created_at timestamp with time zone default now() not null,
    updated_at timestamp with time zone default now() not null
);

-- Users table (stores user metadata and password directly, bypassing auth.users)
create table public.users (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    email text unique not null,
    password text not null,
    mobile text,
    centre_id uuid references public.centres(id) on delete set null,
    status text default 'active' check (status in ('active', 'inactive')),
    created_at timestamp with time zone default now() not null,
    updated_at timestamp with time zone default now() not null
);

-- Add foreign keys to centres referencing users
alter table public.centres add constraint fk_centres_incharge foreign key (centre_incharge_id) references public.users(id) on delete set null;
alter table public.centres add constraint fk_centres_coordinator foreign key (coordinator_id) references public.users(id) on delete set null;

-- User Roles mapping table
create table public.user_roles (
    user_id uuid references public.users(id) on delete cascade not null,
    role_id text not null check (role_id in ('super_admin', 'prog_admin', 'centre_incharge', 'judge', 'academic_lead', 'final_judge', 'coordinator', 'management')),
    primary key (user_id, role_id)
);

-- Schools table
create table public.schools (
    id uuid primary key default gen_random_uuid(),
    school_name text not null,
    school_code text unique not null,
    centre_id uuid references public.centres(id) on delete cascade not null,
    school_type text default 'OTHER' check (school_type in ('GYANTANTRA', 'GOVERNMENT', 'NGO', 'COMMUNITY', 'OTHER')),
    address text,
    status text default 'active' check (status in ('active', 'inactive')),
    created_at timestamp with time zone default now() not null,
    updated_at timestamp with time zone default now() not null
);

-- Batches table
create table public.batches (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    academic_year text not null,
    centre_id uuid references public.centres(id) on delete cascade not null,
    created_at timestamp with time zone default now() not null
);

-- Students master table
create table public.students (
    id uuid primary key default gen_random_uuid(),
    student_id text unique not null, -- format GT-LIT-YYYY-XXXXXX
    name text not null,
    gender text check (gender in ('M', 'F', 'Other')),
    date_of_birth date,
    class text not null,
    centre_id uuid references public.centres(id) on delete set null,
    school_id uuid references public.schools(id) on delete set null,
    batch_id uuid references public.batches(id) on delete set null,
    guardian_name text,
    guardian_mobile text,
    language text,
    photo_path text,
    status text default 'active' check (status in ('active', 'inactive')),
    created_at timestamp with time zone default now() not null,
    updated_at timestamp with time zone default now() not null
);

-- Events table
create table public.events (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    event_code text unique not null,
    event_type text default 'Competition',
    academic_year text not null,
    class text not null,
    description text,
    objective text,
    start_date date,
    end_date date,
    registration_start date,
    registration_end date,
    venue text,
    status text default 'DRAFT' check (status in ('DRAFT', 'PLANNING', 'REGISTRATION_OPEN', 'REGISTRATION_CLOSED', 'IN_PROGRESS', 'RESULT_PROCESSING', 'COMPLETED', 'ARCHIVED', 'CANCELLED')),
    event_owner uuid references public.users(id) on delete set null,
    created_at timestamp with time zone default now() not null,
    updated_at timestamp with time zone default now() not null
);

-- Event Centres mapping table
create table public.event_centres (
    event_id uuid references public.events(id) on delete cascade not null,
    centre_id uuid references public.centres(id) on delete cascade not null,
    primary key (event_id, centre_id)
);

-- Event Stages (Phases) table
create table public.event_stages (
    id uuid primary key default gen_random_uuid(),
    event_id uuid references public.events(id) on delete cascade not null,
    name text not null,
    description text,
    sequence integer not null,
    start_datetime timestamp with time zone,
    end_datetime timestamp with time zone,
    configuration_deadline timestamp with time zone,
    venue text,
    status text default 'DRAFT' check (status in ('DRAFT', 'SCHEDULED', 'OPEN', 'IN_PROGRESS', 'COMPLETED', 'LOCKED', 'CANCELLED')),
    participant_rule text,
    advancement_rule_id text default 'ALL_PARTICIPANTS' check (advancement_rule_id in ('TOP_N_OVERALL', 'TOP_N_PER_CENTRE', 'PERCENTAGE_THRESHOLD', 'SCORE_THRESHOLD', 'MANUAL_SELECTION', 'ALL_PARTICIPANTS')),
    advancement_rule_value integer,
    created_at timestamp with time zone default now() not null,
    updated_at timestamp with time zone default now() not null,
    unique (event_id, sequence)
);

-- Event Assessments (Stages) table
create table public.event_assessments (
    id uuid primary key default gen_random_uuid(),
    stage_id uuid references public.event_stages(id) on delete cascade not null,
    name text not null,
    description text,
    assessment_type text default 'SCORE' check (assessment_type in ('SCORE', 'YES_NO', 'RATING', 'ATTENDANCE', 'TEXT', 'FILE')),
    sequence integer not null,
    max_marks numeric(5,2) not null check (max_marks >= 0),
    start_datetime timestamp with time zone,
    end_datetime timestamp with time zone,
    configuration_deadline timestamp with time zone,
    status text default 'DRAFT' check (status in ('DRAFT', 'ACTIVE', 'COMPLETED', 'LOCKED')),
    required boolean default true,
    judge_assignment_mode text default 'ALL_JUDGES',
    created_at timestamp with time zone default now() not null,
    updated_at timestamp with time zone default now() not null,
    unique (stage_id, sequence)
);

-- Assessment Criteria table
create table public.assessment_criteria (
    id uuid primary key default gen_random_uuid(),
    assessment_id uuid references public.event_assessments(id) on delete cascade not null,
    name text not null,
    description text,
    max_marks numeric(5,2) not null check (max_marks >= 0),
    sequence integer not null,
    required boolean default true,
    created_at timestamp with time zone default now() not null,
    unique (assessment_id, name)
);

-- Event Participants table
create table public.event_participants (
    id uuid primary key default gen_random_uuid(),
    event_id uuid references public.events(id) on delete cascade not null,
    student_id uuid references public.students(id) on delete cascade not null,
    registration_number text unique,
    registration_date date default current_date not null,
    registration_status text default 'DRAFT' check (registration_status in ('DRAFT', 'SUBMITTED', 'UNDER_REVIEW', 'APPROVED', 'REJECTED', 'LOCKED', 'CANCELLED')),
    eligibility_status text default 'ELIGIBLE' check (eligibility_status in ('ELIGIBLE', 'INELIGIBLE')),
    attendance_status text default 'ABSENT' check (attendance_status in ('PRESENT', 'ABSENT', 'LATE', 'EXCUSED')),
    current_stage_id uuid references public.event_stages(id) on delete set null,
    finalist_status boolean default false,
    created_at timestamp with time zone default now() not null,
    updated_at timestamp with time zone default now() not null,
    unique (event_id, student_id)
);

-- Stage Participants table
create table public.stage_participants (
    id uuid primary key default gen_random_uuid(),
    stage_id uuid references public.event_stages(id) on delete cascade not null,
    participant_id uuid references public.event_participants(id) on delete cascade not null,
    qualification_source text,
    stage_1_score numeric(5,2),
    stage_1_rank integer,
    qualification_status text default 'PENDING' check (qualification_status in ('PENDING', 'QUALIFIED', 'DISQUALIFIED', 'CONFIRMED')),
    availability text,
    transport_required boolean default false,
    attendance text default 'ABSENT' check (attendance in ('PRESENT', 'ABSENT', 'LATE', 'EXCUSED')),
    created_at timestamp with time zone default now() not null,
    unique (stage_id, participant_id)
);

-- Judge Assignments mapping table
create table public.assessment_assignments (
    id uuid primary key default gen_random_uuid(),
    assessment_id uuid references public.event_assessments(id) on delete cascade not null,
    judge_id uuid references public.users(id) on delete cascade not null,
    centre_id uuid references public.centres(id) on delete cascade,
    participant_id uuid references public.event_participants(id) on delete cascade,
    created_at timestamp with time zone default now() not null
);

-- Assessment Scores table
create table public.assessment_scores (
    id uuid primary key default gen_random_uuid(),
    assessment_id uuid references public.event_assessments(id) on delete cascade not null,
    stage_participant_id uuid references public.stage_participants(id) on delete cascade not null,
    judge_id uuid references public.users(id) on delete set null not null,
    total_score numeric(5,2) not null check (total_score >= 0),
    remarks text,
    status text default 'DRAFT' check (status in ('DRAFT', 'SUBMITTED', 'UNDER_REVIEW', 'VERIFIED', 'REJECTED', 'LOCKED')),
    verified_by uuid references public.users(id) on delete set null,
    verified_at timestamp with time zone,
    locked_at timestamp with time zone,
    created_at timestamp with time zone default now() not null,
    updated_at timestamp with time zone default now() not null,
    unique (assessment_id, stage_participant_id, judge_id)
);

-- Criteria Scores
create table public.criteria_scores (
    id uuid primary key default gen_random_uuid(),
    score_id uuid references public.assessment_scores(id) on delete cascade not null,
    criteria_id uuid references public.assessment_criteria(id) on delete cascade not null,
    score numeric(5,2) not null check (score >= 0),
    created_at timestamp with time zone default now() not null,
    unique (score_id, criteria_id)
);

-- Evidence table
create table public.evidence (
    id uuid primary key default gen_random_uuid(),
    event_id uuid references public.events(id) on delete cascade not null,
    stage_id uuid references public.event_stages(id) on delete cascade,
    centre_id uuid references public.centres(id) on delete cascade,
    participant_id uuid references public.event_participants(id) on delete cascade,
    evidence_type text not null,
    file_name text not null,
    storage_path text not null,
    uploaded_by uuid references public.users(id) on delete set null not null,
    verification_status text default 'PENDING' check (verification_status in ('PENDING', 'VERIFIED', 'REJECTED')),
    created_at timestamp with time zone default now() not null
);

-- Audit logs
create table public.audit_logs (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references public.users(id) on delete set null,
    action text not null,
    entity_type text not null,
    entity_id text,
    old_data jsonb,
    new_data jsonb,
    reason text,
    created_at timestamp with time zone default now() not null
);

-- Version history
create table public.version_history (
    id uuid primary key default gen_random_uuid(),
    entity_type text not null,
    entity_id uuid not null,
    version integer not null,
    changed_by uuid references public.users(id) on delete set null,
    changed_at timestamp with time zone default now() not null,
    change_reason text,
    old_value jsonb,
    new_value jsonb
);

-- Indices
create index idx_students_centre on public.students(centre_id);
create index idx_students_student_id on public.students(student_id);
create index idx_event_stages_event on public.event_stages(event_id);
create index idx_event_assessments_stage on public.event_assessments(stage_id);
create index idx_criteria_assessment on public.assessment_criteria(assessment_id);
create index idx_participants_event on public.event_participants(event_id);
create index idx_participants_student on public.event_participants(student_id);
create index idx_stage_participants_stage on public.stage_participants(stage_id);
create index idx_scores_participant on public.assessment_scores(stage_participant_id);
create index idx_criteria_scores_parent on public.criteria_scores(score_id);
create index idx_evidence_event on public.evidence(event_id);
create index idx_audit_user on public.audit_logs(user_id);

-- =====================================================================
-- 4. DATABASE PROCEDURES & TRIGGERS
-- =====================================================================

create or replace function public.update_updated_at_column()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

create or replace function public.validate_criteria_score_limit()
returns trigger as $$
declare
    v_max_marks numeric(5,2);
    v_name text;
begin
    select max_marks, name into v_max_marks, v_name
    from public.assessment_criteria
    where id = new.criteria_id;

    if new.score < 0 or new.score > v_max_marks then
        raise exception 'Invalid score % for criteria "%". Must be between 0 and %.', new.score, v_name, v_max_marks;
    end if;

    return new;
end;
$$ language plpgsql;

create or replace function public.recalculate_score_total()
returns trigger as $$
declare
    v_score_id uuid;
    v_total numeric(5,2);
    v_assessment_id uuid;
    v_max_marks numeric(5,2);
begin
    v_score_id := coalesce(new.score_id, old.score_id);

    select coalesce(sum(score), 0) into v_total
    from public.criteria_scores
    where score_id = v_score_id;

    select s.assessment_id, a.max_marks into v_assessment_id, v_max_marks
    from public.assessment_scores s
    join public.event_assessments a on s.assessment_id = a.id
    where s.id = v_score_id;

    if v_total > v_max_marks then
        raise exception 'Total score % exceeds assessment maximum marks %', v_total, v_max_marks;
    end if;

    update public.assessment_scores
    set total_score = v_total, updated_at = now()
    where id = v_score_id;

    return new;
end;
$$ language plpgsql;

create or replace function public.audit_table_action()
returns trigger as $$
declare
    v_user_id uuid := null;
    v_action text;
    v_entity_type text;
    v_entity_id text;
    v_old jsonb := null;
    v_new jsonb := null;
begin
    v_action := tg_op;
    v_entity_type := tg_table_name::text;

    if tg_op = 'INSERT' then
        v_entity_id := new.id::text;
        v_new := to_jsonb(new);
    elsif tg_op = 'UPDATE' then
        v_entity_id := old.id::text;
        v_old := to_jsonb(old);
        v_new := to_jsonb(new);
    elsif tg_op = 'DELETE' then
        v_entity_id := old.id::text;
        v_old := to_jsonb(old);
    end if;

    insert into public.audit_logs (user_id, action, entity_type, entity_id, old_data, new_data)
    values (v_user_id, v_action, v_entity_type, v_entity_id, v_old, v_new);

    return new;
end;
$$ language plpgsql security definer;

create or replace function public.calculate_stage_advancement(p_stage_id uuid)
returns json as $$
declare
    v_rule_id text;
    v_rule_val integer;
    v_participant record;
    v_count integer := 0;
begin
    select advancement_rule_id, advancement_rule_value into v_rule_id, v_rule_val
    from public.event_stages
    where id = p_stage_id;

    if v_rule_id = 'TOP_N_PER_CENTRE' then
        with ranked_students as (
            select 
                sp.id as stage_participant_id,
                ep.student_id,
                st.centre_id,
                sum(sc.total_score) as total_stage_score,
                row_number() over (
                    partition by st.centre_id 
                    order by sum(sc.total_score) desc, 
                             sum(case when a.name ilike '%Reading%' then sc.total_score else 0 end) desc,
                             sum(case when a.name ilike '%Writing%' then sc.total_score else 0 end) desc,
                             sum(case when a.name ilike '%Spelling%' then sc.total_score else 0 end) desc
                ) as rank_in_centre
            from public.stage_participants sp
            join public.event_participants ep on sp.participant_id = ep.id
            join public.students st on ep.student_id = st.id
            left join public.assessment_scores sc on sc.stage_participant_id = sp.id
            left join public.event_assessments a on sc.assessment_id = a.id
            where sp.stage_id = p_stage_id
            group by sp.id, ep.student_id, st.centre_id
        )
        update public.stage_participants sp
        set stage_1_score = r.total_stage_score,
            stage_1_rank = r.rank_in_centre,
            qualification_status = case when r.rank_in_centre <= v_rule_val then 'QUALIFIED' else 'DISQUALIFIED' end
        from ranked_students r
        where sp.id = r.stage_participant_id;

    elsif v_rule_id = 'TOP_N_OVERALL' then
        with ranked_students as (
            select 
                sp.id as stage_participant_id,
                sum(sc.total_score) as total_stage_score,
                row_number() over (
                    order by sum(sc.total_score) desc
                ) as rank_overall
            from public.stage_participants sp
            left join public.assessment_scores sc on sc.stage_participant_id = sp.id
            where sp.stage_id = p_stage_id
            group by sp.id
        )
        update public.stage_participants sp
        set stage_1_score = r.total_stage_score,
            stage_1_rank = r.rank_overall,
            qualification_status = case when r.rank_overall <= v_rule_val then 'QUALIFIED' else 'DISQUALIFIED' end
        from ranked_students r
        where sp.id = r.stage_participant_id;
        
    elsif v_rule_id = 'ALL_PARTICIPANTS' then
        update public.stage_participants
        set qualification_status = 'QUALIFIED'
        where stage_id = p_stage_id;
    end if;

    return json_build_object('success', true, 'message', 'Advancement rules processed.');
end;
$$ language plpgsql security definer;

-- Trigger Attachments
create trigger set_updated_at_centres before update on public.centres
    for each row execute procedure public.update_updated_at_column();
create trigger set_updated_at_users before update on public.users
    for each row execute procedure public.update_updated_at_column();
create trigger set_updated_at_students before update on public.students
    for each row execute procedure public.update_updated_at_column();
create trigger set_updated_at_events before update on public.events
    for each row execute procedure public.update_updated_at_column();
create trigger set_updated_at_event_stages before update on public.event_stages
    for each row execute procedure public.update_updated_at_column();
create trigger set_updated_at_event_assessments before update on public.event_assessments
    for each row execute procedure public.update_updated_at_column();
create trigger set_updated_at_event_participants before update on public.event_participants
    for each row execute procedure public.update_updated_at_column();
create trigger set_updated_at_assessment_scores before update on public.assessment_scores
    for each row execute procedure public.update_updated_at_column();

create trigger check_criteria_score_limit before insert or update on public.criteria_scores
    for each row execute procedure public.validate_criteria_score_limit();
create trigger update_score_total after insert or update or delete on public.criteria_scores
    for each row execute procedure public.recalculate_score_total();

create trigger audit_events after insert or update or delete on public.events
    for each row execute procedure public.audit_table_action();
create trigger audit_scores after insert or update or delete on public.assessment_scores
    for each row execute procedure public.audit_table_action();
create trigger audit_students after insert or update or delete on public.students
    for each row execute procedure public.audit_table_action();

-- Disable RLS
alter table public.users disable row level security;
alter table public.user_roles disable row level security;
alter table public.centres disable row level security;
alter table public.schools disable row level security;
alter table public.batches disable row level security;
alter table public.students disable row level security;
alter table public.events disable row level security;
alter table public.event_stages disable row level security;
alter table public.event_assessments disable row level security;
alter table public.assessment_criteria disable row level security;
alter table public.event_participants disable row level security;
alter table public.stage_participants disable row level security;
alter table public.assessment_assignments disable row level security;
alter table public.assessment_scores disable row level security;
alter table public.criteria_scores disable row level security;
alter table public.evidence disable row level security;
alter table public.audit_logs disable row level security;
alter table public.version_history disable row level security;

-- =====================================================================
-- 5. SEED INITIAL BASELINE DATA
-- =====================================================================

-- 1. Create Centres
insert into public.centres (id, centre_code, centre_name, district, state, address, status) values
('c1000000-0000-0000-0000-000000000001', 'DL-01', 'Delhi Main Centre', 'South West Delhi', 'Delhi', 'Palam Vihar, Delhi', 'active'),
('c1000000-0000-0000-0000-000000000002', 'UP-01', 'Noida Extension Centre', 'Gautam Buddha Nagar', 'Uttar Pradesh', 'Sector 62, Noida', 'active'),
('c1000000-0000-0000-0000-000000000003', 'HR-01', 'Gurugram Sector 45 Centre', 'Gurugram', 'Haryana', 'Sector 45, Gurugram', 'active');

-- 2. Create Users
insert into public.users (id, name, email, password, mobile, centre_id, status) values
('10000000-0000-0000-0000-000000000001', 'System Administrator', 'admin@test.com', 'password123', '9876543200', null, 'active'),
('10000000-0000-0000-0000-000000000002', 'Delhi Assessor', 'judge@test.com', 'password123', '9876543201', 'c1000000-0000-0000-0000-000000000001', 'active'),
('10000000-0000-0000-0000-000000000003', 'Noida In-Charge', 'noida@test.com', 'password123', '9876543202', 'c1000000-0000-0000-0000-000000000002', 'active');

-- 3. Map User Roles
insert into public.user_roles (user_id, role_id) values
('10000000-0000-0000-0000-000000000001', 'super_admin'),
('10000000-0000-0000-0000-000000000002', 'judge'),
('10000000-0000-0000-0000-000000000003', 'centre_incharge');

update public.centres set centre_incharge_id = '10000000-0000-0000-0000-000000000003' where id = 'c1000000-0000-0000-0000-000000000002';

-- 4. Create Schools
insert into public.schools (id, school_name, school_code, centre_id, school_type, address, status) values
('a1000000-0000-0000-0000-000000000001', 'GyanTantra DL Primary', 'GT-DL-01', 'c1000000-0000-0000-0000-000000000001', 'GYANTANTRA', 'Palam Vihar', 'active'),
('a1000000-0000-0000-0000-000000000002', 'Govt Boys School Delhi', 'GB-DL-02', 'c1000000-0000-0000-0000-000000000001', 'GOVERNMENT', 'Dwarka Sector 10', 'active'),
('a1000000-0000-0000-0000-000000000003', 'GyanTantra Noida Primary', 'GT-UP-01', 'c1000000-0000-0000-0000-000000000002', 'GYANTANTRA', 'Sector 62', 'active'),
('a1000000-0000-0000-0000-000000000004', 'Govt Girls School Noida', 'GG-UP-02', 'c1000000-0000-0000-0000-000000000002', 'GOVERNMENT', 'Sector 12 Noida', 'active'),
('a1000000-0000-0000-0000-000000000005', 'GyanTantra Gurugram Primary', 'GT-HR-01', 'c1000000-0000-0000-0000-000000000003', 'GYANTANTRA', 'Sector 45', 'active');

-- 5. Create Batches
insert into public.batches (id, name, academic_year, centre_id) values
('b1000000-0000-0000-0000-000000000001', 'Batch 2026 Class V A', '2026', 'c1000000-0000-0000-0000-000000000001'),
('b1000000-0000-0000-0000-000000000002', 'Batch 2026 Class V B', '2026', 'c1000000-0000-0000-0000-000000000002'),
('b1000000-0000-0000-0000-000000000003', 'Batch 2026 Class V C', '2026', 'c1000000-0000-0000-0000-000000000003');

-- 6. Create Students
insert into public.students (id, student_id, name, gender, date_of_birth, class, centre_id, school_id, batch_id, guardian_name, guardian_mobile, language, status) values
-- Delhi Students
('d1000000-0000-0000-0000-000000000001', 'GT-LIT-2026-000001', 'Aarav Kumar', 'M', '2016-05-12', 'V', 'c1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000001', 'Ramesh Kumar', '9876543210', 'Hindi', 'active'),
('d1000000-0000-0000-0000-000000000002', 'GT-LIT-2026-000002', 'Aditi Sharma', 'F', '2016-08-22', 'V', 'c1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000001', 'Sunita Sharma', '9876543211', 'Hindi', 'active'),
('d1000000-0000-0000-0000-000000000003', 'GT-LIT-2026-000003', 'Amit Patel', 'M', '2016-01-30', 'V', 'c1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000001', 'Vijay Patel', '9876543212', 'Gujarati', 'active'),
('d1000000-0000-0000-0000-000000000004', 'GT-LIT-2026-000004', 'Ananya Gupta', 'F', '2016-11-15', 'V', 'c1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000001', 'Anil Gupta', '9876543213', 'Hindi', 'active'),
('d1000000-0000-0000-0000-000000000005', 'GT-LIT-2026-000005', 'Arjun Singh', 'M', '2016-03-05', 'V', 'c1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000001', 'b1000000-0000-0000-0000-000000000001', 'Bikram Singh', '9876543214', 'Punjabi', 'active'),
('d1000000-0000-0000-0000-000000000006', 'GT-LIT-2026-000006', 'Divya Verma', 'F', '2016-09-19', 'V', 'c1000000-0000-0000-0000-000000000001', 'a1000000-0000-0000-0000-000000000002', 'b1000000-0000-0000-0000-000000000001', 'Suresh Verma', '9876543215', 'Hindi', 'active'),
-- Noida Students
('e1000000-0000-0000-0000-000000000001', 'GT-LIT-2026-000007', 'Ishan Choudhary', 'M', '2016-04-18', 'V', 'c1000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000003', 'b1000000-0000-0000-0000-000000000002', 'Rajesh Choudhary', '9876543216', 'Hindi', 'active'),
('e1000000-0000-0000-0000-000000000002', 'GT-LIT-2026-000008', 'Kavya Nair', 'F', '2016-07-28', 'V', 'c1000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000003', 'b1000000-0000-0000-0000-000000000002', 'Mohan Nair', '9876543217', 'Malayalam', 'active'),
('e1000000-0000-0000-0000-000000000003', 'GT-LIT-2026-000009', 'Nikhil Yadav', 'M', '2016-12-05', 'V', 'c1000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000004', 'b1000000-0000-0000-0000-000000000002', 'Satish Yadav', '9876543218', 'Hindi', 'active'),
('e1000000-0000-0000-0000-000000000004', 'GT-LIT-2026-000010', 'Prisha Rao', 'F', '2016-02-14', 'V', 'c1000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000004', 'b1000000-0000-0000-0000-000000000002', 'Krishna Rao', '9876543219', 'Telugu', 'active'),
('e1000000-0000-0000-0000-000000000005', 'GT-LIT-2026-000011', 'Rahul Mishra', 'M', '2016-06-25', 'V', 'c1000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000003', 'b1000000-0000-0000-0000-000000000002', 'Gopal Mishra', '9876543220', 'Hindi', 'active'),
('e1000000-0000-0000-0000-000000000006', 'GT-LIT-2026-000012', 'Sanya Sen', 'F', '2016-10-31', 'V', 'c1000000-0000-0000-0000-000000000002', 'a1000000-0000-0000-0000-000000000004', 'b1000000-0000-0000-0000-000000000002', 'Pradip Sen', '9876543221', 'Bengali', 'active'),
-- Gurugram Students
('f1000000-0000-0000-0000-000000000001', 'GT-LIT-2026-000013', 'Shreya Joshi', 'F', '2016-05-02', 'V', 'c1000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000005', 'b1000000-0000-0000-0000-000000000003', 'Dinesh Joshi', '9876543222', 'Hindi', 'active'),
('f1000000-0000-0000-0000-000000000002', 'GT-LIT-2026-000014', 'Tejas Patil', 'M', '2016-08-08', 'V', 'c1000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000005', 'b1000000-0000-0000-0000-000000000003', 'Sanjay Patil', '9876543223', 'Marathi', 'active'),
('f1000000-0000-0000-0000-000000000003', 'GT-LIT-2026-000015', 'Varun Reddy', 'M', '2016-11-23', 'V', 'c1000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000005', 'b1000000-0000-0000-0000-000000000003', 'Bhaskar Reddy', '9876543224', 'Telugu', 'active'),
('f1000000-0000-0000-0000-000000000004', 'GT-LIT-2026-000016', 'Yash Wardhan', 'M', '2016-02-28', 'V', 'c1000000-0000-0000-0000-000000000003', 'a1000000-0000-0000-0000-000000000005', 'b1000000-0000-0000-0000-000000000003', 'Sukhdev Wardhan', '9876543225', 'Hindi', 'active');

-- 7. Create Event
insert into public.events (id, name, event_code, event_type, academic_year, class, description, objective, start_date, end_date, registration_start, registration_end, venue, status) values
('e9000000-0000-0000-0000-000000000001', 'GyanTantra se Saksharta – Class V Literacy Challenge 2026', 'GT-LIT-2026', 'Competition', '2026', 'V', 'World Literacy Day Literacy Challenge event for Class V students.', 'Assess student proficiency in reading, writing and spelling skills.', '2026-09-02', '2026-09-08', '2026-08-15', '2026-08-30', 'Centres & Head Office', 'IN_PROGRESS');

-- Map Event to Centres
insert into public.event_centres (event_id, centre_id) values
('e9000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000001'), -- Delhi
('e9000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000002'), -- Noida
('e9000000-0000-0000-0000-000000000001', 'c1000000-0000-0000-0000-000000000003'); -- Gurugram

-- 8. Create Stages (Phases)
insert into public.event_stages (id, event_id, name, description, sequence, start_datetime, end_datetime, configuration_deadline, venue, status, participant_rule, advancement_rule_id, advancement_rule_value) values
('e1900000-0001-0000-0000-000000000001', 'e9000000-0000-0000-0000-000000000001', 'Stage 1: Centre Level Screening', 'Screening of students inside their local centres.', 1, '2026-09-02 09:00:00+05:30', '2026-09-04 18:00:00+05:30', '2026-09-01 23:59:59+05:30', 'Local Centres', 'OPEN', 'Class V eligible registered students', 'TOP_N_PER_CENTRE', 5),
('e1900000-0002-0000-0000-000000000002', 'e9000000-0000-0000-0000-000000000001', 'Stage 2: Head Office Literacy Championship', 'Final tournament for qualified centre winners.', 2, '2026-09-08 10:00:00+05:30', '2026-09-08 17:00:00+05:30', '2026-09-06 23:59:59+05:30', 'Head Office Auditorium', 'DRAFT', 'Top 5 students per centre from Stage 1', 'TOP_N_OVERALL', 3);

-- 9. Create Assessments (Stages)
insert into public.event_assessments (id, stage_id, name, description, assessment_type, sequence, max_marks, start_datetime, end_datetime, configuration_deadline, status, required, judge_assignment_mode) values
('ea900000-0001-0001-0000-000000000001', 'e1900000-0001-0000-0000-000000000001', 'Spelling', 'Spelling screening test (10 words, 2 sentences).', 'SCORE', 1, 20.00, '2026-09-02 10:00:00+05:30', '2026-09-02 12:00:00+05:30', '2026-09-01 23:59:00+05:30', 'ACTIVE', true, 'ALL_JUDGES'),
('ea900000-0001-0002-0000-000000000001', 'e1900000-0001-0000-0000-000000000001', 'Writing', 'Writing assessment evaluating creativity and grammar.', 'SCORE', 2, 20.00, '2026-09-03 10:00:00+05:30', '2026-09-03 12:00:00+05:30', '2026-09-02 23:59:00+05:30', 'ACTIVE', true, 'ALL_JUDGES'),
('ea900000-0001-0003-0000-000000000001', 'e1900000-0001-0000-0000-000000000001', 'Reading', 'Reading fluency and correct pronunciation evaluation.', 'SCORE', 3, 20.00, '2026-09-04 10:00:00+05:30', '2026-09-04 12:00:00+05:30', '2026-09-03 23:59:00+05:30', 'ACTIVE', true, 'ALL_JUDGES');

-- 10. Create Criteria
insert into public.assessment_criteria (id, assessment_id, name, description, max_marks, sequence, required) values
('ac900001-0001-0001-0000-000000000001', 'ea900000-0001-0001-0000-000000000001', '10 Words', 'Evaluation of spelling of 10 vocabulary words.', 10.00, 1, true),
('ac900001-0001-0002-0000-000000000001', 'ea900000-0001-0001-0000-000000000001', 'Sentence 1', 'Evaluation of sentence write-out 1.', 5.00, 2, true),
('ac900001-0001-0003-0000-000000000001', 'ea900000-0001-0001-0000-000000000001', 'Sentence 2', 'Evaluation of sentence write-out 2.', 5.00, 3, true),

('ac900001-0002-0001-0000-000000000001', 'ea900000-0001-0002-0000-000000000001', 'Content & Relevance', 'Relevance of written thoughts to theme.', 5.00, 1, true),
('ac900001-0002-0002-0000-000000000001', 'ea900000-0001-0002-0000-000000000001', 'Creativity & Ideas', 'Originality of expressions.', 5.00, 2, true),
('ac900001-0002-0003-0000-000000000001', 'ea900000-0001-0002-0000-000000000001', 'Sentence Formation & Grammar', 'Proper sentence syntax and grammar.', 4.00, 3, true),
('ac900001-0002-0004-0000-000000000001', 'ea900000-0001-0002-0000-000000000001', 'Vocabulary', 'Use of varied vocabulary.', 3.00, 4, true),
('ac900001-0002-0005-0000-000000000001', 'ea900000-0001-0002-0000-000000000001', 'Spelling & Punctuation', 'Accuracy of spelling & commas/periods.', 3.00, 5, true),

('ac900001-0003-0001-0000-000000000001', 'ea900000-0001-0003-0000-000000000001', 'Accuracy', 'Correct reading of text passages.', 8.00, 1, true),
('ac900001-0003-0002-0000-000000000001', 'ea900000-0001-0003-0000-000000000001', 'Fluency', 'Smoothness and speed of narration.', 5.00, 2, true),
('ac900001-0003-0003-0000-000000000001', 'ea900000-0001-0003-0000-000000000001', 'Pronunciation', 'Clear phonetic articulation of syllables.', 3.00, 3, true),
('ac900001-0003-0004-0000-000000000001', 'ea900000-0001-0003-0000-000000000001', 'Expression', 'Tonal dynamics reflecting meanings.', 2.00, 4, true),
('ac900001-0003-0005-0000-000000000001', 'ea900000-0001-0003-0000-000000000001', 'Confidence', 'Poise and posture during presentation.', 2.00, 5, true);

-- 11. Auto-Register students to the Event
insert into public.event_participants (id, event_id, student_id, registration_number, registration_status, eligibility_status, current_stage_id)
select 
    uuid_generate_v5('e9000000-0000-0000-0000-000000000001', id::text) as id,
    'e9000000-0000-0000-0000-000000000001' as event_id,
    id as student_id,
    replace(student_id, 'GT-LIT', 'REG') as registration_number,
    'APPROVED' as registration_status,
    'ELIGIBLE' as eligibility_status,
    'e1900000-0001-0000-0000-000000000001' as current_stage_id
from public.students;

-- 12. Register event participants to Stage 1
insert into public.stage_participants (id, stage_id, participant_id, qualification_status, attendance)
select 
    uuid_generate_v5('e1900000-0001-0000-0000-000000000001', id::text) as id,
    'e1900000-0001-0000-0000-000000000001' as stage_id,
    id as participant_id,
    'PENDING' as qualification_status,
    'PRESENT' as attendance
from public.event_participants;
