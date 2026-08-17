# Software Requirements Specification (SRS)
# Literacy India Event & Assessment Management Portal

**Version:** 1.0  
**Status:** Development Baseline  
**Primary Use Case:** GyanTantra se Saksharta – Class V Literacy Challenge 2026  
**Frontend:** HTML5, CSS3, JavaScript (ES6+)  
**Hosting:** GitHub Pages  
**Backend:** Supabase  
**Database:** PostgreSQL via Supabase  
**Authentication:** Supabase Auth  
**Storage:** Supabase Storage  

---

## 1. Document Purpose

This document is the implementation blueprint for building a reusable **Literacy India Event & Assessment Management Portal**.

The portal must NOT be hard-coded only for the 2026 Literacy Challenge. It must provide a generic event engine where an administrator can create an event/competition, configure multiple stages, configure multiple assessments within each stage, define participants, assign judges, collect scores, calculate results, apply advancement rules, and generate reports.

The current GyanTantra se Saksharta – Class V Literacy Challenge 2026 is the first concrete event that the system must support.

The current programme documents define a two-stage literacy programme for Class V students, with Stage 1 covering Reading, Writing and Spelling through a common 60-mark assessment and selection of the Top 5 students from each centre for the final competition.

---

# 2. Product Vision

Build a configurable, secure and reusable web application for managing Literacy India competitions, assessments and academic events.

The system should support this generic flow:

```text
Create Event
    ↓
Configure Event
    ↓
Create Stages
    ↓
Create Assessments
    ↓
Configure Criteria / Marks
    ↓
Configure Participants
    ↓
Assign Judges
    ↓
Open Registration
    ↓
Conduct Assessments
    ↓
Enter Scores
    ↓
Verify Scores
    ↓
Calculate Results
    ↓
Apply Advancement Rules
    ↓
Move Qualified Participants to Next Stage
    ↓
Conduct Final Stage
    ↓
Calculate Final Results
    ↓
Declare Winners
    ↓
Generate Reports
    ↓
Archive Event
```

---

# 3. Current Business Context

## 3.1 GyanTantra se Saksharta – Class V Literacy Challenge 2026

The current source requirements describe:

- Class V students
- Literacy competition
- Reading
- Writing
- Spelling
- Centre-level screening
- Top 5 students from each centre
- Final competition
- Student-wise literacy data
- Centre-wise literacy data
- Skill-wise analysis
- Certificates and recognition

The project plan specifies Stage 1:

| Assessment | Marks |
|---|---:|
| Spelling | 20 |
| Writing | 20 |
| Reading | 20 |
| **Total** | **60** |

Stage 1 dates in the current project plan:

- 2 September 2026 – Spelling
- 3 September 2026 – Writing
- 4 September 2026 – Reading

The project plan states that the Top 5 students from every centre qualify for Stage 2.

The World Literacy Day planning document describes the final competition with Reading, Writing, Spelling and a fourth Literacy Expression round, with a combined score of 70 marks.

Another project document describes the fourth Stage 2 activity as Rapid Fire.

Therefore, the application MUST NOT hard-code the fourth round or final scoring structure. Stage 2 assessments and their maximum marks must be configurable.

---

# 4. Core Design Principle

The system must be **configuration-driven**, not event-specific.

DO NOT build:

```text
spelling_score
writing_score
reading_score
```

as the only assessment structure.

Instead build:

```text
event
  → stages
      → assessments
          → criteria
              → scores
```

This allows future events such as:

- Literacy Competition
- Reading Competition
- Spelling Competition
- Quiz Competition
- Drawing Competition
- Academic Assessment
- Skill Assessment
- Other Literacy India programmes

to use the same platform.

---

# 5. Scope

## 5.1 In Scope

### Event Management
- Create event
- Edit event
- Duplicate event
- Archive event
- Event status
- Event timeline
- Event configuration
- Event templates

### Stage Management
- Create stages
- Edit stages
- Reorder stages
- Configure stage dates
- Configure stage venue
- Configure stage participants
- Configure advancement rules

### Assessment Management
- Create assessments
- Edit assessments before lock
- Configure assessment dates
- Configure maximum marks
- Configure assessment criteria
- Assign judges
- Configure assessment types
- Lock assessments
- Cancel/reschedule assessments

### Participant Management
- Student master
- Centre master
- School master
- Event registration
- Bulk import
- Verification
- Participant status

### Assessment Execution
- Judge dashboard
- Assigned participants
- Score entry
- Draft scores
- Submit scores
- Verification
- Score locking

### Results
- Automatic totals
- Percentage
- Centre ranking
- Overall ranking
- Advancement
- Finalists
- Winners

