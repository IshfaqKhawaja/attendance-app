-- =====================================================
-- Attendance Management System - Database Initialization
-- =====================================================
-- This script creates all required tables and enums
-- UPDATED to match existing column naming conventions
-- Compatible with your existing backend code
-- =====================================================

-- Create custom enum types
-- =====================================================

-- Teacher type enum
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'teacher_type') THEN
    CREATE TYPE teacher_type AS ENUM ('PERMANENT', 'GUEST', 'CONTRACT');
  END IF;
END $$;

-- User type enum
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_type') THEN
    CREATE TYPE user_type AS ENUM ('NORMAL', 'HOD', 'SUPER_ADMIN');
  END IF;
END $$;

-- Create tables in dependency order
-- =====================================================

-- 1. Faculty table (top-level entity)
CREATE TABLE IF NOT EXISTS faculty (
  fact_id   VARCHAR(255) PRIMARY KEY,
  fact_name VARCHAR(255) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Department table (references faculty)
CREATE TABLE IF NOT EXISTS department (
  dept_id   VARCHAR(255) PRIMARY KEY,
  dept_name VARCHAR(255) NOT NULL,
  fact_id   VARCHAR(255) NOT NULL
             REFERENCES faculty(fact_id)
             ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Program table (references department)
CREATE TABLE IF NOT EXISTS program (
  prog_id   VARCHAR(255) PRIMARY KEY,
  prog_name VARCHAR(255) NOT NULL,
  dept_id   VARCHAR(255) NOT NULL
             REFERENCES department(dept_id)
             ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Semester table (references program)
CREATE TABLE IF NOT EXISTS semester (
  sem_id       VARCHAR(255) PRIMARY KEY,
  sem_name     VARCHAR(100) NOT NULL,
  start_date   DATE NOT NULL,
  end_date     DATE NOT NULL,
  prog_id      VARCHAR(255) NOT NULL
               REFERENCES program(prog_id)
               ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Teachers table (references department)
CREATE TABLE IF NOT EXISTS teachers (
  teacher_id   VARCHAR(255) PRIMARY KEY,
  teacher_name VARCHAR(255) NOT NULL,
  type         teacher_type NOT NULL,
  dept_id      VARCHAR(255) NOT NULL
              REFERENCES department(dept_id)
              ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Students table (references semester)
CREATE TABLE IF NOT EXISTS students (
  student_id   VARCHAR(255) PRIMARY KEY,
  student_name VARCHAR(255) NOT NULL,
  phone_number BIGINT,
  sem_id       VARCHAR(255) REFERENCES semester(sem_id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. Course table (references semester)
CREATE TABLE IF NOT EXISTS course (
  course_id    VARCHAR(255) PRIMARY KEY,
  course_name  VARCHAR(255) NOT NULL,
  sem_id       VARCHAR(255) NOT NULL
              REFERENCES semester(sem_id)
              ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. Student Enrollment table (many-to-many: students and semesters)
CREATE TABLE IF NOT EXISTS student_enrollment (
  student_id  VARCHAR(255) NOT NULL
              REFERENCES students(student_id)
              ON DELETE CASCADE,
  sem_id      VARCHAR(255) NOT NULL
              REFERENCES semester(sem_id)
              ON DELETE CASCADE,
  PRIMARY KEY (student_id, sem_id)
);

-- 9. Teacher-Course mapping (many-to-many)
CREATE TABLE IF NOT EXISTS teacher_course (
  teacher_id  VARCHAR(255) NOT NULL
             REFERENCES teachers(teacher_id)
             ON DELETE CASCADE,
  course_id   VARCHAR(255) NOT NULL
             REFERENCES course(course_id)
             ON DELETE CASCADE,
  PRIMARY KEY (teacher_id, course_id)
);

-- 10. Course-Students mapping (many-to-many)
-- Note: Table name is 'course_student' (singular) to match existing code
CREATE TABLE IF NOT EXISTS course_student (
  student_id   VARCHAR(255) NOT NULL
              REFERENCES students(student_id)
              ON DELETE CASCADE,
  course_id    VARCHAR(255) NOT NULL
              REFERENCES course(course_id)
              ON DELETE CASCADE,
  PRIMARY KEY (student_id, course_id)
);

-- 11. Attendance table (references students and courses)
CREATE TABLE IF NOT EXISTS attendance (
  attendance_id  SERIAL PRIMARY KEY,
  student_id     VARCHAR(255) NOT NULL
                  REFERENCES students(student_id)
                  ON DELETE CASCADE,
  course_id      VARCHAR(255) NOT NULL
                  REFERENCES course(course_id)
                  ON DELETE CASCADE,
  date           DATE NOT NULL,
  present        BOOLEAN NOT NULL DEFAULT FALSE,
  created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 12. Users table (for authentication and authorization)
CREATE TABLE IF NOT EXISTS users (
  user_id      VARCHAR(255) PRIMARY KEY,
  user_name    VARCHAR(255) NOT NULL,
  type         user_type NOT NULL,
  dept_id      VARCHAR(255)
               REFERENCES department(dept_id)
               ON DELETE SET NULL,
  fact_id      VARCHAR(255)
               REFERENCES faculty(fact_id)
               ON DELETE SET NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 13. OTP Storage table (for authentication)
CREATE TABLE IF NOT EXISTS otp_storage (
  email          VARCHAR(255) PRIMARY KEY,
  otp            VARCHAR(6) NOT NULL,
  created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at     TIMESTAMP NOT NULL,
  attempts       INTEGER DEFAULT 0
);

-- Create indexes for better query performance
-- =====================================================

-- Indexes for foreign key lookups
CREATE INDEX IF NOT EXISTS idx_department_fact_id ON department(fact_id);
CREATE INDEX IF NOT EXISTS idx_program_dept_id ON program(dept_id);
CREATE INDEX IF NOT EXISTS idx_semester_prog_id ON semester(prog_id);
CREATE INDEX IF NOT EXISTS idx_teachers_dept_id ON teachers(dept_id);
CREATE INDEX IF NOT EXISTS idx_students_sem_id ON students(sem_id);
CREATE INDEX IF NOT EXISTS idx_course_sem_id ON course(sem_id);
CREATE INDEX IF NOT EXISTS idx_attendance_student_id ON attendance(student_id);
CREATE INDEX IF NOT EXISTS idx_attendance_course_id ON attendance(course_id);
CREATE INDEX IF NOT EXISTS idx_attendance_date ON attendance(date);
CREATE INDEX IF NOT EXISTS idx_users_dept_id ON users(dept_id);
CREATE INDEX IF NOT EXISTS idx_users_fact_id ON users(fact_id);

-- Index for OTP cleanup queries
CREATE INDEX IF NOT EXISTS idx_otp_expires_at ON otp_storage(expires_at);

-- Composite indexes for common queries
CREATE INDEX IF NOT EXISTS idx_attendance_course_date ON attendance(course_id, date);
CREATE INDEX IF NOT EXISTS idx_attendance_student_course ON attendance(student_id, course_id);
CREATE INDEX IF NOT EXISTS idx_teacher_course_teacher ON teacher_course(teacher_id);
CREATE INDEX IF NOT EXISTS idx_teacher_course_course ON teacher_course(course_id);
CREATE INDEX IF NOT EXISTS idx_course_student_course ON course_student(course_id);
CREATE INDEX IF NOT EXISTS idx_course_student_student ON course_student(student_id);

-- Success message
SELECT 'Database schema initialized successfully!' AS status;
SELECT 'Column names match existing backend code (fact_id, teacher_id, etc.)' AS compatibility;
