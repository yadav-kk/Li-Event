-- 1. Drop the old status check constraint
ALTER TABLE public.events 
DROP CONSTRAINT IF EXISTS events_status_check;

-- 2. Update existing event statuses from legacy 'IN_PROGRESS' to new 'REGISTRATION'
UPDATE public.events
SET status = 'REGISTRATION'
WHERE status = 'IN_PROGRESS';

-- 3. Add the new status check constraint with REGISTRATION, PRACTICE, and ASSESSMENT
ALTER TABLE public.events 
ADD CONSTRAINT events_status_check 
CHECK (status in ('PLANNING', 'REGISTRATION', 'PRACTICE', 'ASSESSMENT', 'COMPLETED', 'ARCHIVED', 'CANCELLED'));
