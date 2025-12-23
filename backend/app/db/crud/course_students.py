from app.db.connection import connection_to_db
from app.db.models.course_student_model import BulkCourseStudentInput, CourseIdInput, CourseStudent, LocalStudentInput
from typing import  List



def add_course_students_to_db(course_std : CourseStudent) -> dict:
    """
    Insert a single course-students relationship into the database.
    """
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO course_students (student_id, course_id)
                VALUES (%s, %s)
                """,
                (course_std.student_id, course_std.course_id)
            )
        conn.commit()
        return {"success": True, "message": "Course Student Added added to DB"}
    except Exception as e:
        conn.rollback()
        print("Insert failed:", e)
        return {"success": False, "message": f"Couldn't add Course Students: {e}"}


def add_bulk_course_students_to_db(
    course_students: BulkCourseStudentInput
) -> dict:
    """
    Bulk insert multiple course-student relationships into the database.
    Skips duplicate entries based on unique constraint (e.g., studentid + courseid).

    Expects each dict to include:
      - student_id (str)
      - course_id  (str)
    """
    if not isinstance(course_students, list):
        return {"success": False, "message": "Payload must be a list of course students dicts"}

    records = []
    for idx, cr in enumerate(course_students.course_students, start=1):
        if not isinstance(cr, dict):
            return {"success": False, "message": f"Item #{idx} is not a dict"}
        try:
            records.append((
                cr.student_id,
                cr.course_id,
            ))
        except KeyError as missing:
            return {"success": False, "message": f"Item #{idx} missing field '{missing.args[0]}'"}

    if not records:
        return {"success": False, "message": "No records provided for bulk insert."}

    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.executemany(
                """
                INSERT INTO course_students (student_id, course_id)
                VALUES (%s, %s)
                ON CONFLICT (student_id, course_id) DO NOTHING
                """,
                records
            )
        conn.commit()
        return {
            "success": True,
            "message": f"Tried inserting {len(records)} course-student records. Duplicates were skipped."
        }
    except Exception as e:
        conn.rollback()
        print("Bulk insert failed:", e)
        return {"success": False, "message": f"Couldn't add course-student records in bulk: {e}"}



def display_course_student_by_id(course_std: CourseStudent) -> dict:
    """
    Fetches the course students row(s) with the given course_id and returns it as a dict,
    or returns success=False if not found.
    """
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT student_id, course_id"
            " FROM course_students WHERE student_id = %s and course_id=%s",
            (course_std.student_id, course_std.course_id)
        )
        rows = cur.fetchall()
    data = []
    if rows:
        for row in rows:
            data.append({
                "student_id": row[0],
                "course_id": row[1]
            })
        return {
            "success": True,
            "course_students" : data,
            
        }
    else:
        return {"success": False}


def display_course_student_by_course_id(course_input: CourseIdInput) -> dict:
    """
    Fetches the course students row(s) with the given course_id and returns it as a dict,
    or returns success=False if not found.
    """
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT student_id, course_id"
            " FROM course_students WHERE course_id=%s",
            (course_input.course_id,)
        )
        rows = cur.fetchall()
    data = []
    if rows:
        for row in rows:
            data.append({
                "student_id": row[0],
                "course_id": row[1]
            })
    return {
        "success": True,
        "course_students" : data,
    }
    


def display_all() -> list:
    """
    Fetches all rows from course-students and returns a list of dicts.
    """
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT student_id, course_id"
            " FROM course_students"
        )
        rows = cur.fetchall()

    return [
        {
            "student_id": row[0],
            "course_id": row[1],
        }
        for row in rows
    ]


def add_local_student_to_course(data: LocalStudentInput) -> dict:
    """
    Add a local/backlog student directly to a course without semester enrollment.

    1. Check if student exists in students table
    2. If not, create the student (without sem_id)
    3. Add entry to course_students for this specific course
    """
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            # Check if student already exists
            cur.execute(
                "SELECT student_id FROM students WHERE student_id = %s",
                (data.student_id,)
            )
            existing_student = cur.fetchone()

            if not existing_student:
                # Create the student without semester enrollment
                cur.execute(
                    """
                    INSERT INTO students (student_id, student_name, phone_number)
                    VALUES (%s, %s, %s)
                    """,
                    (data.student_id, data.student_name, data.phone_number)
                )

            # Add student to course_students for this specific course
            cur.execute(
                """
                INSERT INTO course_students (student_id, course_id)
                VALUES (%s, %s)
                ON CONFLICT (student_id, course_id) DO NOTHING
                """,
                (data.student_id, data.course_id)
            )

        conn.commit()
        return {
            "success": True,
            "message": "Local student added to course successfully"
        }
    except Exception as e:
        conn.rollback()
        print("Add local student failed:", e)
        return {"success": False, "message": f"Couldn't add local student to course: {e}"}


def remove_student_from_course(course_std: CourseStudent) -> dict:
    """
    Remove a student from a specific course only.
    This only removes the entry from course_students table,
    not from student_enrollment (semester) or students table.
    """
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                DELETE FROM course_students
                WHERE student_id = %s AND course_id = %s
                """,
                (course_std.student_id, course_std.course_id)
            )
            deleted_count = cur.rowcount
        conn.commit()

        if deleted_count > 0:
            return {
                "success": True,
                "message": "Student removed from course successfully"
            }
        else:
            return {
                "success": False,
                "message": "Student not found in this course"
            }
    except Exception as e:
        conn.rollback()
        print("Remove student from course failed:", e)
        return {"success": False, "message": f"Couldn't remove student from course: {e}"}




