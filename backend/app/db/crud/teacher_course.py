from app.db.connection import connection_to_db

from app.db.models.teacher_course_model import BulkTeacherCourseIn, TeacherCourseIn


def add_teacher_course_to_db(teacher_course: TeacherCourseIn) -> dict:
    """
    Insert a single teacher-course relationship into the database.
    """
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO teacher_course (teacher_id, course_id)
                VALUES (%s, %s)
                """,
                (teacher_course.teacher_id, teacher_course.course_id)
            )
        conn.commit()
        return {"success": True, "message": "Teacher Course added to DB"}
    except Exception as e:
        conn.rollback()
        print("Insert failed:", e)
        return {"success": False, "message": f"Couldn't add Teacher Course: {e}"}


def add_bulk_teacher_courses_to_db(
    teacher_courses: BulkTeacherCourseIn
) -> dict:
    """
    Bulk insert multiple teacher-course relationships into the database.
    Expects `courses` to be a list of dicts, each with keys:
      - teacher_id (str)
      - course_id  (str)
    Uses `executemany` instead of `execute_batch` for portability.
    """
    # 1. Validate input
    if not isinstance(teacher_courses, list):
        return {"success": False, "message": "Payload must be a list of course dicts"}

    records = []
    for idx, cr in enumerate(teacher_courses.teacher_courses, start=1):
        if not isinstance(cr, dict):
            return {"success": False, "message": f"Item #{idx} is not a dict"}
        try:
            records.append((
                cr["teacher_id"],
                cr["course_id"],
            ))
        except KeyError as missing:
            return {"success": False, "message": f"Item #{idx} missing field '{missing.args[0]}'"}

    if not records:
        return {"success": False, "message": "No records provided for bulk insert."}

    # 2. Bulk insert using executemany
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.executemany(
                """
                INSERT INTO teacher_course (teacher_id, course_id)
                VALUES (%s, %s)
                """,
                records
            )
        conn.commit()
        return {"success": True, "message": f"Successfully added {len(records)} teacher-course records."}
    except Exception as e:
        conn.rollback()
        print("Bulk insert failed:", e)
        return {"success": False, "message": f"Couldn't add teacher courses in bulk: {e}"}


def display_teacher_course_by_teacher_id(teacher_id: str) -> dict:
    """
    Fetches the teacher_course row(s) with the given course_id and returns it as a dict,
    or returns success=False if not found.
    """
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT teacher_id, course_id"
            " FROM teacher_course WHERE teacher_id = %s",
            (teacher_id,)
        )
        rows = cur.fetchall()
    data = []
    if rows:
        for row in rows:
            data.append({
                "teacher_id": row[0],
                "course_id": row[1]
            })
        return {
            "success": True,
            "teacher_courses" : data,
            
        }
    else:
        return {"success": False}


def display_all() -> list:
    """
    Fetches all rows from teacher_course and returns a list of dicts.
    """
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT teacher_id, course_id"
            " FROM teacher_course"
        )
        rows = cur.fetchall()

    return [
        {
            "teacher_id": row[0],
            "course_id": row[1],
        }
        for row in rows
    ]
