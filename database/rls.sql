-- Disable Row Level Security (RLS) on all tables for direct database access using client-side tables login

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
