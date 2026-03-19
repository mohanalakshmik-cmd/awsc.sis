-- ============================================================
-- AWS SIS — Supabase Database Schema
-- Run this in your Supabase SQL Editor to set up all tables.
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── PROFILES (user accounts linked to Supabase Auth) ────────
CREATE TABLE IF NOT EXISTS profiles (
  username   TEXT PRIMARY KEY,
  name       TEXT,
  role       TEXT NOT NULL DEFAULT 'staff',  -- admin | staff | principal | partner
  email      TEXT,
  campus     TEXT,
  active     BOOLEAN NOT NULL DEFAULT TRUE,
  lastlogin  TIMESTAMPTZ
);

-- ── STUDENTS ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS students (
  id              INTEGER PRIMARY KEY,
  studentId       TEXT,
  firstName       TEXT,
  lastName        TEXT,
  dob             TEXT,
  gender          TEXT,
  grade           TEXT,
  status          TEXT,
  appDate         TEXT,
  enrollDate      TEXT,
  email           TEXT,
  phone           TEXT,
  nationality     TEXT,
  lang            TEXT,
  parent          TEXT,
  relation        TEXT,
  ecName          TEXT,
  ecPhone         TEXT,
  address         TEXT,
  bloodGroup      TEXT,
  allergy         TEXT,
  meds            TEXT,
  physician       TEXT,
  physicianPhone  TEXT,
  healthNotes     TEXT,
  iep             TEXT,
  prevSchool      TEXT,
  gpa             TEXT,
  cohort          TEXT,
  documents       TEXT,   -- pipe-delimited list
  notes           TEXT,
  counselorNotes  TEXT,
  priority        TEXT,
  campus          TEXT,
  studentType     TEXT,
  intDate         TEXT,
  intViewer       TEXT,
  decNotes        TEXT,
  yearJoined      TEXT,
  yearGraduated   TEXT
);

-- ── COURSES (GMS) ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS courses (
  id               SERIAL PRIMARY KEY,
  studentId        INTEGER REFERENCES students(id) ON DELETE CASCADE,
  courseCode       TEXT,
  title            TEXT,
  type             TEXT,
  ag               TEXT,
  area             TEXT,
  semester         TEXT,
  year             TEXT,
  grade            TEXT,
  creditsAttempted NUMERIC DEFAULT 0,
  creditsEarned    NUMERIC DEFAULT 0,
  apScore          TEXT,
  transferFlag     BOOLEAN DEFAULT FALSE,
  notes            TEXT,
  UNIQUE(studentId, courseCode, semester, year)
);

-- ── TRANSFER CREDITS ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS transfer_credits (
  id            SERIAL PRIMARY KEY,
  studentId     INTEGER REFERENCES students(id) ON DELETE CASCADE,
  type          TEXT,
  title         TEXT,
  origTitle     TEXT,
  origGrade     TEXT,
  area          TEXT,
  creditsAwarded NUMERIC DEFAULT 0,
  sourceSchool  TEXT,
  status        TEXT,
  accred        TEXT,
  addedDate     TEXT,
  notes         TEXT
);

-- ── EC CREDITS (Dual Enrollment) ─────────────────────────────
CREATE TABLE IF NOT EXISTS ec_credits (
  id             SERIAL PRIMARY KEY,
  studentId      INTEGER,
  studentName    TEXT,
  grade          TEXT,
  courseTitle    TEXT,
  university     TEXT,
  area           TEXT,
  origGrade      TEXT,
  hsCredits      NUMERIC DEFAULT 0,
  multiplier     INTEGER DEFAULT 3,
  collegeCredits NUMERIC DEFAULT 0,
  status         TEXT,
  accreditation  TEXT,
  notes          TEXT,
  addedDate      TEXT
);

-- ── SETTINGS (single row with id='global') ───────────────────
CREATE TABLE IF NOT EXISTS settings (
  id            TEXT PRIMARY KEY DEFAULT 'global',
  academicYear  TEXT,
  campuses      JSONB,
  capacity      INTEGER,
  docs          JSONB,
  cohorts       JSONB,
  sidPrefix     TEXT,
  gradeScale    TEXT,
  emailNotif    TEXT,
  blocks        JSONB,
  logo          TEXT
);

-- ── ATTENDANCE ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS attendance (
  att_key   TEXT PRIMARY KEY,   -- format: YYYY-MM-DD_studentId
  studentId INTEGER,
  date      TEXT,
  status    TEXT,
  note      TEXT
);

