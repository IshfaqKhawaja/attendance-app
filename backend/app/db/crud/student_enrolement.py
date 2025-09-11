from app.db.connection import connection_to_db
from app.db.models.student_enrolement_model import BulkStudentEnrolementModel, StudentEnrolementModel




def add_student_enrolled_in_sem(student : StudentEnrolementModel):
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO student_enrolement (student_id, sem_id) VALUES (%s, %s)",
                (student.student_id, student.sem_id)
            )
            conn.commit()
        return {
            "success": True,
            "message": "Student Enrolement Added Successfully"
        }
    except Exception as e:
        return {
            "success": False,
            "message": f"Couldn't add student enrolement: {e}"
        }
        

def add_students_enrolled_in_sem_bulk(students: BulkStudentEnrolementModel) -> dict:
    """
    Inserts multiple students in one transaction.
    Skips students whose `student_id` already exists in the DB.
    """
    conn = connection_to_db()
    records = []
    for idx, st in enumerate(students.enrolements):
        if not isinstance(st, StudentEnrolementModel):
            return {"success": False, "message": f"Item #{idx} is not a StudentEnrolementModel"}
        try:
            records.append((
                st.student_id,
                st.sem_id
            ))
        except KeyError as missing:
            return {
                "success": False,
                "message": f"Item #{idx} is missing field: {missing}"
            }
    try:
        with conn.cursor() as cur:
            cur.executemany(
                "INSERT INTO student_enrolement (student_id, sem_id) VALUES (%s, %s) ON CONFLICT (student_id, sem_id) DO NOTHING",
                records
            )
        conn.commit()
        return {
            "success": True,
            "message": f"Inserted {cur.rowcount} records, skipped {len(records) - cur.rowcount} existing."
        }
    except Exception as e:
        conn.rollback()
        return {
            "success": False,
            "message": f"Couldn't add students in bulk: {e}"
        }
        
def display_student_by_sem_id(sem_id: str) -> dict:
    """
    Get student details enrolled in a particular semester using JOIN.
    """
    conn = connection_to_db()
    data = []
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT s.student_id, s.student_name, s.phone_number, s.dept_id
            FROM students s
            INNER JOIN student_enrolement se ON s.student_id = se.student_id
            WHERE se.sem_id = %s
            """,
            (sem_id,)
        )
        for row in cur.fetchall():
            data.append({
                "student_id": row[0],
                "student_name": row[1],
                "phone_number": row[2],
                "dept_id": row[3]
            })
    return {
        "success": True,
        "students": data
    }