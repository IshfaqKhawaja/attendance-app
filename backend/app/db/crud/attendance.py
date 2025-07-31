from typing import List
from app.db.connection import connection_to_db
from app.models.attendence_model import AttendenceModel, AttendenceIdModel

def add_attendence_to_db(model: AttendenceModel) -> dict:
    """
    Insert a single attendance record using an AttendenceModel.
    """
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO attendance
                  (attendanceid, studentid, courseid,
                   date, present, progid, semid, deptid)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                """,
                (
                    model.attendance_id,
                    model.student_id,
                    model.course_id,
                    model.date,
                    model.present,
                    model.prog_id,
                    model.sem_id,
                    model.dept_id,
                ),
            )
        conn.commit()
        return {"success": True, "message": "Attendence Recorded"}
    except Exception as e:
        conn.rollback()
        print("Insert failed:", e)
        return {"success": False, "message": f"Couldn't Record Attendence: {e}"}


def add_attendence_bulk(models: List[AttendenceModel]) -> dict:
    """
    Bulk-insert multiple attendance records via a list of AttendenceModel.
    """
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.executemany(
                """
                INSERT INTO attendance
                  (attendanceid, studentid, courseid,
                   date, present, progid, semid, deptid)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                """,
                [
                    (
                        m.attendance_id,
                        m.student_id,
                        m.course_id,
                        m.date,
                        m.present,
                        m.prog_id,
                        m.sem_id,
                        m.dept_id,
                    )
                    for m in models
                ],
            )
        conn.commit()
        return {
            "success": True,
            "message": f"{len(models)} attendance records inserted"
        }
    except Exception as e:
        conn.rollback()
        print("Bulk insert failed:", e)
        return {"success": False, "message": f"Couldn't insert records: {e}"}


def display_attendence_by_id(attendence_id: AttendenceIdModel) -> dict:
    """
    Fetches the attendance row with the given ID and returns it as a dict,
    or returns success=False if not found.
    """
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT attendanceid, studentid, courseid, date, present, progid, semid, deptid "
            "FROM attendance WHERE attendanceid = %s",
            (attendence_id.attendance_id,),
        )
        row = cur.fetchone()

    if not row:
        return {"success": False}

    # map row back into our model
    model = AttendenceModel(
        attendance_id=row[0],
        student_id=row[1],
        course_id=row[2],
        date=row[3],
        present=row[4],
        prog_id=row[5],
        sem_id=row[6],
        dept_id=row[7],
    )
    return {"success": True, **model.dict()}
