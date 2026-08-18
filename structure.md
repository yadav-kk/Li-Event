# Database Schema & Structure Documentation

This document defines the schema, relations, columns, constraints, and indexes implemented inside the PostgreSQL database for the **Literacy India Event & Assessment Management Portal**.

---

## 1. Centres (`public.centres`)
Stores details of the operational hubs where literacy programmes and events take place.
* **Columns**:
  * `id` (`uuid`, Primary Key): Auto-generated unique identifier.
  * `centre_code` (`text`, Unique, Not Null): Identification prefix (e.g. `DL-01`, `HR-03`, `UP-01`).
  * `centre_name` (`text`, Not Null): Display name of the centre.
  * `district` (`text`): District/City location.
  * `state` (`text`): State location.
  * `address` (`text`): Physical address.
  * `centre_incharge_id` (`uuid`): References `public.users(id)` (Centre Incharge).
  * `coordinator_id` (`uuid`): References `public.users(id)` (Coordinator).
  * `status` (`text`, Default `'active'`): Can be `'active'` or `'inactive'`.
  * `created_at` (`timestamp with time zone`): Auto-timestamp.
  * `updated_at` (`timestamp with time zone`): Auto-timestamp.
* **Foreign Keys**:
  * `fk_centres_incharge`: References `public.users(id)` on delete set null.
  * `fk_centres_coordinator`: References `public.users(id)` on delete set null.

---

## 2. Users (`public.users`)
Stores user accounts for the portal (administrators, incharges, coordinators, and assessors).
* **Columns**:
  * `id` (`uuid`, Primary Key): Unique identifier.
  * `name` (`text`, Not Null): Display name.
  * `email` (`text`, Unique, Not Null): Login email.
  * `password` (`text`, Not Null): Plain text password (simple mock portal auth).
  * `mobile` (`text`): Contact number.
  * `centre_id` (`uuid`): Primary centre reference. References `public.centres(id)`.
  * `status` (`text`, Default `'active'`): `'active'` or `'inactive'`.
  * `created_at` / `updated_at` (`timestamp with time zone`).
* **Foreign Keys**:
  * References `public.centres(id)` on delete set null.

---

## 3. User Roles (`public.user_roles`)
Mapping table linking users to security roles. Enables multi-role permissions.
* **Columns**:
  * `user_id` (`uuid`, Primary Key): References `public.users(id)`.
  * `role_id` (`text`, Primary Key): Check constraints: `super_admin`, `prog_admin`, `centre_incharge`, `judge`, `academic_lead`, `final_judge`, `coordinator`, `management`.
* **Foreign Keys**:
  * References `public.users(id)` on delete cascade.

---

## 4. User Centres (`public.user_centres`)
Mapping table supporting many-to-many centre access for roles like Coordinators.
* **Columns**:
  * `user_id` (`uuid`, Primary Key): References `public.users(id)`.
  * `centre_id` (`uuid`, Primary Key): References `public.centres(id)`.
* **Foreign Keys**:
  * References `public.users(id)` on delete cascade.
  * References `public.centres(id)` on delete cascade.

---

## 5. Schools (`public.schools`)
Stores details of school associations within each centre hub.
* **Columns**:
  * `id` (`uuid`, Primary Key).
  * `school_name` (`text`, Not Null).
  * `school_code` (`text`, Unique, Not Null).
  * `centre_id` (`uuid`, Not Null): References `public.centres(id)`.
  * `school_type` (`text`, Default `'OTHER'`): Checks: `GYANTANTRA`, `GOVERNMENT`, `NGO`, `COMMUNITY`, `OTHER`.
  * `address` (`text`).
  * `status` (`text`, Default `'active'`).
  * `created_at` / `updated_at` (`timestamp with time zone`).
* **Foreign Keys**:
  * References `public.centres(id)` on delete cascade.

---

## 6. Batches (`public.batches`)
Batches/academic cohorts aligned to centres.
* **Columns**:
  * `id` (`uuid`, Primary Key).
  * `name` (`text`, Not Null).
  * `academic_year` (`text`, Not Null).
  * `centre_id` (`uuid`, Not Null): References `public.centres(id)`.
  * `created_at` (`timestamp with time zone`).
* **Foreign Keys**:
  * References `public.centres(id)` on delete cascade.

---

## 7. Students (`public.students`)
Master registry of all enrolled students.
* **Columns**:
  * `id` (`uuid`, Primary Key).
  * `student_id` (`text`, Unique, Not Null): Registration code format `GT-LIT-YYYY-XXXXXX`.
  * `name` (`text`, Not Null).
  * `gender` (`text`): `M`, `F`, or `Other`.
  * `date_of_birth` (`date`).
  * `class` (`text`, Not Null).
  * `centre_id` (`uuid`): References `public.centres(id)`.
  * `school_id` (`uuid`): References `public.schools(id)`.
  * `batch_id` (`uuid`): References `public.batches(id)`.
  * `guardian_name` (`text`).
  * `guardian_mobile` (`text`).
  * `language` (`text`): Dynamic select dropdown (e.g. `Hindi`, `English`).
  * `photo_path` (`text`).
  * `status` (`text`, Default `'active'`).
  * `created_at` / `updated_at` (`timestamp with time zone`).
