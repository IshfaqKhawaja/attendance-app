from app.db.connection import connection_to_db
from typing import  List, Dict


def add_course_students_to_db(student_id: str, course_id: str, sem_id: str, dept_id: str, prog_id: str) -> dict:
    """
    Insert a single course-students relationship into the database.
    """
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO course_students (studentid, courseid, semid, progid, deptid)
                VALUES (%s, %s, %s, %s, %s)
                """,
                (student_id, course_id, sem_id, prog_id, dept_id)
            )
        conn.commit()
        return {"success": True, "message": "Course Student Added added to DB"}
    except Exception as e:
        conn.rollback()
        print("Insert failed:", e)
        return {"success": False, "message": f"Couldn't add Course Students: {e}"}


def add_bulk_course_students_to_db(
    course_students: List[Dict[str, str]]
) -> dict:
    """
    Bulk insert multiple course-student relationships into the database.
    Skips duplicate entries based on unique constraint (e.g., studentid + courseid).

    Expects each dict to include:
      - student_id (str)
      - course_id  (str)
      - sem_id     (str)
      - prog_id    (str)
      - dept_id    (str)
    """
    if not isinstance(course_students, list):
        return {"success": False, "message": "Payload must be a list of course students dicts"}

    records = []
    for idx, cr in enumerate(course_students, start=1):
        if not isinstance(cr, dict):
            return {"success": False, "message": f"Item #{idx} is not a dict"}
        try:
            records.append((
                cr["student_id"],
                cr["course_id"],
                cr["sem_id"],
                cr["prog_id"],
                cr["dept_id"],
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
                INSERT INTO course_students (studentid, courseid, semid, progid, deptid)
                VALUES (%s, %s, %s, %s, %s)
                ON CONFLICT (studentid, courseid) DO NOTHING
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



def display_course_student_by_id(students_id: str, course_id : str) -> dict:
    """
    Fetches the course students row(s) with the given course_id and returns it as a dict,
    or returns success=False if not found.
    """
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT studentid, courseid, semid, progid, deptid, factid"
            " FROM course_students WHERE studentid = %s and courseid=%s",
            (students_id,course_id)
        )
        rows = cur.fetchall()
    data = []
    if rows:
        for row in rows:
            data.append({
                "student_id": row[0],
                "course_id": row[1],
                "sem_id": row[2],
                "prog_id": row[3],
                "dept_id": row[4],
            })
        return {
            "success": True,
            "course_students" : data,
            
        }
    else:
        return {"success": False}
    
    
def display_course_student_by_course_id(course_id : str) -> dict:
    """
    Fetches the course students row(s) with the given course_id and returns it as a dict,
    or returns success=False if not found.
    """
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT studentid, courseid, semid, progid, deptid"
            " FROM course_students WHERE  courseid=%s",
            (course_id,)
        )
        rows = cur.fetchall()
    data = []
    if rows:
        for row in rows:
            data.append({
                "student_id": row[0],
                "course_id": row[1],
                "sem_id": row[2],
                "prog_id": row[3],
                "dept_id": row[4],
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
            "SELECT studentid, courseid, semid, progid, deptid, factid"
            " FROM course_students"
        )
        rows = cur.fetchall()

    return [
        {
            "student_id": row[0],
            "course_id": row[1],
            "sem_id": row[2],
            "prog_id": row[3],
            "dept_id": row[4],
        }
        for row in rows
    ]
