# Literacy India Event Portal - Functional Report

This report outlines all the system functions, features, calculations, workflows, and access controls implemented across the modules of the **Literacy India Event & Assessment Management Portal**.

---

## 1. Authentication & Session Module

* **Functional Scope**: Handles identity validation and secure access control.
* **Core Functions**:
  * **Login Credentials Validation**: Verifies username (email) and password against the custom credentials database table. Saves session data inside local browser cache to avoid re-login latency.
  * **Auth Route Guards**: Intercepts DOM loads. Checks the user's role parameters against authorization parameters.
  * **Dynamic Navigation Builder**: Generates side navigation links matching the authenticated user's permissions (e.g. hides the Event Builder for Assessor judges).

---

## 2. Portal User Management Module

* **Functional Scope**: Administrative panel for directory controls, roles, and centre permissions.
* **Core Functions**:
  * **Unified Grid Layout**: User roster table with name, email, role, associated centre(s), and account status.
  * **Account Creator Modal**: Hidden-by-default card form to register new users or update credentials.
  * **Edit Mode Controller**: Clicking Edit pre-fills all user profile fields.
  * **Coordinator Multi-Choice dropdown**:
    * Dynamically displays when the role `coordinator` is selected.
    * Uses a custom checkbox toggle group to select one or more operational centres.
    * Updates are synced to the `public.user_centres` database mapping table.
  * **Security Rules Validation**:
    * Forces validation: Centre Incharges must have exactly one centre.
    * Forces validation: Coordinators must have at least one centre.

---

## 3. Student Enrollment & Directory Module

* **Functional Scope**: Student registration, rosters, bulk uploading, and action management.
* **Core Functions**:
  * **Single Registration Wizard**: Registers a student under a selected event. Populates classes dynamically based on targeted classes of the chosen event. Populates school choices based on the chosen centre.
  * **CSV Bulk Enrollment Parser**:
    * Parses comma-separated student lists client-side.
    * Maps columns to student attributes (ID, Name, DOB, Gender, Class, Language, School, Guardian Details).
    * Includes a **Download Sample Template** action button to generate structured mock CSV templates.
  * **Role-Based Registry Actions**:
    * **Edit Students**: Only visible and accessible to `centre_incharge` (and higher admins) to update profile credentials.
    * **Delete Students**: Only visible and accessible to `coordinator` (and higher admins) to remove a student and clean database cascades.

---

## 4. Event & Assessment Configurator Module

* **Functional Scope**: Wizard for constructing events, grading rules, stages, and assessments.
* **Core Functions**:
  * **Event Creator**: Configures event code, objective, venue, and target classes.
  * **Sequential Stages Builder**: Creates stages/phases (e.g. Phase 1 Screening, Phase 2 Finale) with individual start/end dates.
  * **Evaluation Parameters Configurator**: Creates assessments (e.g. Oral Reading test) within stages, setting maximum marks and sequence numbers.
  * **Criteria Breakdown Constructor**: Adds nested criteria (e.g. Pronunciation, Speed) mapping specific maximum sub-marks.
  * **Advancement Rules Engine**: Configures how students qualify for subsequent stages (e.g. `TOP_N_PER_CENTRE` or `SCORE_THRESHOLD`).

---

## 5. Grading & Marksheet Module

* **Functional Scope**: Assessor score grids, draft saves, and locking.
* **Core Functions**:
  * **Assessor Marksheets**: Displays student lists filtered by event, stage, and centre.
  * **Subscores Input Sheet**: Renders assessment criteria inputs to allow judges to input sub-marks.
  * **Auto-Sum Aggregation**: Dynamically sums sub-marks on input change, highlighting inputs exceeding maximum marks.
  * **Draft Saving / Submission**:
    * **Save Draft**: Saves scores under `DRAFT` status, allowing future editing.
    * **Submit**: Submits scorecard under `SUBMITTED` status, locking inputs to prevent further modifications.

---

## 6. Digital Evidence & Document Trail Module

* **Functional Scope**: Archival repository for grading sheets, media, and uploads.
* **Core Functions**:
  * **BaaS Bucket Upload**: Uploads answer sheets, videos, or audio directly to Supabase storage.
  * **Evidence Metadata Sync**: Records the uploaded file paths against corresponding student ID, event, and stage.
  * **Verification Controls**: Administrators review file records and toggle verification statuses (`PENDING`, `VERIFIED`, `REJECTED`).