### Evidence
- Attendance
- Photos
- Documents
- Score sheets
- Winner lists

### Reports
- Registration
- Assessment
- Centre
- Participant
- Ranking
- Finalist
- Winner
- Skill analysis

### Security
- Authentication
- Role-based access
- Supabase Row Level Security
- Audit logs
- Secure storage

---

# 6. Out of Scope for Version 1

Do not implement unless explicitly requested:

- Native mobile app
- AI judging
- Automatic handwriting evaluation
- Automatic pronunciation scoring
- Online video examination
- Payment processing
- Public student database
- Public student contact information

---

# 7. User Roles

## 7.1 Super Administrator

Full access.

Can:

- Create/edit/archive events
- Configure stages
- Configure assessments
- Manage users
- Manage centres
- Manage participants
- Assign judges
- Verify results
- Override locks
- View audit logs
- Export reports
- Manage system configuration

---

## 7.2 Programme/Data Administrator

Can:

- Manage event data
- Manage registration
- Import students
- Verify students
- Review assessments
- Analyse results
- Confirm advancement
- Generate reports

---

## 7.3 Centre In-Charge

Can only access assigned centre data.

Can:

- Register students
- Edit student data before registration lock
- View registered students
- Mark attendance
- Upload evidence
- View centre results
- View qualified students

Cannot:

- View other centres
- Modify verified marks
- Change event configuration

---

## 7.4 Judge / Assessor

Can:

- View assigned assessments
- View assigned participants
- Enter marks
- Save drafts
- Submit marks
- Add remarks

Cannot:

- Change participant identity
- Change event configuration
- Change maximum marks
- Modify locked scores

---

## 7.5 Academic Lead

Can:

- Review assessment structure
- Review criteria
- Review assessment content metadata
- Verify assessment standards
- Review scores
- Approve Stage 1 results

---

## 7.6 Final Judge

Can:

- View Stage 2 finalists
- Enter final assessment scores
- Submit final scores
- Add remarks

---

## 7.7 Coordinator / Logistics

Can:

- View qualified participants
- Confirm availability
- Update transport information
- View travel list
- View Stage 2 attendance

---

## 7.8 Management

Read-only access to:

- Dashboard
- Event performance
- Participation
- Results
- Centre performance
- Winners
- Reports

---

# 8. Authentication

Use Supabase Auth.

Minimum:

- Email/password login
- Logout
- Password reset
- Session management

Future:

- Microsoft login
- Google login

User profile fields:

```text
id
name
email
mobile
role
centre_id
status
created_at
updated_at
last_login
```

---

# 9. Event Management

## 9.1 Create Event

Admin can create:

- Event name
- Event code
- Event type
- Academic year
- Class
- Description
- Objective
- Start date
- End date
- Registration start
- Registration end
- Venue
- Status
- Event owner

Example:

```text
Event Name:
GyanTantra se Saksharta – Class V Literacy Challenge 2026

Event Code:
GT-LIT-2026

Event Type:
Competition

Class:
V
```

---

# 10. Event Status

Supported statuses:

```text
DRAFT
PLANNING
REGISTRATION_OPEN
REGISTRATION_CLOSED
IN_PROGRESS
RESULT_PROCESSING
COMPLETED
ARCHIVED
CANCELLED
```

Status changes should be controlled by business rules.

---

# 11. Event Configuration Deadlines

Every configurable object should support deadlines.

Important concept:

### Configuration Deadline

The last time configuration can normally be changed.

### Start Date/Time

When the activity actually starts.

### End Date/Time

When the activity ends.

Example:

```text
Assessment:
Reading

Configuration Deadline:
03-Sep-2026 23:59

Start:
04-Sep-2026 10:00

End:
04-Sep-2026 12:00
```

Before configuration deadline:

```text
EDITABLE
```

After deadline:

```text
CONFIGURATION LOCKED
```

After activity starts:

```text
ACTIVE
```

After completion:

```text
COMPLETED
```

After verification:

```text
LOCKED
```

---

# 12. Emergency Override

Super Administrator may unlock a locked object.

Required fields:

- Reason
- User
- Date/time
- Object
- Previous status
- New status

Every override MUST create an audit log.

---

# 13. Stage Management

Each event can have unlimited stages.

Example:

```text
Event
 ├── Stage 1: Centre Screening
 ├── Stage 2: Final Competition
 └── Stage 3: Optional Future Stage
```

Stage fields:

```text
id
event_id
name
description
sequence
start_datetime
end_datetime
configuration_deadline
venue
status
participant_rule
advancement_rule_id
created_at
updated_at
```

---

# 14. Stage Status

