-- SQL Script: Audit Logs and Tie-Breaking CMS Configuration
-- Run this in your Supabase SQL Editor.

-- 1. Create Audit Logs table
CREATE TABLE IF NOT EXISTS public.audit_logs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid REFERENCES public.users(id) ON DELETE SET NULL,
    action_type text NOT NULL, -- e.g. 'MANUAL_PROMOTION', 'MANUAL_DEMOTION', 'RULES_EXECUTION'
    description text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

-- Disable Row Level Security (RLS) to match the project's architecture
ALTER TABLE public.audit_logs DISABLE ROW LEVEL SECURITY;

-- 2. Add tie_break_priority column to event_assessments
ALTER TABLE public.event_assessments ADD COLUMN IF NOT EXISTS tie_break_priority integer DEFAULT 0;

-- 3. Replace calculate_stage_advancement PL/pgSQL function with dynamic sorting priorities
CREATE OR REPLACE FUNCTION public.calculate_stage_advancement(p_stage_id uuid)
RETURNS json AS $$
DECLARE
    v_rule_id text;
    v_rule_val integer;
    v_order_by text := 'sum(coalesce(sc.total_score, 0)) desc';
    v_ass record;
    v_sql text;
BEGIN
    -- Fetch stage advancement rules
    SELECT advancement_rule_id, advancement_rule_value INTO v_rule_id, v_rule_val
    FROM public.event_stages
    WHERE id = p_stage_id;

    -- Dynamically build tie-breaking sorting order based on tie_break_priority
    FOR v_ass IN (
        SELECT id 
        FROM public.event_assessments 
        WHERE stage_id = p_stage_id 
        ORDER BY coalesce(tie_break_priority, 0) DESC, created_at ASC
    ) LOOP
        v_order_by := v_order_by || ', sum(case when sc.assessment_id = ''' || v_ass.id || ''' then coalesce(sc.total_score, 0) else 0 end) desc';
    END LOOP;

    -- Clear old qualifications and ranks for this stage first
    UPDATE public.stage_participants
    SET stage_1_score = 0,
        stage_1_rank = null,
        qualification_status = 'PENDING'
    WHERE stage_id = p_stage_id;

    -- Process based on rules
    IF v_rule_id = 'TOP_N_PER_CENTRE' THEN
        -- Execute dynamic query for ranked_students partition by centre
        v_sql := '
            with ranked_students as (
                select 
                    sp.id as stage_participant_id,
                    sum(coalesce(sc.total_score, 0)) as total_stage_score,
                    row_number() over (
                        partition by st.centre_id 
                        order by ' || v_order_by || '
                    ) as rank_in_centre
                from public.stage_participants sp
                join public.event_participants ep on sp.participant_id = ep.id
                join public.students st on ep.student_id = st.id
                left join public.assessment_scores sc on sc.stage_participant_id = sp.id
                where sp.stage_id = $1
                group by sp.id, st.centre_id
            )
            update public.stage_participants sp
            set stage_1_score = r.total_stage_score,
                stage_1_rank = r.rank_in_centre,
                qualification_status = case when r.rank_in_centre <= $2 then ''QUALIFIED'' else ''DISQUALIFIED'' end
            from ranked_students r
            where sp.id = r.stage_participant_id;
        ';
        EXECUTE v_sql USING p_stage_id, v_rule_val;

    ELSIF v_rule_id = 'TOP_N_OVERALL' THEN
        -- Execute dynamic query for overall ranking
        v_sql := '
            with ranked_students as (
                select 
                    sp.id as stage_participant_id,
                    sum(coalesce(sc.total_score, 0)) as total_stage_score,
                    row_number() over (
                        order by ' || v_order_by || '
                    ) as rank_overall
                from public.stage_participants sp
                left join public.assessment_scores sc on sc.stage_participant_id = sp.id
                where sp.stage_id = $1
                group by sp.id
            )
            update public.stage_participants sp
            set stage_1_score = r.total_stage_score,
                stage_1_rank = r.rank_overall,
                qualification_status = case when r.rank_overall <= $2 then ''QUALIFIED'' else ''DISQUALIFIED'' end
            from ranked_students r
            where sp.id = r.stage_participant_id;
        ';
        EXECUTE v_sql USING p_stage_id, v_rule_val;
        
    ELSIF v_rule_id = 'ALL_PARTICIPANTS' THEN
        UPDATE public.stage_participants
        SET qualification_status = 'QUALIFIED',
            stage_1_score = coalesce((
                SELECT sum(coalesce(sc.total_score, 0)) 
                from public.assessment_scores sc 
                where sc.stage_participant_id = stage_participants.id
            ), 0)
        WHERE stage_id = p_stage_id;
    END IF;

    RETURN json_build_object('success', true, 'message', 'Advancement rules processed.');
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
