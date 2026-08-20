-- 1. Update the students table unique student_id column
UPDATE public.students s
SET student_id = (
    SELECT e.event_code || '-' || lpad(sub.seq_num::text, 4, '0')
    FROM (
        SELECT 
            ep.student_id,
            ep.event_id,
            row_number() OVER (PARTITION BY ep.event_id ORDER BY ep.created_at ASC) AS seq_num
        FROM public.event_participants ep
    ) sub
    JOIN public.events e ON sub.event_id = e.id
    WHERE sub.student_id = s.id
)
WHERE s.id IN (SELECT student_id FROM public.event_participants);


-- 2. Update the event_participants table registration_number column
UPDATE public.event_participants ep
SET registration_number = (
    SELECT e.event_code || '-' || lpad(sub.seq_num::text, 4, '0')
    FROM (
        SELECT 
            ep2.id,
            ep2.event_id,
            row_number() OVER (PARTITION BY ep2.event_id ORDER BY ep2.created_at ASC) AS seq_num
        FROM public.event_participants ep2
    ) sub
    JOIN public.events e ON sub.event_id = e.id
    WHERE sub.id = ep.id
);