* **Foreign Keys**:
  * References `public.centres(id)` on delete set null.
  * References `public.schools(id)` on delete set null.
  * References `public.batches(id)` on delete set null.

---

## 8. Events (`public.events`)
Operational configuration records for competitions and assessments.
* **Columns**:
  * `id` (`uuid`, Primary Key).
  * `name` (`text`, Not Null).
  * `event_code` (`text`, Unique, Not Null).
  * `event_type` (`text`, Default `'Competition'`).
  * `academic_year` (`text`, Not Null).
  * `class` (`text`, Not Null): Target classes.
  * `description` / `objective` (`text`).
  * `start_date` / `end_date` (`date`).
  * `registration_start` / `registration_end` (`date`).
  * `venue` (`text`).
  * `status` (`text`, Default `'DRAFT'`): Checks: `DRAFT`, `PLANNING`, `REGISTRATION_OPEN`, `REGISTRATION_CLOSED`, `IN_PROGRESS`, `RESULT_PROCESSING`, `COMPLETED`, `ARCHIVED`, `CANCELLED`.
  * `event_owner` (`uuid`): References `public.users(id)`.
  * `created_at` / `updated_at` (`timestamp with time zone`).
* **Foreign Keys**:
  * References `public.users(id)` on delete set null.

---

## 9. Event Centres (`public.event_centres`)
Join table indicating which centres are participating in an event.
* **Columns**:
  * `event_id` (`uuid`, Primary Key): References `public.events(id)`.
  * `centre_id` (`uuid`, Primary Key): References `public.centres(id)`.
* **Foreign Keys**:
  * References `public.events(id)` on delete cascade.
  * References `public.centres(id)` on delete cascade.

---

## 10. Event Stages (`public.event_stages`)
Sequential phases configured within a single event (e.g. Phase 1 Screening, Phase 2 Finale).
* **Columns**:
  * `id` (`uuid`, Primary Key).
  * `event_id` (`uuid`, Not Null): References `public.events(id)`.
  * `name` (`text`, Not Null).
  * `description` (`text`).
  * `sequence` (`integer`, Not Null): Sequential order index.
  * `start_datetime` / `end_datetime` (`timestamp with time zone`).
  * `configuration_deadline` (`timestamp with time zone`).
  * `venue` (`text`).
  * `status` (`text`, Default `'DRAFT'`): Checks: `DRAFT`, `SCHEDULED`, `OPEN`, `IN_PROGRESS`, `COMPLETED`, `LOCKED`, `CANCELLED`.
  * `participant_rule` (`text`): Eligibility criteria description.
  * `advancement_rule_id` (`text`, Default `'ALL_PARTICIPANTS'`): Checks: `TOP_N_OVERALL`, `TOP_N_PER_CENTRE`, `PERCENTAGE_THRESHOLD`, `SCORE_THRESHOLD`, `MANUAL_SELECTION`, `ALL_PARTICIPANTS`.
  * `advancement_rule_value` (`integer`).
  * `created_at` / `updated_at` (`timestamp with time zone`).
* **Foreign Keys**:
  * References `public.events(id)` on delete cascade.
* **Constraints**:
  * Unique combo: `(event_id, sequence)`.

---

## 11. Event Assessments (`public.event_assessments`)
Individual papers, parameters, or tests conducted in a given stage.
* **Columns**:
  * `id` (`uuid`, Primary Key).
  * `stage_id` (`uuid`, Not Null): References `public.event_stages(id)`.
  * `name` (`text`, Not Null).
  * `description` (`text`).
  * `assessment_type` (`text`, Default `'SCORE'`): Checks: `SCORE`, `YES_NO`, `RATING`, `ATTENDANCE`, `TEXT`, `FILE`.
  * `sequence` (`integer`, Not Null).
  * `max_marks` (`numeric(5,2)`, Not Null).
  * `start_datetime` / `end_datetime` / `configuration_deadline` (`timestamp with time zone`).
  * `status` (`text`, Default `'DRAFT'`): Checks: `DRAFT`, `ACTIVE`, `COMPLETED`, `LOCKED`.
  * `required` (`boolean`, Default `true`).
  * `judge_assignment_mode` (`text`, Default `'ALL_JUDGES'`).
  * `created_at` / `updated_at` (`timestamp with time zone`).
* **Foreign Keys**:
  * References `public.event_stages(id)` on delete cascade.
