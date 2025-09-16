from app.db.connection import connection_to_db

from app.db.models.teacher_course_model import BulkTeacherCourseIn, TeacherCourseDetail, TeacherCourseIn, TeacherCourseResponse


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


def display_teacher_course_by_teacher_id(teacher_id: str) -> TeacherCourseResponse:
    """
    Fetches a detailed list of courses (with semester and program info)
    for a specific teacher.
    """
    sql_query = """
        SELECT
            tc.teacher_id,    -- r[0]
            tc.course_id,     -- r[1]
            c.course_name,    -- r[2]
            s.sem_id,         -- r[3]
            s.sem_name,       -- r[4]
            p.prog_id,        -- r[5]
            p.prog_name       -- r[6]
        FROM
            teacher_course tc
        JOIN
            course c ON tc.course_id = c.course_id
        JOIN
            semester s ON c.sem_id = s.sem_id
        JOIN
            program p ON s.prog_id = p.prog_id
        WHERE
            tc.teacher_id = %s
        ORDER BY
            s.sem_name, c.course_name;
    """
    
    conn = connection_to_db() 
    if not conn:
        print("Error: Could not connect to the database.")
        return TeacherCourseResponse(success=False)

    assignments = []
    try:
        with conn.cursor() as cur:
            cur.execute(sql_query, (teacher_id,))
            rows = cur.fetchall()

        if not rows:
            return TeacherCourseResponse(success=True, teacher_courses=[])

        # Map tuple indexes to the TeacherCourseDetail model
        for r in rows:
            assignments.append(
                TeacherCourseDetail(
                    teacher_id=r[0],
                    course_id=r[1],
                    course_name=r[2],
                    sem_id=r[3],
                    sem_name=r[4],
                    prog_id=r[5],
                    prog_name=r[6]
                )
            )

        return TeacherCourseResponse(success=True, teacher_courses=assignments)
    
    except Exception as e:
        print(f"Error fetching teacher course details: {e}")
        if conn:
            conn.rollback()
        return TeacherCourseResponse(success=False)
    
    finally:
        if conn:
            conn.close()


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
