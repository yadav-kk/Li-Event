-- Literacy India Event & Assessment Management Portal Database Schema (Direct Custom Auth)

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- 1. Centres table
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

-- 2. Users table (stores user metadata and password directly, bypassing auth.users)
create table public.users (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    email text unique not null,
    password text not null, -- Plain text password for simplified mock portal login
    mobile text,
    centre_id uuid references public.centres(id) on delete set null,
    status text default 'active' check (status in ('active', 'inactive')),
    created_at timestamp with time zone default now() not null,
    updated_at timestamp with time zone default now() not null
);

-- Add foreign keys to centres referencing users
alter table public.centres add constraint fk_centres_incharge foreign key (centre_incharge_id) references public.users(id) on delete set null;
alter table public.centres add constraint fk_centres_coordinator foreign key (coordinator_id) references public.users(id) on delete set null;

-- 3. User Roles mapping table (restored for roles mapping)
create table public.user_roles (
    user_id uuid references public.users(id) on delete cascade not null,
    role_id text not null check (role_id in ('super_admin', 'prog_admin', 'centre_incharge', 'judge', 'academic_lead', 'final_judge', 'coordinator', 'management')),
    primary key (user_id, role_id)
);

-- User Centres mapping table (allows a user to belong to multiple centres)
create table public.user_centres (
    user_id uuid references public.users(id) on delete cascade not null,
    centre_id uuid references public.centres(id) on delete cascade not null,
    primary key (user_id, centre_id)
);

-- 4. Schools table
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

-- 5. Batches table
create table public.batches (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    academic_year text not null,
    centre_id uuid references public.centres(id) on delete cascade not null,
    created_at timestamp with time zone default now() not null
);

-- 6. Students master table
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

-- 7. Events table
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

-- 7.1. Event Centres mapping table
create table public.event_centres (
    event_id uuid references public.events(id) on delete cascade not null,
    centre_id uuid references public.centres(id) on delete cascade not null,
    primary key (event_id, centre_id)
);

-- 8. Event Stages table
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
    participant_rule text, -- Defines eligibility
    advancement_rule_id text default 'ALL_PARTICIPANTS' check (advancement_rule_id in ('TOP_N_OVERALL', 'TOP_N_PER_CENTRE', 'PERCENTAGE_THRESHOLD', 'SCORE_THRESHOLD', 'MANUAL_SELECTION', 'ALL_PARTICIPANTS')),
    advancement_rule_value integer, -- N or Score limit
    created_at timestamp with time zone default now() not null,
    updated_at timestamp with time zone default now() not null,
    unique (event_id, sequence)
);

-- 9. Event Assessments table
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

-- 10. Assessment Criteria table
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

-- 11. Event Participants table
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

-- 12. Stage Participants table
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

-- 13. Judge Assignments mapping table
create table public.assessment_assignments (
    id uuid primary key default gen_random_uuid(),
    assessment_id uuid references public.event_assessments(id) on delete cascade not null,
    judge_id uuid references public.users(id) on delete cascade not null,
    centre_id uuid references public.centres(id) on delete cascade,
    participant_id uuid references public.event_participants(id) on delete cascade,
    created_at timestamp with time zone default now() not null
);

-- 14. Assessment Scores table
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

-- 15. Criteria Scores (relational normalized subscores)
create table public.criteria_scores (
    id uuid primary key default gen_random_uuid(),
    score_id uuid references public.assessment_scores(id) on delete cascade not null,
    criteria_id uuid references public.assessment_criteria(id) on delete cascade not null,
    score numeric(5,2) not null check (score >= 0),
    created_at timestamp with time zone default now() not null,
    unique (score_id, criteria_id)
);

-- 16. Evidence table for attachments
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

-- 17. Audit logs for operations
create table public.audit_logs (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references public.users(id) on delete set null,
    action text not null, -- CREATE, UPDATE, DELETE, LOCK, UNLOCK, etc.
    entity_type text not null, -- EVENT, SCORE, STUDENT, etc.
    entity_id text,
    old_data jsonb,
    new_data jsonb,
    reason text,
    created_at timestamp with time zone default now() not null
);

-- 18. Version history for tracks
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

-- Standard index creations for optimized query routing
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
