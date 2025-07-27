# app/db/course_crud.py
from typing import List
from app.db.connection import connection_to_db
from app.models.course_model import (
    CourseCreate,
    CourseCreateResponse,
    CourseDetailResponse,
    CourseListItem,
    BulkCourseCreate,
    BulkCourseCreateResponse,
)

def add_course_to_db(course: CourseCreate) -> CourseCreateResponse:
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO course (courseid, name, semid, progid, deptid, factid) "
                "VALUES (%s, %s, %s, %s, %s, %s)",
                (course.courseid, course.name, course.sem_id,
                 course.prog_id, course.dept_id, course.fact_id)
            )
        conn.commit()
        return CourseCreateResponse(success=True, message="Course added to DB")
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
            course_id=row[0],
            course_name=row[1],
            sem_id=row[2],
            prog_id=row[3],
            dept_id=row[4],
            fact_id=row[5]
        )
    return CourseDetailResponse(success=False)

def display_all_courses() -> List[CourseListItem]:
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT courseid, name, semid, progid, deptid, factid FROM course"
        )
        rows = cur.fetchall()
    return [
        CourseListItem(
            course_id=r[0],
            course_name=r[1],
            sem_id=r[2],
            prog_id=r[3],
            dept_id=r[4],
            fact_id=r[5]
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
                    INSERT INTO course (courseid, name, semid, progid, deptid, factid)
                    VALUES (%s, %s, %s, %s, %s, %s)
                    ON CONFLICT (courseid) DO NOTHING
                    """,
                    (c.courseid, c.name, c.sem_id,
                     c.prog_id, c.dept_id, c.fact_id)
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
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT courseid, name, semid, progid, deptid, factid "
            "FROM course WHERE semid = %s",
            (sem_id,)
        )
        rows = cur.fetchall()
    if not rows:
        return CourseDetailResponse(success=False)
    
    courses = [
        CourseListItem(
            course_id=r[0],
            course_name=r[1],
            sem_id=r[2],
            prog_id=r[3],
            dept_id=r[4],
            fact_id=r[5]
        )
        for r in rows
    ]
    
    return CourseDetailResponse(success=True, courses=courses)