```text
DRAFT
SCHEDULED
OPEN
IN_PROGRESS
COMPLETED
LOCKED
CANCELLED
```

---

# 15. Assessment Management

Each stage can have multiple assessments.

Example:

```text
Stage 1
 ├── Spelling
 ├── Writing
 └── Reading
```

Each assessment should be independently configurable.

Assessment fields:

```text
id
stage_id
name
description
assessment_type
sequence
max_marks
start_datetime
end_datetime
configuration_deadline
status
required
judge_assignment_mode
created_at
updated_at
```

---

# 16. Assessment Types

Version 1 should support:

## 16.1 Score Based

Example:

```text
Reading
Maximum Marks: 20
```

## 16.2 Yes/No

Example:

```text
Participation:
Yes / No
```

## 16.3 Rating

Example:

```text
Confidence:
1–5
```

## 16.4 Attendance

```text
Present
Absent
```

## 16.5 Text Evaluation

Judge enters remarks.

## 16.6 Evidence/File

Participant or assessor uploads evidence.

The database should be designed so more assessment types can be added later.

---

# 17. Assessment Criteria Builder

An assessment can have multiple criteria.

Example:

```text
Reading – 20 Marks

Accuracy              8
Fluency               5
Pronunciation         3
Expression            2
Confidence            2
-------------------------
Total                20
```

Criteria fields:

```text
id
assessment_id
name
description
max_marks
sequence
required
created_at
```

The sum of criteria maximum marks must equal assessment maximum marks.

Validation:

```text
SUM(criteria.max_marks) = assessment.max_marks
```

---

# 18. Current Stage 1 Configuration

The first event should be configured as:

```text
Stage 1:
Centre Level Literacy Screening

Assessment 1:
Spelling
20 marks
02-Sep-2026

Assessment 2:
Writing
20 marks
03-Sep-2026

Assessment 3:
Reading
20 marks
04-Sep-2026
```

---

# 19. Current Spelling Criteria

```text
10 Words
Maximum: 10

Sentence 1
Maximum: 5

Sentence 2
Maximum: 5

Total: 20
```

---

# 20. Current Writing Criteria

```text
Content and relevance       5
Creativity / ideas          5
Sentence formation/grammar  4
Vocabulary                  3
Spelling/punctuation        3
Total                      20
```

---

# 21. Current Reading Criteria

```text
Accuracy / correct reading  8
Fluency                     5
Pronunciation               3
Expression                  2
Confidence                  2
Total                      20
```

---

# 22. Stage 2

Stage 2 must be configurable.

The current requirements mention:

- Reading
- Writing
- Spelling
- Literacy Expression / Rapid Fire

Because the source documents differ on the fourth round, the system must allow the administrator to choose the final assessments and maximum marks.

Do NOT hard-code 70 marks.

---

# 23. Participant Management

Participants are independent of assessments.

Core participant entity:

```text
event_participants
```

A student can participate in multiple events over multiple years.

Student master should remain separate:

```text
students
```

Relationship:

```text
student
    ↓
event_participant
    ↓
event
```

---

# 24. Student Master

Fields:

```text
id
student_id
name
gender
date_of_birth
class
centre_id
school_id
batch_id
guardian_name
guardian_mobile
language
photo_path
status
created_at
updated_at
```

Student ID format:

```text
GT-LIT-2026-000001
```

The ID must be unique.

---

# 25. Event Participant

Fields:

```text
id
event_id
student_id
registration_number
registration_date
registration_status
eligibility_status
attendance_status
current_stage_id
finalist_status
created_at
updated_at
```

---

# 26. Registration Status

```text
DRAFT
SUBMITTED
UNDER_REVIEW
APPROVED
REJECTED
LOCKED
CANCELLED
```

---

# 27. Bulk Import

Support CSV import.

Expected columns:

```text
Student Name
Gender
Class
Centre
School
Batch
Guardian Name
Guardian Mobile
Language
```

Import process:

```text
Upload CSV
    ↓
Parse
    ↓
Validate
    ↓
Show Preview
    ↓
Identify Errors
    ↓
Confirm Import
    ↓
Create Records
```

Display:

```text
Total: 50
Valid: 45
Duplicate: 3
Invalid: 2
```

Never silently discard invalid rows.

---

# 28. Centre Management

Fields:

```text
id
centre_code
centre_name
district
state
address
centre_incharge_id
coordinator_id
status
created_at
updated_at
```

Centre users can only access their assigned centre.

---

# 29. School Management

Fields:

```text
id
school_name
school_code
centre_id
school_type
address
status
```

School types can include:

```text
GYANTANTRA
GOVERNMENT
NGO
COMMUNITY
OTHER
```

---

# 30. Judge Assignment

Assessors can be assigned:

- Event level
- Stage level
- Assessment level
- Centre level
- Participant level

Recommended Version 1:

```text
Judge → Assessment → Centre/Participant
```

The system must prevent judges from accessing unauthorised scores.

---

# 31. Assessment Execution

Judge workflow:

```text
Login
 ↓
My Assessments
 ↓
Select Assessment
 ↓
Select Participant
 ↓
Enter Criteria Scores
 ↓
Automatic Total
 ↓
Save Draft
 ↓
Submit
```

---

# 32. Score Validation

For each criterion:

```text
score >= 0
score <= max_marks
```

Total is calculated automatically.

The user must NOT manually enter the assessment total.

---

# 33. Score Status

```text
DRAFT
SUBMITTED
UNDER_REVIEW
VERIFIED
REJECTED
LOCKED
```

---

# 34. Score Locking

Once a score is verified and locked:

- Judge cannot edit it.
- Centre In-Charge cannot edit it.
- Participant cannot edit it.
- Only authorised administrator can unlock.

Unlock requires reason and audit entry.

---

# 35. Automatic Results Engine

For each participant:

```text
Assessment Scores
       ↓
Stage Total
       ↓
Percentage
       ↓
Stage Rank
       ↓
Advancement Rule
```

Example:

```text
Spelling = 18
Writing  = 17
Reading  = 19

Total = 54
Maximum = 60

Percentage = 90%
```

---

# 36. Ranking Engine

Support:

### Overall Ranking

All participants.

### Centre Ranking

Participants grouped by centre.

### School Ranking

Optional.

### Stage Ranking

Participants within a stage.

### Assessment Ranking

Optional.

Ranking direction should be configurable:

```text
HIGH_SCORE_WINS
LOW_SCORE_WINS
```

Default:

```text
HIGH_SCORE_WINS
```

---

# 37. Tie-Breaking

Tie-breaking must be configurable.

Recommended default:

```text
1. Higher total score
2. Higher Reading score
3. Higher Writing score
4. Higher Spelling score
5. Manual academic review
```

Do not permanently hard-code this if the event builder can configure it.

---

# 38. Advancement Rules

An event stage can define how participants move to the next stage.

Supported rules:

```text
TOP_N_OVERALL
TOP_N_PER_CENTRE
PERCENTAGE_THRESHOLD
SCORE_THRESHOLD
MANUAL_SELECTION
ALL_PARTICIPANTS
```

Example:

```text
Rule:
TOP_N_PER_CENTRE

N:
5
```

This supports the current Top 5 requirement.

---

# 39. Advancement Workflow

```text
Stage 1 Completed
       ↓
All Required Assessments Verified
       ↓
Calculate Scores
       ↓
Calculate Ranking
       ↓
Apply Advancement Rule
       ↓
Generate Qualified Participants
       ↓
Admin Review
       ↓
Confirm
       ↓
Move to Stage 2
```

---

# 40. Manual Confirmation

Even if advancement is automatic, the system should require authorised confirmation before finalising the list.

Example:

```text
Automatic Top 5 Generated

[ Confirm Selection ]

Before confirmation:
Admin can review.

After confirmation:
List becomes locked.
```

---

# 41. Stage 2 Participant List

Fields:

```text
participant_id
stage_id
qualification_source
stage_1_score
stage_1_rank
qualification_status
availability
transport_required
attendance
```

---

# 42. Attendance

Attendance should be supported at event/stage level.

Fields:

```text
id
event_id
stage_id
participant_id
attendance_status
check_in_time
check_out_time
remarks
recorded_by
created_at
```

Statuses:

```text
PRESENT
ABSENT
LATE
EXCUSED
```

---

# 43. Logistics

For finalist events:

```text
availability_status
transport_required
transport_mode
pickup_location
arrival_status
departure_status
remarks
```

Only authorised logistics users can edit this.

---

# 44. Evidence Management

Evidence types:

```text
Registration Sheet
Attendance Sheet
Reading Photos
Writing Photos
Spelling Photos
Competition Photos
Prize Distribution Photos
Winner List
Final Score Sheet
Other
```

Use Supabase Storage.

Evidence metadata:

```text
id
event_id
stage_id
centre_id
participant_id
evidence_type
file_name
storage_path
uploaded_by
verification_status
created_at
```

---

# 45. Storage Structure

Recommended:

```text
events/
  {event_id}/
    registration/
    attendance/
    assessments/
    evidence/
    results/
    certificates/
```

For centre-specific files:

```text
events/
  {event_id}/
    centres/
      {centre_id}/
        registration/
        attendance/
        evidence/
```

---

# 46. Dashboard

## Admin Dashboard

Cards:

```text
Total Events
Active Events
Total Centres
Total Participants
Assessments Completed
Pending Assessments
Qualified Participants
Final Winners
```

Charts:

- Participation by centre
- Assessment completion
- Average scores
- Skill performance
- Centre performance
- Score distribution

---

# 47. Event Dashboard

For each event:

```text
Event Name
Status
Start Date
End Date

Participants
Assessments
Stages
Completion %

Stage 1
██████████████ 100%

Stage 2
███████░░░░░░ 50%
```

---

# 48. Centre Dashboard

Centre users see only their centre:

```text
Registered Students
Approved Students
Assessment Completion
Average Score
Top Performers
Pending Evidence
Qualified Students
```

---

# 49. Student Profile

Show:

```text
Student Information

Event Participation

Stage 1
  Spelling
  Writing
  Reading
  Total
  Rank

Stage 2
  Reading
  Writing
  Spelling
  Final Round
  Total

Final Result
```

---

# 50. Reports

Required reports:

1. Event Registration Report
2. Student Master Report
3. Assessment Score Report
4. Stage Result Report
5. Centre Ranking Report
6. Overall Ranking Report
7. Top N Report
8. Finalist Report
9. Winner Report
10. Attendance Report
11. Evidence Report
12. Skill Analysis Report

---

# 51. Export

Allow authorised users to export:

- CSV
- Excel-compatible CSV

Future:

- PDF
- Certificate PDF
- Printable score sheets

Export must obey RLS and role permissions.

---

# 52. Analytics

For literacy events, calculate:

```text
Average Reading Score
Average Writing Score
Average Spelling Score

Reading %
Writing %
Spelling %

Centre Average
Overall Average
Highest Score
Lowest Score
```

Also identify:

```text
Strongest Skill
Weakest Skill
Students Needing Support
High Performers
```

---

# 53. Audit Logs

Every important operation must be recorded.

Fields:

```text
id
user_id
action
entity_type
entity_id
old_data
new_data
reason
created_at
```

Actions include:

```text
CREATE
UPDATE
DELETE
LOGIN
LOGOUT
SUBMIT
VERIFY
LOCK
UNLOCK
APPROVE
REJECT
EXPORT
ADVANCE
CANCEL
```

Never permanently delete audit logs through the normal UI.

---

# 54. Version History

Important configurable objects should support version history.

At minimum:

- Event
- Stage
- Assessment
- Criteria
- Advancement Rule

Each change should record:

```text
version
changed_by
changed_at
change_reason
old_value
new_value
```

---

# 55. Event Templates

Allow:

```text
Create Blank Event
Create From Existing Event
Create From Template
```

When cloning an event:

COPY:

- Event structure
- Stages
- Assessments
- Criteria
- Advancement rules
- Default configuration

DO NOT COPY:

- Participants
- Scores
- Rankings
- Attendance
- Evidence
- Winners
- Audit history

---

# 56. Date and Time Rules

Store timestamps in UTC in the database.

Display in:

```text
Asia/Kolkata
```

Use ISO timestamps internally.

All date comparisons must be server/database based where security matters.

Do not rely only on browser time.

---

# 57. Frontend Requirements

Use:

```text
HTML5
CSS3
JavaScript ES6+
Supabase JavaScript Client
```

No frontend framework is required for Version 1.

Use modular JavaScript.

Recommended:

```text
/js/
  app.js
  auth.js
  supabase.js
  permissions.js
  events.js
  stages.js
  assessments.js
  criteria.js
  participants.js
  students.js
  centres.js
  judges.js
  scores.js
  results.js
  advancement.js
  evidence.js
  reports.js
  dashboard.js
  audit.js
  utils.js
```

---

# 58. Project Structure