* **Constraints**:
  * Unique combo: `(stage_id, sequence)`.

---

## 12. Assessment Criteria (`public.assessment_criteria`)
Sub-sections or breakdown points of an assessment parameter (e.g. Reading, Writing, Math).
* **Columns**:
  * `id` (`uuid`, Primary Key).
  * `assessment_id` (`uuid`, Not Null): References `public.event_assessments(id)`.
  * `name` (`text`, Not Null).
  * `description` (`text`).
  * `max_marks` (`numeric(5,2)`, Not Null).
  * `sequence` (`integer`, Not Null).
  * `required` (`boolean`, Default `true`).
  * `created_at` (`timestamp with time zone`).
* **Foreign Keys**:
  * References `public.event_assessments(id)` on delete cascade.
* **Constraints**:
  * Unique combo: `(assessment_id, name)`.

---

## 13. Event Participants (`public.event_participants`)
Maps registered students to a given Event. Tracks event-wide standing.
* **Columns**:
  * `id` (`uuid`, Primary Key).
  * `event_id` (`uuid`, Not Null): References `public.events(id)`.
  * `student_id` (`uuid`, Not Null): References `public.students(id)`.
  * `registration_number` (`text`, Unique).
  * `registration_date` (`date`, Default current date).
  * `registration_status` (`text`, Default `'DRAFT'`): Checks: `DRAFT`, `SUBMITTED`, `UNDER_REVIEW`, `APPROVED`, `REJECTED`, `LOCKED`, `CANCELLED`.
  * `eligibility_status` (`text`, Default `'ELIGIBLE'`): Checks: `ELIGIBLE`, `INELIGIBLE`.
  * `attendance_status` (`text`, Default `'ABSENT'`): Checks: `PRESENT`, `ABSENT`, `LATE`, `EXCUSED`.
  * `current_stage_id` (`uuid`): References `public.event_stages(id)`.
  * `finalist_status` (`boolean`, Default `false`).
  * `created_at` / `updated_at` (`timestamp with time zone`).
* **Foreign Keys**:
  * References `public.events(id)` on delete cascade.
  * References `public.students(id)` on delete cascade.
  * References `public.event_stages(id)` on delete set null.
* **Constraints**:
  * Unique combo: `(event_id, student_id)`.

---

## 14. Stage Participants (`public.stage_participants`)
Tracks student eligibility and status inside a specific event stage.
* **Columns**:
  * `id` (`uuid`, Primary Key).
  * `stage_id` (`uuid`, Not Null): References `public.event_stages(id)`.
  * `participant_id` (`uuid`, Not Null): References `public.event_participants(id)`.
  * `qualification_source` (`text`).
  * `stage_1_score` (`numeric(5,2)`).
  * `stage_1_rank` (`integer`).
  * `qualification_status` (`text`, Default `'PENDING'`): Checks: `PENDING`, `QUALIFIED`, `DISQUALIFIED`, `CONFIRMED`.
  * `availability` (`text`).
  * `transport_required` (`boolean`, Default `false`).
  * `attendance` (`text`, Default `'ABSENT'`): Checks: `PRESENT`, `ABSENT`, `LATE`, `EXCUSED`.
  * `created_at` (`timestamp with time zone`).
* **Foreign Keys**:
  * References `public.event_stages(id)` on delete cascade.
  * References `public.event_participants(id)` on delete cascade.
* **Constraints**:
  * Unique combo: `(stage_id, participant_id)`.

---

## 15. Assessment Assignments (`public.assessment_assignments`)
Maps assessors/judges to specific stages, centres, or individual student grading tasks.
* **Columns**:
  * `id` (`uuid`, Primary Key).
  * `assessment_id` (`uuid`, Not Null): References `public.event_assessments(id)`.
  * `judge_id` (`uuid`, Not Null): References `public.users(id)`.
  * `centre_id` (`uuid`): References `public.centres(id)`.
  * `participant_id` (`uuid`): References `public.event_participants(id)`.
  * `created_at` (`timestamp with time zone`).
* **Foreign Keys**:
  * References `public.event_assessments(id)` on delete cascade.
  * References `public.users(id)` on delete cascade.
  * References `public.centres(id)` on delete cascade.
  * References `public.event_participants(id)` on delete cascade.

---

## 16. Assessment Scores (`public.assessment_scores`)
Header grading record submitted by a judge for an assessment.
* **Columns**:
  * `id` (`uuid`, Primary Key).
  * `assessment_id` (`uuid`, Not Null): References `public.event_assessments(id)`.
  * `stage_participant_id` (`uuid`, Not Null): References `public.stage_participants(id)`.
  * `judge_id` (`uuid`, Not Null): References `public.users(id)`.
  * `total_score` (`numeric(5,2)`, Not Null).
  * `remarks` (`text`).
  * `status` (`text`, Default `'DRAFT'`): Checks: `DRAFT`, `SUBMITTED`, `UNDER_REVIEW`, `VERIFIED`, `REJECTED`, `LOCKED`.
  * `verified_by` (`uuid`): References `public.users(id)`.
  * `verified_at` (`timestamp with time zone`).
  * `locked_at` (`timestamp with time zone`).
  * `created_at` / `updated_at` (`timestamp with time zone`).