-- ── INTERVIEWS ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS interviews (
  id        INTEGER PRIMARY KEY,
  studentId INTEGER REFERENCES students(id) ON DELETE CASCADE,
  date      TEXT,
  viewer    TEXT,
  status    TEXT,
  scores    JSONB,
  notes     TEXT
);

-- ── FEES ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS fees (
  id          INTEGER PRIMARY KEY,
  studentId   INTEGER REFERENCES students(id) ON DELETE CASCADE,
  type        TEXT,
  description TEXT,
  amount      NUMERIC DEFAULT 0,
  currency    TEXT DEFAULT 'USD',
  due         TEXT,
  paid        BOOLEAN DEFAULT FALSE,
  waived      BOOLEAN DEFAULT FALSE,
  paidDate    TEXT,
  notes       TEXT
);

-- ── COMMUNICATIONS ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS communications (
  id        INTEGER PRIMARY KEY,
  studentId INTEGER REFERENCES students(id) ON DELETE CASCADE,
  date      TEXT,
  type      TEXT,
  subject   TEXT,
  notes     TEXT,
  outcome   TEXT,
  staff     TEXT
);

-- ── TPMS LESSONS ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS tpms_lessons (
  id        TEXT PRIMARY KEY,
  title     TEXT,
  subject   TEXT,
  grade     TEXT,
  date      TEXT,
  duration  INTEGER,
  objectives TEXT,
  content   TEXT,
  resources TEXT,
  notes     TEXT,
  staff     TEXT
);

-- ── TPMS UNITS ───────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS tpms_units (
  id         TEXT PRIMARY KEY,
  title      TEXT,
  subject    TEXT,
  grade      TEXT,
  startDate  TEXT,
  endDate    TEXT,
  objectives TEXT,
  standards  TEXT,
  notes      TEXT,
  staff      TEXT
);

-- ── TPMS EVENTS ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS tpms_events (
  id       TEXT PRIMARY KEY,
  title    TEXT,
  date     TEXT,
  endDate  TEXT,
  type     TEXT,
  layer    TEXT,
  notes    TEXT,
  staff    TEXT
);

-- ── TPMS PROFESSIONAL DEVELOPMENT ────────────────────────────
CREATE TABLE IF NOT EXISTS tpms_pd (
  id       TEXT PRIMARY KEY,
  title    TEXT,
  date     TEXT,
  hours    NUMERIC DEFAULT 0,
  type     TEXT,
  provider TEXT,
  notes    TEXT,
  staff    TEXT
);

-- ── STAFF DIRECTORY ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS staff (
  id          SERIAL PRIMARY KEY,
  name        TEXT,
  email       TEXT,
  phone       TEXT,
  role        TEXT,
  staffType   TEXT,
  subjects    TEXT,
  campus      TEXT,
  startDate   TEXT,
  notes       TEXT
);

-- ── COURSE CATALOG ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS catalog (
  code    TEXT PRIMARY KEY,
  title   TEXT,
  type    TEXT,
  area    TEXT,
  credits NUMERIC DEFAULT 1,
  grade   TEXT
);

-- ── REPORT CARD REMARKS ───────────────────────────────────────
CREATE TABLE IF NOT EXISTS remarks (
  studentId TEXT,
  term      TEXT,
  remarks   TEXT,
  PRIMARY KEY (studentId, term)
);

-- ── CALENDAR ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS calendar (
  id      TEXT PRIMARY KEY,
  title   TEXT,
  date    TEXT,
  endDate TEXT,
  type    TEXT,
  layer   TEXT,
  notes   TEXT
);

-- ── HEALTH RECORDS ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS health (
  id        SERIAL PRIMARY KEY,
  studentId INTEGER REFERENCES students(id) ON DELETE CASCADE,
  date      TEXT,
  type      TEXT,
  notes     TEXT,
  staff     TEXT
);

-- ── BEHAVIOUR LOG ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS behaviour (
  id        SERIAL PRIMARY KEY,
  studentId INTEGER REFERENCES students(id) ON DELETE CASCADE,
  date      TEXT,
  type      TEXT,
  severity  TEXT,
  notes     TEXT,
  action    TEXT,
  staff     TEXT
);

-- ── ASSIGNMENT TRACKER ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS at_assignments (
  id         TEXT PRIMARY KEY,
  title      TEXT,
  subject    TEXT,
  grade      TEXT,
  dueDate    TEXT,
  points     NUMERIC DEFAULT 0,
  notes      TEXT,
  staff      TEXT
);

CREATE TABLE IF NOT EXISTS at_notes (
  id        TEXT PRIMARY KEY,
  subject   TEXT,
  grade     TEXT,
  date      TEXT,
  notes     TEXT,
  staff     TEXT
);

