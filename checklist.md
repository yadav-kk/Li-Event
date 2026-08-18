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
  - `super_admin` (Full CRUD control)
  - `prog_admin` (Program CRUD control)
  - `coordinator` (Multi-centre oversight and deletion)
  - `centre_incharge` (Single centre operator and editing)
  - `judge` (Assessments grader)
  - `management` (Read-only viewer)

---

## 👥 User & Access Directory
- [x] **Refactored Portal User Grid**: Responsive full-width grid layout matching participant directory (`pages/users.html`).
- [x] **Toggleable Account Panel**: Modal card configuration for adding/editing users (`#userModal`).
- [x] **User CRUD Operations**: Admins can Create, Read, Update, and cascadingly **Delete** user accounts.
- [x] **Coordinator Multi-Choice dropdown**: Custom checkbox dropdown displaying only for `coordinator` role, saving selections to `public.user_centres`.
- [x] **Role-Based Centre Validation**:
  - `centre_incharge` must have exactly one centre assigned.
  - `coordinator` must have at least one centre assigned.

---

## 🧑‍🎓 Participant Directory & Registrations
- [x] **Single Participant Registration**: Modal form supporting Name, Gender, DOB, Centre, Program, and Language (`pages/students.html`).
- [x] **Excel/CSV Bulk Import**: Excel file parser mapping parsed participants dynamically.
- [x] **Download Sample Template**: Single-click button creating mock CSV structure based on fields.
- [x] **Role-Based Action Controls**:
  - `centre_incharge` and admins can edit participant details.
  - `coordinator` and admins can delete participant records.

---

## 🏢 Centres & Program Configurations
- [x] **Centres CRUD Operations**: Admins can Create, Read, Update, and cascadingly **Delete** learning centres (`pages/centres.html`).
- [x] **Programs mapping per Centre**: Replaced traditional "Schools" with "Programs" (e.g. *Smart Class/Pathashala*, *Basic IT*, *Vocational*, *Gyantantra*), managed dynamically inside each centre's workspace.

---

## 🏆 Event Builder & Configurations
- [x] **Configuration Wizard**: Set event code, academic year, and status (`pages/event-builder.html`).
- [x] **Sequential Phases Builder**: Define multi-stage timeline dates, sequence numbers, and venues.
- [x] **Advancement Rules engine**: Configures criteria (e.g. TOP_N_OVERALL, TOP_N_PER_CENTRE) to automatically qualify participants for the next stage.
- [x] **Assessment & Criteria breakdown**: Allocates maximum marks and builds subscores criteria configurations.

---

## 📝 Grading & Evaluation Portal
- [x] **Assessment Selection Roster**: Filters participants based on phase stages and centres (`pages/score-entry.html`).
- [x] **Dynamic Subscores Grids**: Renders spreadsheet grids mapping marks against configured assessment criteria.
- [x] **Status Locking & Draft Save**: Allows judges to save marks as `DRAFT` or submit as `SUBMITTED`, preventing edits once locked.

---

## 📂 Evidence & Verification Trail
- [x] **File Attachment Uploads**: Supports uploading PDF answer sheets, images, and videos directly to Supabase storage buckets (`pages/evidence.html`).
- [x] **Evidence Registry Table**: Renders upload dates, files, and uploader identities.
- [x] **Admin Verification**: Toggles verification status between `PENDING`, `VERIFIED`, and `REJECTED` for both super_admin and prog_admin.

---

## 📱 Mobile Responsiveness & Optimization
- [x] **Universal Menu Toggle Drawer**: Dynamically injected menu-toggle hamburger button inside `permissions.js`, facilitating sidebar toggling on mobile viewports.
- [x] **Click-Away Close Behavior**: Instantly closes mobile sidebar drawer when clicking the main content canvas.
- [x] **Responsive CSS Grid Layouts**: Tables and forms scale dynamically across small viewports (`assets/css/responsive.css`).