* **Foreign Keys**:
  * References `public.event_assessments(id)` on delete cascade.
  * References `public.stage_participants(id)` on delete cascade.
  * References `public.users(id)` on delete set null.
  * References `public.users(id)` (verified_by) on delete set null.
* **Constraints**:
  * Unique combo: `(assessment_id, stage_participant_id, judge_id)`.

---

## 17. Criteria Scores (`public.criteria_scores`)
Normalized individual criterion score lines belonging to a parent header score record.
* **Columns**:
  * `id` (`uuid`, Primary Key).
  * `score_id` (`uuid`, Not Null): References `public.assessment_scores(id)`.
  * `criteria_id` (`uuid`, Not Null): References `public.assessment_criteria(id)`.
  * `score` (`numeric(5,2)`, Not Null).
  * `created_at` (`timestamp with time zone`).
* **Foreign Keys**:
  * References `public.assessment_scores(id)` on delete cascade.
  * References `public.assessment_criteria(id)` on delete cascade.
* **Constraints**:
  * Unique combo: `(score_id, criteria_id)`.

---

## 18. Evidence (`public.evidence`)
Stores file upload trails (e.g. answer sheets, videos, certificates).
* **Columns**:
  * `id` (`uuid`, Primary Key).
  * `event_id` (`uuid`, Not Null): References `public.events(id)`.
  * `stage_id` (`uuid`): References `public.event_stages(id)`.
  * `centre_id` (`uuid`): References `public.centres(id)`.
  * `participant_id` (`uuid`): References `public.event_participants(id)`.
  * `evidence_type` (`text`, Not Null).
  * `file_name` (`text`, Not Null).
  * `storage_path` (`text`, Not Null).
  * `uploaded_by` (`uuid`, Not Null): References `public.users(id)`.
  * `verification_status` (`text`, Default `'PENDING'`): Checks: `PENDING`, `VERIFIED`, `REJECTED`.
  * `created_at` (`timestamp with time zone`).
* **Foreign Keys**:
  * References `public.events(id)` on delete cascade.
  * References `public.event_stages(id)` on delete cascade.
  * References `public.centres(id)` on delete cascade.
  * References `public.event_participants(id)` on delete cascade.
  * References `public.users(id)` on delete set null.

---

## 19. Audit Logs (`public.audit_logs`)
Maintains operational audit history of portal events.
* **Columns**:
  * `id` (`uuid`, Primary Key).
  * `user_id` (`uuid`): References `public.users(id)`.
  * `action` (`text`, Not Null): `CREATE`, `UPDATE`, `DELETE`, `LOCK`, `UNLOCK`.
  * `entity_type` (`text`, Not Null): `EVENT`, `SCORE`, `STUDENT`.
  * `entity_id` (`text`).
  * `old_data` / `new_data` (`jsonb`).
  * `reason` (`text`).
  * `created_at` (`timestamp with time zone`).

---

## 20. Version History (`public.version_history`)
Tracks changes across system entities for debugging and rollback support.
* **Columns**:
  * `id` (`uuid`, Primary Key).
  * `entity_type` (`text`, Not Null).
  * `entity_id` (`uuid`, Not Null).
  * `version` (`integer`, Not Null).
  * `changed_by` (`uuid`): References `public.users(id)`.
  * `changed_at` (`timestamp with time zone`).
  * `change_reason` (`text`).
  * `old_value` / `new_value` (`jsonb`).

---

## Database Performance Indexes
The schema defines target indexes to ensure quick query execution on filters:
* `idx_students_centre`: `public.students(centre_id)`
* `idx_students_student_id`: `public.students(student_id)`
* `idx_event_stages_event`: `public.event_stages(event_id)`
* `idx_event_assessments_stage`: `public.event_assessments(stage_id)`
* `idx_criteria_assessment`: `public.assessment_criteria(assessment_id)`
* `idx_participants_event`: `public.event_participants(event_id)`
* `idx_participants_student`: `public.event_participants(student_id)`
* `idx_stage_participants_stage`: `public.stage_participants(stage_id)`
* `idx_scores_participant`: `public.assessment_scores(stage_participant_id)`
* `idx_criteria_scores_parent`: `public.criteria_scores(score_id)`
* `idx_evidence_event`: `public.evidence(event_id)`
* `idx_audit_user`: `public.audit_logs(user_id)`