```text
literacy-india-event-portal/
│
├── index.html
├── README.md
├── SRS.md
├── .gitignore
│
├── assets/
│   ├── css/
│   │   ├── style.css
│   │   ├── responsive.css
│   │   └── components.css
│   │
│   ├── js/
│   │   ├── app.js
│   │   ├── auth.js
│   │   ├── supabase.js
│   │   ├── permissions.js
│   │   ├── events.js
│   │   ├── stages.js
│   │   ├── assessments.js
│   │   ├── criteria.js
│   │   ├── participants.js
│   │   ├── students.js
│   │   ├── centres.js
│   │   ├── scores.js
│   │   ├── results.js
│   │   ├── advancement.js
│   │   ├── evidence.js
│   │   ├── reports.js
│   │   ├── dashboard.js
│   │   └── utils.js
│   │
│   └── images/
│
├── pages/
│   ├── login.html
│   ├── dashboard.html
│   ├── events.html
│   ├── event-details.html
│   ├── event-builder.html
│   ├── stages.html
│   ├── assessments.html
│   ├── participants.html
│   ├── students.html
│   ├── centres.html
│   ├── judge-dashboard.html
│   ├── score-entry.html
│   ├── results.html
│   ├── finalists.html
│   ├── evidence.html
│   ├── reports.html
│   ├── users.html
│   └── audit-logs.html
│
├── database/
│   ├── schema.sql
│   ├── functions.sql
│   ├── triggers.sql
│   ├── rls.sql
│   └── seed.sql
│
└── docs/
    ├── architecture.md
    └── deployment.md
```

---

# 59. Supabase Database

Minimum tables:

```text
profiles
roles
permissions
user_roles

centres
schools
batches
students

events
event_stages
event_assessments
assessment_criteria

event_participants
stage_participants
assessment_assignments
assessment_scores

advancement_rules
results
rankings
winners

attendance
evidence
notifications
audit_logs
```

---

# 60. Important Database Relationships

```text
events
  1 ──── N event_stages

event_stages
  1 ──── N event_assessments

event_assessments
  1 ──── N assessment_criteria

events
  1 ──── N event_participants

students
  1 ──── N event_participants

event_participants
  1 ──── N stage_participants

event_assessments
  1 ──── N assessment_scores

stage_participants
  1 ──── N assessment_scores
```

---

# 61. Database Constraints

Use PostgreSQL constraints.

Examples:

```text
student_id UNIQUE
centre_code UNIQUE
event_code UNIQUE
score >= 0
score <= max_marks
```

Foreign keys must be enforced.

Do not rely only on JavaScript validation.

---

# 62. Supabase RLS

RLS is mandatory.

Example:

### Super Admin

Full access.

### Management

SELECT only.

### Centre In-Charge

Can access:

```text
centre_id = current user's centre_id
```

### Judge

Can access only assigned assessment/participant records.

### Student

No student self-service in Version 1 unless specifically enabled.

---

# 63. Security Rules

Never expose:

```text
SUPABASE_SERVICE_ROLE_KEY
```

in frontend code.

Only the public/anon key may be used in the browser.

Database protection must come from:

- RLS
- PostgreSQL constraints
- Authentication
- Secure storage policies

---

# 64. Sensitive Data

Treat these as confidential:

- Guardian mobile
- Student personal information
- Assessment scores
- Judge information
- Internal remarks
- Evidence files

Do not expose them publicly.

---

# 65. Public Pages

The public site may contain:

- Event name
- Description
- Dates
- Venue
- General information
- Publicly approved winners

Never expose full student databases.

---

# 66. Responsive Design

Must support:

- Desktop
- Laptop
- Tablet
- Android mobile

Centre In-Charges should be able to use:

- Registration
- Attendance
- Student search
- Evidence upload
- Result viewing

from mobile.

---

# 67. UI Design

Design principles:

- Clean
- Professional
- Simple
- Fast
- Accessible
- Minimal clicks
- Clear status indicators
- Responsive tables
- Confirmation dialogs
- Search and filters

Use consistent status badges.

Example:

```text
DRAFT       → Grey
ACTIVE      → Blue
COMPLETED   → Green
LOCKED      → Dark
CANCELLED   → Red
```

---

# 68. Event Builder UX

Use a wizard:

```text
1. Basic Information
2. Timeline
3. Stages
4. Assessments
5. Criteria
6. Participants
7. Advancement Rules
8. Judges
9. Review
10. Publish
```

At every step:

```text
Save Draft
Save & Continue
Back
Cancel
```

---

# 69. Assessment Builder UX

Example:

```text
Assessment Name
[ Reading ]

Type
[ Score Based ]

Maximum Marks
[ 20 ]

Date
[ 04-Sep-2026 ]

Configuration Deadline
[ 03-Sep-2026 ]

Criteria

+ Add Criterion

Accuracy       8
Fluency        5
Pronunciation  3
Expression     2
Confidence     2

Total = 20
```

System must prevent saving if criteria total does not equal maximum marks.

---

# 70. Event Review Page

Before publishing, show:

```text
Event
Stages
Assessments
Dates
Marks
Criteria
Participants
Advancement Rules
Judges
```

Show validation:

```text
✓ Event details complete
✓ Stage dates valid
✓ Assessment marks valid
✓ Criteria totals valid
✓ Advancement rule configured
✓ Judges assigned
```

Do not allow publishing if mandatory validation fails.

