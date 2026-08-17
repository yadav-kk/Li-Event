# Literacy India Event & Assessment Management Portal

A generic, configuration-driven web application for managing academic events, literacy challenges, student registration, and assessor scoring. Designed for **Literacy India**, with first baseline support for the **GyanTantra se Saksharta – Class V Literacy Challenge 2026**.

## Architecture Overview
The portal is built around a flexible, database-first relational model:
$$\text{Event} \rightarrow \text{Stage} \rightarrow \text{Assessment} \rightarrow \text{Criteria} \rightarrow \text{Scores}$$

- **Frontend**: Single-page dashboards and wizards built with vanilla HTML5, CSS3 variables, and ES6 modular JavaScript. Fully mobile responsive.
- **Backend-as-a-Service**: Supabase.
- **Security**: PostgreSQL Row Level Security (RLS) policies enforcing role isolation (Super Admin, Programme Admin, Centre In-Charge, Judge).

---

## Database Setup & Deployment

To initialize the backend, copy the contents of the SQL scripts in the `/database/` directory and execute them in your Supabase Project **SQL Editor** in this order:

1. **`database/schema.sql`**: Creates the public tables, schemas, relations, and indexes.
2. **`database/functions.sql`**: Declares calculation rules, triggers, auditing, and ranking/advancement functions.
3. **`database/triggers.sql`**: Binds functions to tables for automatic updated-at stamps, auth sync, total sum aggregates, and validation checks.
4. **`database/rls.sql`**: Enforces strict row-level security.
5. **`database/seed.sql`**: Seeds default roles, sample centres/schools/students, and configures the default **Class V Literacy Challenge 2026** structure.

---

## Local Setup & Run

1. Clone or pull the repository locally.
2. Double-click `index.html` to run in any browser, or spin up a simple static web server:
   ```bash
   npx serve .
   ```
3. The project connects to the Supabase instance using credentials defined in `assets/js/supabase.js`.

---

## User Roles in Portal
- **Super Administrator**: Full controls. Creates/edits events, overrides locks, runs audit checks.
- **Centre In-Charge**: Manages student registrations, attendance, and evidence uploads for their assigned centre.
- **Judge / Assessor**: Evaluates assigned students, saves score drafts, and submits finalized score matrices.
- **Academic Lead**: Configures parameters and confirms Stage 1 screening totals.
