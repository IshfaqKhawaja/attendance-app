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
  STUDENT_ENROLLMENT (new)

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
            CREATE TYPE user_type AS ENUM ('NORMAL', 'HOD', 'SUPER_ADMIN');
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

    # program → department (factid is redundant as it can be found via department)
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

    # teacher (faculty member) → department
    """
    CREATE TABLE IF NOT EXISTS teachers (
        teacher_id   VARCHAR(255) PRIMARY KEY,
        teacher_name        VARCHAR(255) NOT NULL,
        type        teacher_type NOT NULL,
        dept_id      VARCHAR(255) NOT NULL REFERENCES department(dept_id) ON DELETE CASCADE
    );
    """,

    # student → department (program/semester info is now in the enrollment table)
    """
    CREATE TABLE IF NOT EXISTS students (
        student_id   VARCHAR(255) PRIMARY KEY,
        student_name        VARCHAR(255) NOT NULL,
        phone_number BIGINT,
        dept_id      VARCHAR(255) REFERENCES department(dept_id) ON DELETE SET NULL
    );
    """,

    # course → semester (other IDs are redundant)
    """
    CREATE TABLE IF NOT EXISTS course (
        course_id    VARCHAR(255) PRIMARY KEY,
        course_name        VARCHAR(255) NOT NULL,
        sem_id       VARCHAR(255) NOT NULL REFERENCES semester(sem_id) ON DELETE CASCADE
    );
    """,

    # [NEW] student_enrollment: links a student to a specific semester
    """
    CREATE TABLE IF NOT EXISTS student_enrollment (
        student_id   VARCHAR(255) NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
        sem_id       VARCHAR(255) NOT NULL REFERENCES semester(sem_id) ON DELETE CASCADE,
        PRIMARY KEY (student_id, sem_id)
    );
    """,

    # teacher_course: junction table for a many-to-many relationship
    """
    CREATE TABLE IF NOT EXISTS teacher_course (
        teacher_id   VARCHAR(255) NOT NULL REFERENCES teachers(teacher_id) ON DELETE CASCADE,
        course_id    VARCHAR(255) NOT NULL REFERENCES course(course_id) ON DELETE CASCADE,
        PRIMARY KEY (teacher_id, course_id)
    );
    """,

    # course_student: junction table for courses a student is taking in a semester
    """
    CREATE TABLE IF NOT EXISTS course_student (
        student_id   VARCHAR(255) NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
        course_id    VARCHAR(255) NOT NULL REFERENCES course(course_id) ON DELETE CASCADE,
        PRIMARY KEY (student_id, course_id)
    );
    """,

    # attendance → student, course (other IDs are redundant)
    """
    CREATE TABLE IF NOT EXISTS attendance (
        student_id      VARCHAR(255) NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
        course_id       VARCHAR(255) NOT NULL REFERENCES course(course_id) ON DELETE CASCADE,
        "date"         DATE NOT NULL,
        present        BOOLEAN NOT NULL DEFAULT FALSE,
        PRIMARY KEY (student_id, course_id)
    );
    """,

    # users → department (factid is redundant)
    """
    CREATE TABLE IF NOT EXISTS users (
        user_id       VARCHAR(255) PRIMARY KEY,
        user_name         VARCHAR(255) NOT NULL,
        type         user_type NOT NULL,
        dept_id       VARCHAR(255) REFERENCES department(dept_id) ON DELETE SET NULL,
        fact_id       VARCHAR(255) REFERENCES faculty(fact_id) ON DELETE SET NULL
    );
    """
] 