"""
Script to create all required tables and enums for the attendance app in PostgreSQL.
"""
import psycopg2

# Update these values as needed for your local setup
DB_NAME = "attendance_db"
DB_USER = "postgres"
DB_PASSWORD = "postgres"
DB_HOST = "localhost"
DB_PORT = "5432"

def create_schema():
    conn = psycopg2.connect(
        dbname=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=DB_PORT
    )
    cur = conn.cursor()

    # 1) create enum for teacher type (if it doesn't already exist)
    cur.execute("""
    DO $$
    BEGIN
      IF NOT EXISTS (
        SELECT 1 FROM pg_type WHERE typname = 'teacher_type'
      ) THEN
        CREATE TYPE teacher_type AS ENUM (
          'PERMANENT',
          'GUEST',
          'CONTRACT'
        );
      END IF;
    END
    $$;
    """)

    # 2) create tables in dependency order
    statements = [
        # faculty
        """
        CREATE TABLE IF NOT EXISTS faculty (
          factid   VARCHAR(255) PRIMARY KEY,
          name     VARCHAR(255) NOT NULL
        );
        """,
        # department → faculty
        """
        CREATE TABLE IF NOT EXISTS department (
          deptid   VARCHAR(255) PRIMARY KEY,
          name     VARCHAR(255) NOT NULL,
          factid   VARCHAR(255) NOT NULL
                     REFERENCES faculty(factid)
                     ON DELETE CASCADE
        );
        """,
        # program → department, faculty
        """
        CREATE TABLE IF NOT EXISTS program (
          progid   VARCHAR(255) PRIMARY KEY,
          name     VARCHAR(255) NOT NULL,
          deptid   VARCHAR(255) NOT NULL
                     REFERENCES department(deptid)
                     ON DELETE CASCADE,
          factid   VARCHAR(255) NOT NULL
                     REFERENCES faculty(factid)
                     ON DELETE CASCADE
        );
        """,
        # semester → program
        """
        CREATE TABLE IF NOT EXISTS semester (
          semid       VARCHAR(255) PRIMARY KEY,
          name        VARCHAR(100) NOT NULL,
          startdate   DATE NOT NULL,
          enddate     DATE NOT NULL,
          progid      VARCHAR(255) NOT NULL
                       REFERENCES program(progid)
                       ON DELETE CASCADE
        );
        """,
        # teachers (faculty members) with enum type
        """
        CREATE TABLE IF NOT EXISTS teachers (
          teacherid   VARCHAR(255) PRIMARY KEY,
          name        VARCHAR(255) NOT NULL,
          type        teacher_type NOT NULL,
          deptid      VARCHAR(255) NOT NULL
                      REFERENCES department(deptid)
                      ON DELETE CASCADE
        );
        """,
        # course → semester, teachers
        """
        CREATE TABLE IF NOT EXISTS course (
          courseid    VARCHAR(255) PRIMARY KEY,
          name        VARCHAR(255) NOT NULL,
          semid       VARCHAR(255) NOT NULL
                      REFERENCES semester(semid)
                      ON DELETE CASCADE,
          progid     VARCHAR(255) NOT NULL
                      REFERENCES program(progid)
                      ON DELETE CASCADE,
          deptid      VARCHAR(255) NOT NULL
                      REFERENCES department(deptid)
                      ON DELETE CASCADE,
          factid      VARCHAR(255) NOT NULL
                      REFERENCES faculty(factid)
                      ON DELETE CASCADE
        );
        CREATE TABLE teacher_course (
          teacherid  VARCHAR(255) NOT NULL
            REFERENCES teachers(teacherid) ON DELETE CASCADE,
          courseid   VARCHAR(255) NOT NULL
            REFERENCES course(courseid) ON DELETE CASCADE,
          semid      VARCHAR(255) NOT NULL
            REFERENCES semester(semid) ON DELETE CASCADE,
          deptid     VARCHAR(255) NOT NULL
            REFERENCES department(deptid) ON DELETE CASCADE,
          progid     VARCHAR(255) NOT NULL
            REFERENCES program(progid) ON DELETE CASCADE,
          factid     VARCHAR(255) NOT NULL
            REFERENCES faculty(factid) ON DELETE CASCADE,
          PRIMARY KEY (teacherid, courseid, semid, factid)
        );
        """,
        # student → program, semester
        """
        CREATE TABLE IF NOT EXISTS students (
          studentid   VARCHAR(255) PRIMARY KEY,
          name        VARCHAR(255) NOT NULL,
          phonenumber BIGINT,
          progid      VARCHAR(255) NOT NULL
                       REFERENCES program(progid)
                       ON DELETE SET NULL,
          semid       VARCHAR(255) NOT NULL
                       REFERENCES semester(semid)
                       ON DELETE SET NULL,
          deptid     VARCHAR(255) NOT NULL
                     REFERENCES department(deptid)
                     ON DELETE CASCADE
        );
        """,
        # attendance → student, course
        """
        CREATE TABLE IF NOT EXISTS attendance (
          attendanceid   VARCHAR(255) PRIMARY KEY,
          studentid      VARCHAR(255) NOT NULL
                          REFERENCES students(studentid)
                          ON DELETE CASCADE,
          courseid       VARCHAR(255) NOT NULL
                          REFERENCES course(courseid)
                          ON DELETE CASCADE,
          date           DATE    NOT NULL,
          present        BOOLEAN NOT NULL DEFAULT FALSE,
          semid         VARCHAR(255) NOT NULL
                        REFERENCES semester(semid)
                        ON DELETE CASCADE,
          deptid        VARCHAR(255) NOT NULL
                        REFERENCES department(deptid)
                        ON DELETE CASCADE,
          progid     VARCHAR(255) NOT NULL
                        REFERENCES program(progid)
                        ON DELETE CASCADE
        );
        CREATE TYPE user_type AS ENUM (
          'NORMAL',
          'HOD',
          'SUPER_ADMIN'
        );
        CREATE TABLE IF NOT EXISTS users (
          userid       VARCHAR(255) PRIMARY KEY,
          name         VARCHAR(255) NOT NULL,
          type         user_type     NOT NULL,
          deptid     VARCHAR(255) 
                     REFERENCES department(deptid)
                     ON DELETE CASCADE,
          factid     VARCHAR(255)
                     REFERENCES faculty(factid)
                     ON DELETE CASCADE
        );
        CREATE TABLE IF NOT EXISTS course_students (
          studentid   VARCHAR(255) NOT NULL
                       REFERENCES students(studentid)
                       ON DELETE CASCADE,
          courseid    VARCHAR(255) NOT NULL
                       REFERENCES course(courseid)
                       ON DELETE CASCADE,
          progid      VARCHAR(255) NOT NULL
                       REFERENCES program(progid)
                       ON DELETE CASCADE,
          semid       VARCHAR(255) NOT NULL
                       REFERENCES semester(semid)
                       ON DELETE CASCADE,
          deptid     VARCHAR(255) NOT NULL
                     REFERENCES department(deptid)
                     ON DELETE CASCADE,
          PRIMARY KEY(studentid,courseid )
        );
        """
    ]

    for stmt in statements:
        cur.execute(stmt)
    conn.commit()
    cur.close()
    conn.close()
    print("All tables created successfully.")

if __name__ == "__main__":
    create_schema()
