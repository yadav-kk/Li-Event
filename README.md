# Literacy India Event & Assessment Management Portal

A generic, configuration-driven web application for managing academic events, literacy challenges, student registration, and assessor scoring. Designed for **Literacy India**, with first baseline support for the **GyanTantra se Saksharta – Class V Literacy Challenge 2026**.

---

## 📖 Portal Documentation Index

To explore the architecture, database schema, and operational specifications of this system, refer to:
* **[Software Requirements Specification (SRS.md)](file:///d:/Projects/Complitions/Compitition%20new/SRS.md)**: Detailed functional specs, user dashboard rules, and assessment calculations.
* **[Systems Infrastructure & Setup (infrastructure.md)](file:///d:/Projects/Complitions/Compitition%20new/infrastructure.md)**: Hosting configurations, client authentication flows, and security details.
* **[Database Schema Documentation (structure.md)](file:///d:/Projects/Complitions/Compitition%20new/structure.md)**: Relational tables structure, primary/foreign keys, types, and database index listings.

---

## 🛠️ Architecture Overview

The portal is built around a flexible, database-first relational model:
$$\text{Event} \rightarrow \text{Stage} \rightarrow \text{Assessment} \rightarrow \text{Criteria} \rightarrow \text{Scores}$$

* **Frontend**: Responsive single-page dashboards built with vanilla HTML5, CSS3 variable design tokens, and ES6 modular JavaScript.
* **Backend-as-a-Service**: Supabase BaaS (Database, Storage, Auth routing).
* **Security**: PostgreSQL Row Level Security (RLS) policies enforcing role isolation (Super Admin, Programme Admin, Coordinator, Centre In-Charge, Judge).

---

## 💾 Database Setup & Deployment

To initialize the backend, copy the contents of the SQL scripts in the `/database/` directory and execute them in your Supabase Project **SQL Editor** in this order:

1. **`database/schema.sql`**: Creates the public tables, schemas, relations, and indexes.
2. **`database/functions.sql`**: Declares calculation rules, triggers, auditing, and ranking/advancement functions.
3. **`database/triggers.sql`**: Binds functions to tables for automatic updated-at stamps, auth sync, total sum aggregates, and validation checks.
4. **`database/rls.sql`**: Enforces strict row-level security.
5. **`database/seed.sql`**: Seeds default roles, sample centres (Delhi, Gurugram, Noida), schools, students, and configures the default **Class V Literacy Challenge 2026** structure.

---

## 💻 Local Setup & Run

1. Clone or pull the repository locally.
2. Double-click `index.html` to run in any browser, or spin up a simple static web server:
   ```bash
   npx serve .
   ```
3. The project connects to the Supabase instance using credentials defined in `assets/js/supabase.js`.

---

## 👥 Security Access Roles Matrix

* **Super Administrator**: Full controls. Creates/edits events, configures grading stages, overrides locks, runs audit checks.
* **Programme Administrator**: Full program dashboard oversight, manages user role registries, seeds centers and schools.
* **Coordinator**: Manages multiple centres (assigned using the multi-choice dropdown group). Has permissions to **Delete** student records.
* **Centre Incharge**: Manages student enrollments, details, language/class choices, and evidence uploads for their assigned center. Has permissions to **Edit** student profiles.
* **Judge / Assessor**: Evaluates assigned students, saves score drafts, and submits finalized score matrices.