---

# 71. Date Conflict Validation

The system should detect:

- Assessment outside stage dates
- Stage outside event dates
- Configuration deadline after assessment start
- End date before start date
- Conflicting assessment times where the same judge is assigned

Example:

```text
ERROR:
Reading assessment starts after Stage 1 ends.
Please correct the date.
```

---

# 72. Change Management

Before an event starts, Admin can change:

- Dates
- Assessment names
- Marks
- Criteria
- Judges
- Advancement rules
- Venue

After locking, changes require:

```text
Unlock
→ Reason
→ Change
→ Re-lock
```

Audit everything.

---

# 73. Cancellation and Rescheduling

Any event/stage/assessment can be cancelled or rescheduled by authorised users.

Cancellation requires:

```text
Reason
```

Rescheduling requires:

```text
New Date
New Time
Reason
```

Notify affected users in-app.

---

# 74. Notifications

Version 1:

- In-app notifications

Examples:

```text
Assessment scheduled.
Assessment date changed.
Registration deadline approaching.
Assessment pending.
Scores submitted.
Results verified.
You have qualified for Stage 2.
```

Future:

- Email
- Microsoft Teams
- WhatsApp

---

# 75. Certificate Support

Design the database for certificates, even if automatic PDF generation is Version 2.

Certificate types:

```text
Participation
Winner
Runner-up
Best Reader
Best Writer
Best Speller
Finalist
```

Future table:

```text
certificates
```

---

# 76. Testing Requirements

Before deployment test:

## Authentication

- Login
- Logout
- Password reset
- Session expiration

## Permissions

- Admin access
- Management read-only
- Centre isolation
- Judge isolation

## Event Builder

- Create
- Edit
- Clone
- Publish
- Archive

## Assessment

- Criteria validation
- Score validation
- Date validation
- Judge assignment
- Locking

## Results

- Total calculation
- Percentage
- Ranking
- Tie-breaking
- Advancement

## Security

- RLS
- Storage policies
- Direct API access attempts
- Unauthorised record access

## Mobile

- Login
- Registration
- Score entry
- Evidence upload
- Dashboard

---

# 77. Acceptance Criteria

The system is ready for production when:

1. Admin can create an event without changing source code.
2. Admin can create multiple stages.
3. Admin can create multiple assessments within a stage.
4. Admin can configure assessment marks.
5. Admin can create assessment criteria.
6. System validates criteria totals.
7. Admin can configure dates.
8. System locks configuration after the configured deadline.
9. Admin can override locks with an audit reason.
10. Students can be registered.
11. Bulk import works.
12. Duplicate records are detected.
13. Judges can enter marks.
14. Judges cannot access unauthorised participants.
15. Scores calculate automatically.
16. Scores cannot exceed maximum marks.
17. Verified scores can be locked.
18. Ranking is automatic.
19. Advancement rules work.
20. Top 5 per centre works for the current event.
21. Stage 2 participants are generated correctly.
22. Final results are calculated.
23. Reports can be exported.
24. RLS prevents unauthorised access.
25. Audit logs capture important changes.
26. Application works on mobile.
27. No service-role key is exposed.
28. GitHub Pages deployment works.
29. Supabase Storage upload works.
30. Event can be cloned for a future year without copying results.

---

# 78. Development Order

Implement in this order.

## Phase 1

Project setup:

- GitHub repository
- HTML/CSS/JS structure
- Supabase project
- Environment/configuration
- Base layout

## Phase 2

Authentication:

- Login
- Logout
- User profile
- Roles
- Permissions
- RLS

## Phase 3

Master Data:

- Centres
- Schools
- Batches
- Students
- Users

## Phase 4

Event Engine:

- Event creation
- Event editing
- Event status
- Event cloning
- Event timeline

## Phase 5

Stage Engine:

- Stage creation
- Stage ordering
- Stage dates
- Stage status

## Phase 6

Assessment Engine:

- Assessment builder
- Assessment types
- Criteria builder
- Marks configuration
- Judge assignment
- Date locking

## Phase 7

Participants:

- Registration
- Bulk import
- Verification
- Participant status

## Phase 8

Assessment Execution:

- Judge dashboard
- Score entry
- Draft
- Submit
- Verify
- Lock

## Phase 9

Results Engine:

- Total
- Percentage
- Ranking
- Tie-breaking
- Advancement
- Finalists

## Phase 10

Dashboard:

- Event dashboard
- Centre dashboard
- Management dashboard
- Analytics

## Phase 11

Evidence:

- Upload
- Storage
- Verification
- Attendance

## Phase 12

Reports:

