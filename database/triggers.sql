-- Database Triggers binding function actions to operations

-- 1. Sync Supabase Auth User to Profiles
do $$
begin
    if exists (select 1 from pg_namespace where nspname = 'auth') then
        drop trigger if exists on_auth_user_created on auth.users;
        create trigger on_auth_user_created
            after insert on auth.users
            for each row execute procedure public.handle_new_user();
    end if;
end $$;

-- 2. updated_at timestamp triggers
create trigger set_updated_at_centres before update on public.centres
    for each row execute procedure public.update_updated_at_column();

create trigger set_updated_at_profiles before update on public.profiles
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

-- 3. Criteria Score limits check
create trigger check_criteria_score_limit before insert or update on public.criteria_scores
    for each row execute procedure public.validate_criteria_score_limit();

-- 4. Calculate total score sums on criteria changes
create trigger update_score_total after insert or update or delete on public.criteria_scores
    for each row execute procedure public.recalculate_score_total();

-- 5. Audit Logging Bindings
create trigger audit_events after insert or update or delete on public.events
    for each row execute procedure public.audit_table_action();

create trigger audit_scores after insert or update or delete on public.assessment_scores
    for each row execute procedure public.audit_table_action();

create trigger audit_students after insert or update or delete on public.students
    for each row execute procedure public.audit_table_action();