CREATE TABLE IF NOT EXISTS at_reports (
  id      TEXT PRIMARY KEY,
  date    TEXT,
  type    TEXT,
  content TEXT,
  staff   TEXT
);

-- ── PROJECT TRACKER (AWSC-27) ─────────────────────────────────
CREATE TABLE IF NOT EXISTS pt_assignments (
  id         TEXT PRIMARY KEY,
  title      TEXT,
  studentId  INTEGER,
  dueDate    TEXT,
  status     TEXT,
  notes      TEXT
);

CREATE TABLE IF NOT EXISTS pt_evaluations (
  id          TEXT PRIMARY KEY,
  assignmentId TEXT,
  studentId   INTEGER,
  score       NUMERIC DEFAULT 0,
  feedback    TEXT,
  date        TEXT
);

-- ── KEY-VALUE STORE (for blobs like AT submissions) ──────────
CREATE TABLE IF NOT EXISTS kv_store (
  key   TEXT PRIMARY KEY,
  value TEXT
);

-- ============================================================
-- ROW LEVEL SECURITY (RLS)
-- Enable RLS and create policies for authenticated users.
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE profiles          ENABLE ROW LEVEL SECURITY;
ALTER TABLE students          ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses           ENABLE ROW LEVEL SECURITY;
ALTER TABLE transfer_credits  ENABLE ROW LEVEL SECURITY;
ALTER TABLE ec_credits        ENABLE ROW LEVEL SECURITY;
ALTER TABLE settings          ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance        ENABLE ROW LEVEL SECURITY;
ALTER TABLE interviews        ENABLE ROW LEVEL SECURITY;
ALTER TABLE fees              ENABLE ROW LEVEL SECURITY;
ALTER TABLE communications    ENABLE ROW LEVEL SECURITY;
ALTER TABLE tpms_lessons      ENABLE ROW LEVEL SECURITY;
ALTER TABLE tpms_units        ENABLE ROW LEVEL SECURITY;
ALTER TABLE tpms_events       ENABLE ROW LEVEL SECURITY;
ALTER TABLE tpms_pd           ENABLE ROW LEVEL SECURITY;
ALTER TABLE staff             ENABLE ROW LEVEL SECURITY;
ALTER TABLE catalog           ENABLE ROW LEVEL SECURITY;
ALTER TABLE remarks           ENABLE ROW LEVEL SECURITY;
ALTER TABLE calendar          ENABLE ROW LEVEL SECURITY;
ALTER TABLE health            ENABLE ROW LEVEL SECURITY;
ALTER TABLE behaviour         ENABLE ROW LEVEL SECURITY;
ALTER TABLE at_assignments    ENABLE ROW LEVEL SECURITY;
ALTER TABLE at_notes          ENABLE ROW LEVEL SECURITY;
ALTER TABLE at_reports        ENABLE ROW LEVEL SECURITY;
ALTER TABLE pt_assignments    ENABLE ROW LEVEL SECURITY;
ALTER TABLE pt_evaluations    ENABLE ROW LEVEL SECURITY;
ALTER TABLE kv_store          ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users full access to all tables
-- (Refine these policies as needed for role-based restrictions)
DO $$
DECLARE
  tbl TEXT;
  tbls TEXT[] := ARRAY[
    'profiles','students','courses','transfer_credits','ec_credits','settings',
    'attendance','interviews','fees','communications','tpms_lessons','tpms_units',
    'tpms_events','tpms_pd','staff','catalog','remarks','calendar','health',
    'behaviour','at_assignments','at_notes','at_reports','pt_assignments',
    'pt_evaluations','kv_store'
  ];
BEGIN
  FOREACH tbl IN ARRAY tbls LOOP
    EXECUTE format('
      CREATE POLICY IF NOT EXISTS "auth_all_%s" ON %I
        FOR ALL TO authenticated USING (true) WITH CHECK (true);
    ', tbl, tbl);
  END LOOP;
END $$;

-- ============================================================
-- HOW TO CREATE USERS
-- In Supabase dashboard: Authentication → Users → Invite User
-- Then set user metadata for role/name via:
--   UPDATE auth.users SET raw_user_meta_data = raw_user_meta_data ||
--   '{"role":"admin","name":"Admin User","campus":""}'::jsonb
--   WHERE email = 'admin@yourschool.edu';
--
-- Or insert into profiles after creating the auth user:
--   INSERT INTO profiles (username, name, role, email)
--   VALUES ('admin', 'Admin User', 'admin', 'admin@yourschool.edu');
-- ============================================================
