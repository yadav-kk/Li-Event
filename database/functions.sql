-- Database Functions and Stored Procedures for Literacy India Event Portal

-- 1. Automatic updated_at timestamp setter
create or replace function public.update_updated_at_column()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

-- 2. Criteria score boundary checker trigger
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

-- 3. Automatically recalculate total score from criteria scores
create or replace function public.recalculate_score_total()
returns trigger as $$
declare
    v_score_id uuid;
    v_total numeric(5,2);
    v_assessment_id uuid;
    v_max_marks numeric(5,2);
begin
    v_score_id := coalesce(new.score_id, old.score_id);

    -- Calculate current sum of criteria scores
    select coalesce(sum(score), 0) into v_total
    from public.criteria_scores
    where score_id = v_score_id;

    -- Fetch parent assessment info to check bounds
    select s.assessment_id, a.max_marks into v_assessment_id, v_max_marks
    from public.assessment_scores s
    join public.event_assessments a on s.assessment_id = a.id
    where s.id = v_score_id;

    if v_total > v_max_marks then
        raise exception 'Total score % exceeds assessment maximum marks %', v_total, v_max_marks;
    end if;

    -- Update parent total score
    update public.assessment_scores
    set total_score = v_total, updated_at = now()
    where id = v_score_id;

    return new;
end;
$$ language plpgsql;

-- 4. Audit Log trigger function to track table audits automatically
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

-- 5. Advancement rule engine trigger
create or replace function public.calculate_stage_advancement(p_stage_id uuid)
returns json as $$
declare
    v_rule_id text;
    v_rule_val integer;
    v_participant record;
    v_count integer := 0;
begin
    -- Fetch stage advancement rules
    select advancement_rule_id, advancement_rule_value into v_rule_id, v_rule_val
    from public.event_stages
    where id = p_stage_id;

    if v_rule_id = 'TOP_N_PER_CENTRE' then
        -- Rank students within each centre
        with ranked_students as (
            select 
                sp.id as stage_participant_id,
                ep.student_id,
                st.centre_id,
                sum(sc.total_score) as total_stage_score,
                row_number() over (
                    partition by st.centre_id 
                    order by sum(sc.total_score) desc, 
                             -- Tie-breaking: Reading, then Writing, then Spelling
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
        -- Rank students across all centres
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
