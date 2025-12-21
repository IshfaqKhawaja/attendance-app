"""
Create the following schema in PostgreSQL (DDL strings only):

  FACULTY
  DEPARTMENT
  PROGRAM
  SEMESTER
  TEACHER (with enum Type)
  COURSE
  STUDENT
  ATTENDANCE
  STUDENT_ENROLLMENT

Expose `statements` as a module-level list of SQL strings.
This module does not perform any DB connections or execution on import.
"""

# 1) create enums and tables in dependency order
statements = [
    # --- ENUMS ---
    # Create all custom types at the beginning for clarity.
    """
    DO $$ BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'teacher_type') THEN
            CREATE TYPE teacher_type AS ENUM ('PERMANENT', 'GUEST', 'CONTRACT');
        END IF;
    END $$;
    """,
    """
    DO $$ BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_type') THEN
            CREATE TYPE user_type AS ENUM ('NORMAL', 'HOD', 'DEAN', 'SUPER_ADMIN');
        ELSE
            -- Add DEAN to existing enum if it doesn't exist
            IF NOT EXISTS (SELECT 1 FROM pg_enum WHERE enumlabel = 'DEAN' AND enumtypid = (SELECT oid FROM pg_type WHERE typname = 'user_type')) THEN
                ALTER TYPE user_type ADD VALUE 'DEAN' AFTER 'HOD';
            END IF;
        END IF;
    END $$;
    """,

    # --- TABLES ---

    # faculty (no dependencies)
    """
    CREATE TABLE IF NOT EXISTS faculty (
        fact_id   VARCHAR(255) PRIMARY KEY,
        fact_name     VARCHAR(255) NOT NULL
    );
    """,

    # department → faculty
    """
    CREATE TABLE IF NOT EXISTS department (
        dept_id   VARCHAR(255) PRIMARY KEY,
        dept_name     VARCHAR(255) NOT NULL,
        fact_id   VARCHAR(255) NOT NULL REFERENCES faculty(fact_id) ON DELETE CASCADE
    );
    """,

    # program → department
    """
    CREATE TABLE IF NOT EXISTS program (
        prog_id   VARCHAR(255) PRIMARY KEY,
        prog_name     VARCHAR(255) NOT NULL,
        dept_id   VARCHAR(255) NOT NULL REFERENCES department(dept_id) ON DELETE CASCADE
    );
    """,

    # semester → program
    """
    CREATE TABLE IF NOT EXISTS semester (
        sem_id       VARCHAR(255) PRIMARY KEY,
        sem_name        VARCHAR(100) NOT NULL,
        start_date  DATE NOT NULL,
        end_date    DATE NOT NULL,
        prog_id      VARCHAR(255) NOT NULL REFERENCES program(prog_id) ON DELETE CASCADE
    );
    """,

    # teacher → department
    """
    CREATE TABLE IF NOT EXISTS teachers (
        teacher_id   VARCHAR(255) PRIMARY KEY,
        teacher_name        VARCHAR(255) NOT NULL,
        type        teacher_type NOT NULL,
        dept_id      VARCHAR(255) NOT NULL REFERENCES department(dept_id) ON DELETE CASCADE
    );
    """,

    # student → semester
    """
    CREATE TABLE IF NOT EXISTS students (
        student_id   VARCHAR(255) PRIMARY KEY,
        student_name        VARCHAR(255) NOT NULL,
        phone_number BIGINT,
        sem_id      VARCHAR(255) REFERENCES semester(sem_id) ON DELETE CASCADE
    );
    """,

    # course → semester
    """
    CREATE TABLE IF NOT EXISTS course (
        course_id    VARCHAR(255) PRIMARY KEY,
        course_name        VARCHAR(255) NOT NULL,
        sem_id       VARCHAR(255) NOT NULL REFERENCES semester(sem_id) ON DELETE CASCADE
    );
    """,

    # student_enrollment
    """
    CREATE TABLE IF NOT EXISTS student_enrollment (
        student_id   VARCHAR(255) NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
        sem_id       VARCHAR(255) NOT NULL REFERENCES semester(sem_id) ON DELETE CASCADE,
        PRIMARY KEY (student_id, sem_id)
    );
    """,

    # teacher_course
    """
    CREATE TABLE IF NOT EXISTS teacher_course (
        teacher_id   VARCHAR(255) NOT NULL REFERENCES teachers(teacher_id) ON DELETE CASCADE,
        course_id    VARCHAR(255) NOT NULL REFERENCES course(course_id) ON DELETE CASCADE,
        PRIMARY KEY (teacher_id, course_id)
    );
    """,

    # course_students
    """
    CREATE TABLE IF NOT EXISTS course_students (
        student_id   VARCHAR(255) NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
        course_id    VARCHAR(255) NOT NULL REFERENCES course(course_id) ON DELETE CASCADE,
        PRIMARY KEY (student_id, course_id)
    );
    """,

    # attendance → student, course
    # NO unique constraint needed - application logic handles the course-date locking
    """
    CREATE TABLE IF NOT EXISTS attendance (
        attendance_id SERIAL PRIMARY KEY,
        student_id      VARCHAR(255) NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
        course_id       VARCHAR(255) NOT NULL REFERENCES course(course_id) ON DELETE CASCADE,
        date           DATE NOT NULL,
        present        BOOLEAN NOT NULL DEFAULT FALSE,
        created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    );
    """,

    # Add index for better query performance on course-date lookups
    """
    CREATE INDEX IF NOT EXISTS idx_attendance_course_date
    ON attendance(course_id, date);
    """,

    # otp_storage - for storing OTPs with expiration
    """
    CREATE TABLE IF NOT EXISTS otp_storage (
        email          VARCHAR(255) PRIMARY KEY,
        otp            VARCHAR(6) NOT NULL,
        created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        expires_at     TIMESTAMP NOT NULL,
        attempts       INTEGER DEFAULT 0
    );
    """,

    # Add index for cleaning up expired OTPs
    """
    CREATE INDEX IF NOT EXISTS idx_otp_expires_at
    ON otp_storage(expires_at);
    """,
    
    # Add index for student-course lookups (for summaries)
    """
    CREATE INDEX IF NOT EXISTS idx_attendance_student_course 
    ON attendance(student_id, course_id);
    """,

    # users → department
    """
    CREATE TABLE IF NOT EXISTS users (
        user_id       VARCHAR(255) PRIMARY KEY,
        user_name         VARCHAR(255) NOT NULL,
        type         user_type NOT NULL,
        dept_id       VARCHAR(255) REFERENCES department(dept_id) ON DELETE SET NULL,
        fact_id       VARCHAR(255) REFERENCES faculty(fact_id) ON DELETE SET NULL
    );
    """,
]