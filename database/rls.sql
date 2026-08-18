-- Database Row Level Security (RLS) Policies for Literacy India Event Portal

-- 1. Helper functions to avoid repeating code and query parameters
create or replace function public.has_role(p_role text)
returns boolean as $$
begin
    return exists (
        select 1 from public.users
        where id::text = auth.uid()::text and role = p_role
    );
end;
$$ language plpgsql security definer;

create or replace function public.is_admin()
returns boolean as $$
begin
    return public.has_role('super_admin') or public.has_role('prog_admin');
end;
$$ language plpgsql security definer;

create or replace function public.get_user_centre()
returns uuid as $$
declare
    v_centre_id uuid;
begin
    select centre_id into v_centre_id
    from public.users
    where id::text = auth.uid()::text;
    return v_centre_id;
end;
$$ language plpgsql security definer;

-- 2. Enable RLS on all tables
alter table public.users enable row level security;
alter table public.centres enable row level security;
alter table public.schools enable row level security;
alter table public.batches enable row level security;
alter table public.students enable row level security;
alter table public.events enable row level security;
alter table public.event_stages enable row level security;
alter table public.event_assessments enable row level security;
alter table public.assessment_criteria enable row level security;
alter table public.event_participants enable row level security;
alter table public.stage_participants enable row level security;
alter table public.assessment_assignments enable row level security;
alter table public.assessment_scores enable row level security;
alter table public.criteria_scores enable row level security;
alter table public.evidence enable row level security;
alter table public.audit_logs enable row level security;

-- 3. Define Security Policies

-- Users table policies (handles profile metadata)
create policy "Allow users to read all user profiles" on public.users
    for select using (auth.role() = 'authenticated');

create policy "Allow users to update own profile" on public.users
    for update using (auth.uid()::text = id::text);

create policy "Admins can manage user profiles" on public.users
    for all using (public.is_admin());

-- Centres table policies
create policy "Allow all users to select centres" on public.centres
    for select using (auth.role() = 'authenticated');

create policy "Admins can manage centres" on public.centres
    for all using (public.is_admin());

-- Schools table policies
create policy "Allow all users to select schools" on public.schools
    for select using (auth.role() = 'authenticated');

create policy "Admins can manage schools" on public.schools
    for all using (public.is_admin());

-- Batches table policies
create policy "Allow all users to select batches" on public.batches
    for select using (auth.role() = 'authenticated');

create policy "Admins can manage batches" on public.batches
    for all using (public.is_admin());

-- Students table policies
create policy "Allow read access to students" on public.students
    for select using (auth.role() = 'authenticated');

create policy "Admins can manage students" on public.students
    for all using (public.is_admin());

create policy "Centre In-Charge can insert student" on public.students
    for insert with check (
        public.has_role('centre_incharge') and centre_id::text = public.get_user_centre()::text
    );

create policy "Centre In-Charge can update student" on public.students
    for update using (
        public.has_role('centre_incharge') and centre_id::text = public.get_user_centre()::text
    );

-- Events / Stages / Assessments / Criteria table policies
create policy "Allow read access to events" on public.events
    for select using (auth.role() = 'authenticated');

create policy "Admins can manage events" on public.events
    for all using (public.is_admin());

create policy "Allow read access to event stages" on public.event_stages
    for select using (auth.role() = 'authenticated');

create policy "Admins can manage event stages" on public.event_stages
    for all using (public.is_admin());

create policy "Allow read access to event assessments" on public.event_assessments
    for select using (auth.role() = 'authenticated');

create policy "Admins can manage event assessments" on public.event_assessments
    for all using (public.is_admin());

create policy "Allow read access to criteria" on public.assessment_criteria
    for select using (auth.role() = 'authenticated');

create policy "Admins can manage criteria" on public.assessment_criteria
    for all using (public.is_admin());

-- Event Participants policies
create policy "Allow read access to event participants" on public.event_participants
    for select using (auth.role() = 'authenticated');

create policy "Admins can manage event participants" on public.event_participants
    for all using (public.is_admin());

create policy "Centre In-Charge can register event participants" on public.event_participants
    for insert with check (
        public.has_role('centre_incharge') and exists (
            select 1 from public.students s
            where s.id::text = student_id::text and s.centre_id::text = public.get_user_centre()::text
        )
    );

create policy "Centre In-Charge can update event participants" on public.event_participants
    for update using (
        public.has_role('centre_incharge') and exists (
            select 1 from public.students s
            where s.id::text = student_id::text and s.centre_id::text = public.get_user_centre()::text
        )
    );

-- Stage Participants policies
create policy "Allow read access to stage participants" on public.stage_participants
    for select using (auth.role() = 'authenticated');

create policy "Admins can manage stage participants" on public.stage_participants
    for all using (public.is_admin());

-- Judge Assignments policies
create policy "Allow read access to assignments" on public.assessment_assignments
    for select using (auth.role() = 'authenticated');

create policy "Admins can manage assignments" on public.assessment_assignments
    for all using (public.is_admin());

-- Scores policies
create policy "Allow read access to scores" on public.assessment_scores
    for select using (auth.role() = 'authenticated');

create policy "Admins can manage scores" on public.assessment_scores
    for all using (public.is_admin());

create policy "Judges can write own scores" on public.assessment_scores
    for all using (
        public.has_role('judge') and judge_id::text = auth.uid()::text and status in ('DRAFT', 'SUBMITTED')
    );

-- Criteria Scores policies
create policy "Allow read access to criteria scores" on public.criteria_scores
    for select using (auth.role() = 'authenticated');

create policy "Admins can manage criteria scores" on public.criteria_scores
    for all using (public.is_admin());

create policy "Judges can write criteria scores" on public.criteria_scores
    for all using (
        exists (
            select 1 from public.assessment_scores s
            where s.id::text = score_id::text and s.judge_id::text = auth.uid()::text and s.status in ('DRAFT', 'SUBMITTED')
        )
    );

-- Evidence policies
create policy "Allow read access to evidence" on public.evidence
    for select using (auth.role() = 'authenticated');

create policy "Admins can manage evidence" on public.evidence
    for all using (public.is_admin());

create policy "Centre In-Charge can upload evidence" on public.evidence
    for insert with check (
        public.has_role('centre_incharge') and centre_id::text = public.get_user_centre()::text
    );

-- Audit logs policies
create policy "Admins can read audit logs" on public.audit_logs
    for select using (public.is_admin());
