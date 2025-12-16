# app/db/course_crud.py
from typing import List
from app.db.connection import connection_to_db
from app.db.crud.teacher_course import add_teacher_course_to_db
from app.db.models.course_model import (
    CourseCreate,
    CourseCreateResponse,
    CourseDetailResponse,
    BulkCourseCreate,
    BulkCourseCreateResponse,
)
from app.db.models.teacher_course_model import TeacherCourseIn

def add_course_to_db(course: CourseCreate) -> CourseCreateResponse:
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            # 1. Create the course
            cur.execute(
                "INSERT INTO course (course_id, course_name, sem_id) "
                "VALUES (%s, %s, %s)",
                (course.course_id, course.course_name, course.sem_id)
            )

            # 2. Auto-enroll all students already in this semester to the new course
            cur.execute(
                """
                INSERT INTO course_students (student_id, course_id)
                SELECT se.student_id, %s
                FROM student_enrollment se
                WHERE se.sem_id = %s
                ON CONFLICT (student_id, course_id) DO NOTHING
                """,
                (course.course_id, course.sem_id)
            )
            enrolled_count = cur.rowcount

        conn.commit()

        # 3. Assign teacher to course
        details = add_teacher_course_to_db(TeacherCourseIn(teacher_id=course.assigned_teacher_id, course_id=course.course_id))
        if not details.get("success", False):
            conn.rollback()
            return CourseCreateResponse(
                success=False,
                message=f"Couldn't add course: {details.get('message', 'Failed to assign teacher to course')}"
            )
        return CourseCreateResponse(
            success=True,
            message=f"Course added to DB. {enrolled_count} existing student(s) auto-enrolled."
        )
    except Exception as e:
        conn.rollback()
        return CourseCreateResponse(
            success=False,
            message=f"Couldn't add course: {e}"
        )

def display_course_by_id(courseid: str) -> CourseDetailResponse:
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT courseid, name, semid, progid, deptid, factid "
            "FROM course WHERE courseid = %s",
            (courseid,)
        )
        row = cur.fetchone()
    if row:
        return CourseDetailResponse(
            success=True,
            courses=[CourseCreate(
                course_id=row[0],
                course_name=row[1],
                sem_id=row[2],
            )]
        )
    return CourseDetailResponse(success=False)

def display_all_courses() -> List[CourseCreate]:
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT course_id, course_name, sem_id FROM course"
        )
        rows = cur.fetchall()
    return [
        CourseCreate(
            course_id=r[0],
            course_name=r[1],
            sem_id=r[2],
        )
        for r in rows
    ]

def add_courses_bulk(payload: BulkCourseCreate) -> BulkCourseCreateResponse:
    conn = connection_to_db()
    inserted = 0
    skipped = 0
    try:
        with conn.cursor() as cur:
            for c in payload.courses:
                cur.execute(
                    """
                    INSERT INTO course (course_id, course_name, sem_id)
                    VALUES (%s, %s, %s)
                    ON CONFLICT (course_id) DO NOTHING
                    """,
                    (c.course_id, c.course_name, c.sem_id)
                )
                if cur.rowcount:
                    inserted += 1
                else:
                    skipped += 1
        conn.commit()
        return BulkCourseCreateResponse(
            success=True,
            inserted_count=inserted,
            skipped_count=skipped,
            message=f"{inserted} inserted, {skipped} skipped"
        )
    except Exception as e:
        conn.rollback()
        return BulkCourseCreateResponse(
            success=False,
            inserted_count=inserted,
            skipped_count=skipped,
            message=f"Bulk insert failed: {e}"
        )



def fetch_courses_by_semester_id(sem_id: str) -> CourseDetailResponse:
    """
    Fetches a flat list of course-teacher assignments for a semester.
    """
    
    sql_query = """
        SELECT
            c.course_name,
            c.course_id,
            c.sem_id,
            tc.teacher_id AS assigned_teacher_id
        FROM
            course c
        JOIN
            teacher_course tc ON c.course_id = tc.course_id
        WHERE
            c.sem_id = %s
        ORDER BY
            c.course_name, assigned_teacher_id;
    """
    
    # This connection will now produce DictCursors by default
    conn = connection_to_db() 
    
    if not conn:
        print("Error: Could not connect to the database.")
        return CourseDetailResponse(success=False)

    courses = []
    try:
        # --- THIS IS THE FIX ---
        # No 'cursor_factory' argument here
        with conn.cursor() as cur:
            cur.execute(sql_query, (sem_id,))
            rows = cur.fetchall()

        if not rows:
            return CourseDetailResponse(success=True, courses=[])

        for row in rows:
            courses.append(CourseCreate(
                course_name=row[0],
                course_id=row[1],
                sem_id=row[2],
                assigned_teacher_id=row[3]
            ))
        return CourseDetailResponse(success=True, courses=courses)
    
    except Exception as e:
        print(f"Error fetching course assignments: {e}")
        return CourseDetailResponse(success=False)
    
    finally:
        if conn:
            conn.close()


def delete_course_by_id(course_id: str) -> CourseCreateResponse:
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "DELETE FROM course WHERE course_id = %s",
                (course_id,)
            )
            if cur.rowcount == 0:
                return CourseCreateResponse(
                    success=False,
                    message="Course not found"
                )
        conn.commit()
        return CourseCreateResponse(
            success=True,
            message="Course deleted successfully"
        )
    except Exception as e:
        conn.rollback()
        return CourseCreateResponse(
            success=False,
            message=f"Couldn't delete course: {e}"
        )


def update_course_by_id(course_update) -> CourseCreateResponse:
    """Update course name and/or assigned teacher"""
    from app.db.models.course_model import CourseUpdate
    from app.db.crud.teacher_course import update_teacher_course_assignment

    conn = connection_to_db()
    try:
        # Update course name if provided
        if course_update.course_name:
            with conn.cursor() as cur:
                cur.execute(
                    "UPDATE course SET course_name = %s WHERE course_id = %s",
                    (course_update.course_name, course_update.course_id)
                )
                if cur.rowcount == 0:
                    return CourseCreateResponse(
                        success=False,
                        message="Course not found"
                    )

        # Update teacher assignment if provided
        if course_update.assigned_teacher_id:
            result = update_teacher_course_assignment(
                course_update.course_id,
                course_update.assigned_teacher_id
            )
            if not result.get("success", False):
                conn.rollback()
                return CourseCreateResponse(
                    success=False,
                    message=f"Failed to update teacher assignment: {result.get('message', 'Unknown error')}"
                )

        conn.commit()
        return CourseCreateResponse(
            success=True,
            message="Course updated successfully"
        )
    except Exception as e:
        conn.rollback()
        return CourseCreateResponse(
            success=False,
            message=f"Couldn't update course: {e}"
        )