- CSV
- Excel-compatible exports
- Result reports
- Centre reports

## Phase 13

Audit:

- Audit logs
- Version history
- Unlock history

## Phase 14

Testing:

- Functional
- Security
- RLS
- Mobile
- Performance

## Phase 15

Deployment:

- GitHub Pages
- Supabase production configuration
- Final security review

---

# 79. Development Rule for AI Coding Agent

The AI coding agent MUST follow these rules:

1. Read this SRS before making implementation decisions.
2. Do not hard-code the 2026 event structure into the application.
3. Build reusable components.
4. Build database-first relationships.
5. Use Supabase RLS.
6. Never expose the Supabase service-role key.
7. Do not implement security only in frontend JavaScript.
8. Keep business rules configurable.
9. Keep assessment criteria configurable.
10. Keep advancement rules configurable.
11. Keep event/stage/assessment dates configurable.
12. Preserve historical data.
13. Use soft deletion where appropriate.
14. Add audit logs for important changes.
15. Validate data both frontend and database/backend.
16. Do not silently delete or overwrite records.
17. Use confirmation dialogs for destructive operations.
18. Keep code modular.
19. Keep UI responsive.
20. Do not create unnecessary dependencies.
21. Do not modify the database schema without updating `database/schema.sql`.
22. Do not change business rules without documenting the change.
23. Test RLS policies before considering a feature complete.
24. Use meaningful variable and function names.
25. Keep README and documentation updated.

---

# 80. Definition of Done

A feature is considered complete only when:

```text
UI complete
    +
Database complete
    +
Validation complete
    +
RLS complete
    +
Error handling complete
    +
Audit logging complete where required
    +
Mobile responsive
    +
Tested
```

A UI-only implementation is NOT considered complete.

---

# 81. First Event Seed Data

The initial system should contain the following event as seed/configuration data:

```text
Event:
GyanTantra se Saksharta – Class V Literacy Challenge 2026

Type:
Competition

Class:
V

Stage 1:
Centre Level Screening

Stage 1 Assessments:
1. Spelling – 20
2. Writing – 20
3. Reading – 20

Stage 1 Total:
60

Advancement:
Top 5 per Centre

Stage 2:
Head Office Literacy Championship

Stage 2 assessments:
Configurable
```

The Stage 2 fourth assessment and final total must remain configurable because the source documents use different terminology/structure.

---

# 82. Important Business Rules for Initial Event

1. Only eligible Class V students can register.
2. Each student can have one registration per event unless explicitly configured otherwise.
3. Registration must be approved before assessment.
4. Stage 1 requires all three assessments for a complete result.
5. Maximum Stage 1 score is 60.
6. Top 5 per centre qualify by default.
7. Qualification must be reviewable before final confirmation.
8. Only confirmed finalists can enter Stage 2.
9. Scores must be verified before ranking is finalised.
10. Locked results cannot be modified without administrator override.
11. All overrides must be audited.

---

# 83. Future-Proofing Requirements

The system should be capable of supporting:

```text
Multiple events
Multiple years
Multiple classes
Multiple centres
Multiple assessment types
Multiple stages
Multiple scoring systems
Different advancement rules
Different judging models
Different event categories
```

The database should therefore always include `event_id` where data belongs to an event.

Do not create separate tables such as:

```text
literacy_2026_scores
literacy_2027_scores
```

Instead:

```text
assessment_scores
event_id
```

---

# 84. Recommended Architecture Summary

```text
                 FRONTEND
          HTML + CSS + JavaScript
                     │
                     ▼
              SUPABASE AUTH
                     │
                     ▼
              SUPABASE API
                     │
       ┌─────────────┼─────────────┐
       ▼             ▼             ▼
 PostgreSQL       Storage          RLS
       │             │
       ▼             ▼
 Event Engine      Evidence
       │
       ├── Events
       ├── Stages
       ├── Assessments
       ├── Criteria
       ├── Participants
       ├── Scores
       ├── Rankings
       ├── Advancement
       └── Results
                     │
                     ▼
             DASHBOARDS / REPORTS
```

---

# 85. Final Product Definition

The finished product should be understood as:

> **A reusable web-based Event, Competition and Assessment Management System for Literacy India.**

The 2026 GyanTantra Literacy Challenge is the first event configured within the platform.

The system must allow an authorised administrator to create a completely different event in the future without requiring a developer to modify application source code.

The core abstraction is:

```text
EVENT
  → STAGE
      → ASSESSMENT
          → CRITERIA
              → SCORE
      → ADVANCEMENT RULE
  → PARTICIPANTS
  → RESULTS
  → REPORTS
```

This architecture is the primary requirement of the project.

