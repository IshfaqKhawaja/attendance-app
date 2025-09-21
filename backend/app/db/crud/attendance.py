from re import A
from typing import List
from app.db.connection import connection_to_db
from app.db.models.attendence_model import AttendenceModel, AttendenceIdModel, BulkAttendenceResponseModel, ReportInput

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
                    model.student_id,
                    model.course_id,
                    model.date,
                    model.present,
                ),
            )
        conn.commit()
        return {"success": True, "message": "Attendence Recorded"}
    except Exception as e:
        conn.rollback()
        print("Insert failed:", e)
        return {"success": False, "message": f"Couldn't Record Attendence: {e}"}


def add_attendence_bulk(attendances: List[AttendenceModel]) -> BulkAttendenceResponseModel:
    """
    Bulk-insert multiple attendance records via a list of AttendenceModel.
    """
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.executemany(
                """
                INSERT INTO attendance
                  (student_id, course_id,
                   date, present)
                VALUES (%s, %s, %s, %s)
                """,
                [
                    (
                        m.student_id,
                        m.course_id,
                        m.date,
                        m.present
                    )
                    for m in attendances
                ],
            )
        conn.commit()
        return BulkAttendenceResponseModel(
            success=True,
            message=f"{len(attendances)} attendance records inserted"
        )
    except Exception as e:
        conn.rollback()
        print("Bulk insert failed:", e)
        return BulkAttendenceResponseModel(
            success=False,
            message=f"Couldn't insert records: {e}"
        )


def display_attendence_by_id(attendence_id: AttendenceIdModel) -> dict:
    """
    Fetches the attendance row with the given ID and returns it as a dict,
    or returns success=False if not found.
    """
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT student_id, course_id, date, present "
            "FROM attendance WHERE attendance_id = %s",
            (attendence_id.attendance_id,),
        )
        row = cur.fetchone()

    if not row:
        return {"success": False}

    # map row back into our model
    model = AttendenceModel(
        student_id=row[0],
        course_id=row[1],
        date=row[2],
        present=row[3],
    )
    return {"success": True, **model.dict()}