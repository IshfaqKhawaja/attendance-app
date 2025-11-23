#!/usr/bin/env python3
"""
Backfill script to populate course_students table with existing student enrollments.

This script finds all students enrolled in semesters (from student_enrollment table)
and enrolls them in all courses within those semesters (inserts into course_students table).
"""

import sys
from pathlib import Path

# Add parent directory to path so we can import from app
backend_dir = Path(__file__).parent.parent
sys.path.insert(0, str(backend_dir))

from app.db.connection import connection_to_db


def backfill_course_students():
    """
    Populate course_students table based on existing student_enrollment data.
    For each student enrolled in a semester, enroll them in all courses in that semester.
    """
    conn = connection_to_db()

    try:
        with conn.cursor() as cur:
            # Get count before
            cur.execute("SELECT COUNT(*) FROM course_students")
            count_before = cur.fetchone()[0]
            print(f"Current course_students entries: {count_before}")

            # Insert course-student relationships for all students enrolled in semesters
            print("\nBackfilling course_students table...")
            cur.execute("""
                INSERT INTO course_students (student_id, course_id)
                SELECT DISTINCT se.student_id, c.course_id
                FROM student_enrollment se
                INNER JOIN course c ON se.sem_id = c.sem_id
                ON CONFLICT (student_id, course_id) DO NOTHING
            """)

            rows_inserted = cur.rowcount
            conn.commit()

            # Get count after
            cur.execute("SELECT COUNT(*) FROM course_students")
            count_after = cur.fetchone()[0]

            print(f"\nBackfill complete!")
            print(f"Rows inserted: {rows_inserted}")
            print(f"Total course_students entries: {count_after}")

            # Show summary by semester
            print("\nSummary by semester:")
            cur.execute("""
                SELECT c.sem_id, COUNT(DISTINCT cs.student_id) as student_count,
                       COUNT(DISTINCT cs.course_id) as course_count,
                       COUNT(*) as total_enrollments
                FROM course_students cs
                INNER JOIN course c ON cs.course_id = c.course_id
                GROUP BY c.sem_id
                ORDER BY c.sem_id
            """)

            for row in cur.fetchall():
                sem_id, student_count, course_count, total = row
                print(f"  Semester {sem_id}: {student_count} students × {course_count} courses = {total} enrollments")

    except Exception as e:
        conn.rollback()
        print(f"Error during backfill: {e}")
        return False
    finally:
        conn.close()

    return True


if __name__ == "__main__":
    print("=" * 60)
    print("Course Students Backfill Script")
    print("=" * 60)

    success = backfill_course_students()

    if success:
        print("\n✓ Backfill completed successfully!")
        sys.exit(0)
    else:
        print("\n✗ Backfill failed!")
        sys.exit(1)
