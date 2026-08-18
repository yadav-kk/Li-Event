# System Implementation Checklist

Below is the verified checklist of all database modules, security features, and functional views implemented within the **Literacy India Event & Assessment Management Portal**.

---

## 💾 Core Infrastructure & Database Setup
- [x] **PostgreSQL Database Schema**: Setup of tables, primary/foreign keys, check constraints, and cascading deletions (`database/schema.sql`).
- [x] **Relational Joins**: PostgREST endpoints set up for nested queries (`centres`, `user_roles`, `user_centres`, `event_participants`).
- [x] **Database Performance Indexing**: Optimization indexes for quick filter routing (`idx_students_centre`, `idx_participants_student`, etc.).
- [x] **Seeded Datasets**: Pre-loaded roles, school types, and 13 operational Delhi, Noida, and Gurugram centres (`database/seed.sql`, `database/setup_all.sql`).
- [x] **Row Level Security (RLS)**: Contextual row restriction policies (`database/rls.sql`).

---

## 🔑 Authentication & Role Security
- [x] **Direct Credentials Authentication**: Custom validation against `public.users` plain text passwords (`assets/js/auth.js`).
- [x] **Secure Route Guards**: Redirects non-logged-in or unauthorized requests to `login.html`.
- [x] **Security Role Matrix**: Integrated permission tokens for:
  - `super_admin` (Full control)
  - `prog_admin` (Program control)
  - `coordinator` (Multi-centre oversight)
  - `centre_incharge` (Single centre operator)
  - `judge` (Assessments grader)
  - `management` (Read-only viewer)

---

## 👥 User & Access Directory
- [x] **Refactored Portal User Grid**: Responsive full-width grid layout matching student directory (`pages/users.html`).
- [x] **Toggleable Account Panel**: Modal card configuration for adding/editing users (`#userModal`).
- [x] **User Editing Actions**: Edit trigger pre-filling credentials, roles, and centre associations.
- [x] **Coordinator Multi-Choice dropdown**: Custom checkbox dropdown displaying only for `coordinator` role, saving selections to `public.user_centres`.
- [x] **Role-Based Centre Validation**:
  - `centre_incharge` must have exactly one centre assigned.
  - `coordinator` must have at least one centre assigned.

---

## 🧑‍🎓 Student Directory & Registrations
- [x] **Single Student Registration**: Modal form supporting Name, Gender, Class selection, Centre, School, and Language (`pages/students.html`).
- [x] **Excel/CSV Bulk Import**: Excel file parser with status progress bar mapping parsed students dynamically.
- [x] **Download Sample Template**: Single-click button creating mock CSV structure based on fields.
- [x] **Role-Based Action Controls**:
  - `centre_incharge` can edit student details.
  - `coordinator` and program admins can delete student records.

---

## 🏆 Event Builder & Configurations
- [x] **Configuration Wizard**: Set event code, target class options, academic year, and status (`pages/event-builder.html`).
- [x] **Sequential Phases Builder**: Define multi-stage timeline dates, sequence numbers, and venues.
- [x] **Advancement Rules engine**: Configures criteria (e.g. TOP_N_OVERALL, TOP_N_PER_CENTRE) to automatically qualify students for the next stage.
- [x] **Assessment & Criteria breakdown**: Allocates maximum marks and builds subscores criteria configurations.

---

## 📝 Grading & Evaluation Portal
- [x] **Assessment Selection Roster**: Filters students based on phase stages and centres (`pages/score-entry.html`).
- [x] **Dynamic Subscores Grids**: Renders spreadsheet grids mapping marks against configured assessment criteria.
- [x] **Status Locking & Draft Save**: Allows judges to save marks as `DRAFT` or submit as `SUBMITTED`, preventing edits once locked.

---

## 📂 Evidence & Verification Trail
- [x] **File Attachment Uploads**: Supports uploading PDF answer sheets, images, and videos directly to Supabase storage buckets (`pages/evidence.html`).
- [x] **Evidence Registry Table**: Renders upload dates, files, and uploader identities.
- [x] **Admin Verification**: Toggles verification status between `PENDING`, `VERIFIED`, and `REJECTED`.
