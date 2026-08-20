-- 1. Update the students table unique student_id column
WITH ranked_participants AS (
    SELECT 
        ep.student_id AS s_uuid,
        e.event_code AS code,
        row_number() OVER (PARTITION BY ep.event_id ORDER BY ep.created_at ASC) AS seq_num
    FROM public.event_participants ep
    JOIN public.events e ON ep.event_id = e.id
),
formatted_ids AS (
    SELECT 
        s_uuid,
        code || '-' || lpad(seq_num::text, 4, '0') AS new_id
    FROM ranked_participants
)
UPDATE public.students s
SET student_id = f.new_id
FROM formatted_ids f
WHERE s.id = f.s_uuid;


-- 2. Update the event_participants table registration_number column
WITH ranked_participants AS (
    SELECT 
        ep.id AS ep_id,
        e.event_code AS code,
        row_number() OVER (PARTITION BY ep.event_id ORDER BY ep.created_at ASC) AS seq_num
    FROM public.event_participants ep
    JOIN public.events e ON ep.event_id = e.id
),
formatted_ids AS (
    SELECT 
        ep_id,
        code || '-' || lpad(seq_num::text, 4, '0') AS new_id
    FROM ranked_participants
)
UPDATE public.event_participants ep
SET registration_number = f.new_id
FROM formatted_ids f
WHERE ep.id = f.ep_id;
