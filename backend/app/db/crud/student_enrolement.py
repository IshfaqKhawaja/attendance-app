from ast import Delete
from app.db.connection import connection_to_db
from app.db.models.student_enrolement_model import BulkStudentEnrolementModel, DeleteStudentEnrollmentResponseModel, DisplayStudentsBySemIdResponseModel, StudentCourseEnrolementModel, StudentEnrolementModel, StudentEnrollmentDetailsModel, StudentResponseModel




def add_student_enrolled_in_sem(student : StudentEnrolementModel):
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            # Insert into student_enrollment
            cur.execute(
                "INSERT INTO student_enrollment (student_id, sem_id) VALUES (%s, %s) ON CONFLICT (student_id, sem_id) DO NOTHING",
                (student.student_id, student.sem_id)
            )

            # Also enroll the student in all courses for this semester
            cur.execute(
                """
                INSERT INTO course_students (student_id, course_id)
                SELECT %s, course_id
                FROM course
                WHERE sem_id = %s
                ON CONFLICT (student_id, course_id) DO NOTHING
                """,
                (student.student_id, student.sem_id)
            )
            conn.commit()
        return {
            "success": True,
            "message": "Student Enrollment Added Successfully"
        }
    except Exception as e:
        return {
            "success": False,
            "message": f"Couldn't add student enrollment: {e}"
        }
        

def add_students_enrolled_in_sem_bulk(students: BulkStudentEnrolementModel) -> dict:
    """
    Inserts multiple students in one transaction.
    Skips students whose `student_id` already exists in the DB.
    Also enrolls students in all courses within the semester.
    """
    conn = connection_to_db()
    records = []
    for idx, st in enumerate(students.enrolements):
        if not isinstance(st, StudentEnrolementModel):
            return {"success": False, "message": f"Item #{idx} is not a StudentEnrollmentModel"}
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
            # Insert into student_enrollment
            cur.executemany(
                "INSERT INTO student_enrollment (student_id, sem_id) VALUES (%s, %s) ON CONFLICT (student_id, sem_id) DO NOTHING",
                records
            )

            # For each student-semester pair, also enroll them in all courses for that semester
            for student_id, sem_id in records:
                cur.execute(
                    """
                    INSERT INTO course_students (student_id, course_id)
                    SELECT %s, course_id
                    FROM course
                    WHERE sem_id = %s
                    ON CONFLICT (student_id, course_id) DO NOTHING
                    """,
                    (student_id, sem_id)
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
        
def display_students_by_sem_id(sem_id: str) -> DisplayStudentsBySemIdResponseModel:
    """
    Get student details enrolled in a particular semester using JOIN.
    """
    conn = connection_to_db()
    data = []
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT s.student_id, s.student_name, s.phone_number, s.sem_id
            FROM students s
            INNER JOIN student_enrollment se ON s.student_id = se.student_id
            WHERE se.sem_id = %s
            ORDER BY s.student_name ASC
            """,
            (sem_id,)
        )
        for row in cur.fetchall():
             # Append each student as a StudentResponseModel
            data.append(StudentResponseModel(
                student_id=row[0],
                student_name=row[1],
                phone_number=str(row[2]),
                sem_id=row[3]
            ))
    return DisplayStudentsBySemIdResponseModel(
        success=True,
        students=data
    )
    
    
def fetch_students_by_course_id(course_id: str) -> StudentEnrollmentDetailsModel:
    """
    Fetches the Students enrolled in a particular course using JOIN with course_students table.
    """
    conn = connection_to_db()
    data = []
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT s.student_id, s.student_name, s.phone_number
            FROM students s
            INNER JOIN course_students cs ON s.student_id = cs.student_id
            WHERE cs.course_id = %s
            ORDER BY s.student_name ASC
            """,
            (course_id,)
        )
        rows = cur.fetchall()
        for row in rows:
             # Append each student as a StudentResponseModel
            data.append(StudentCourseEnrolementModel(
                student_id=row[0],
                student_name=row[1],
                phone_number=str(row[2]),
                course_id=course_id
            ))
    return StudentEnrollmentDetailsModel(
        success=True,
        students=data
    )
    
    
def delete_student_enrollment(student_id: str, sem_id: str) -> DeleteStudentEnrollmentResponseModel:
    """
    Deletes a student's enrollment in a semester.
    Also deletes the student from all courses in that semester.
    """
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            # First, delete from course_students for all courses in this semester
            cur.execute(
                """
                DELETE FROM course_students
                WHERE student_id = %s
                AND course_id IN (
                    SELECT course_id FROM course WHERE sem_id = %s
                )
                """,
                (student_id, sem_id)
            )

            # Then delete from student_enrollment
            cur.execute(
                "DELETE FROM student_enrollment WHERE student_id = %s AND sem_id = %s",
                (student_id, sem_id)
            )
            if cur.rowcount == 0:
                return DeleteStudentEnrollmentResponseModel(
                    success=False,
                    message="No such enrollment found."
                )
            conn.commit()
        return DeleteStudentEnrollmentResponseModel(
            success=True,
            message="Student enrollment deleted successfully."
        )
    except Exception as e:
        conn.rollback()
        return DeleteStudentEnrollmentResponseModel(
            success=False,
            message=f"Couldn't delete student enrollment: {e}"
        )