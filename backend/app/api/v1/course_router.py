import uuid
from app.db.crud.semester import display_semester_with_details_by_id
from fastapi import APIRouter, Body # type: ignore

from app.db.crud.course import *

from app.db.models.course_model import (
    CourseCreate,
    CourseCreateResponse,
    CourseDetailResponse,
    CourseListItem,
    BulkCourseCreate,
    BulkCourseCreateResponse,
)

router = APIRouter(
     prefix="/course",
     tags=["course"]
)

@router.post("/add", response_model=CourseCreateResponse, summary="Insert a new Course")
def add(
    course : CourseCreate
) -> CourseCreateResponse:
    """
    Expects JSON payload: { "name": "Department of Engineering"}
    """
    courseid = str(uuid.uuid4().hex)
    name = course.name
    sem_id = course.sem_id
    # Find the program, department, and faculty IDs from the database using sem_id
    sem_details = display_semester_with_details_by_id(sem_id)
    prog_id = sem_details.prog_id or ""
    dept_id = sem_details.dept_id or ""
    fact_id = sem_details.fact_id or ""
    if not all([prog_id, dept_id, fact_id]):
        raise ValueError("Program ID (prog_id), Department ID (dept_id), and Faculty ID (fact_id) cannot be empty for the given semester.")
    db_course = CourseCreateForDB(
        courseid=courseid,
        name=name,
        sem_id=sem_id,
        prog_id=prog_id,
        dept_id=dept_id,
        fact_id=fact_id
    )
    return add_course_to_db(db_course)
    


@router.post("/display", response_model=CourseDetailResponse, summary="Display Course")
def display(course_id: str = Body(..., embed=True, description="Course ID")) -> CourseDetailResponse:
    return display_course_by_id(course_id)


@router.get("/display_all", response_model=list[CourseListItem])
def list_courses():
    return display_all_courses()



@router.post("/bulk_add", response_model=BulkCourseCreateResponse)
def bulk_add_courses(payload: BulkCourseCreate):
    return add_courses_bulk(payload)



@router.get("/display_courses_by_semester_id/{sem_id}", response_model=CourseDetailResponse, summary="Get Course Details")
def display_courses_by_semester_id(sem_id: str) -> CourseDetailResponse:
    return fetch_courses_by_semester_id(sem_id)
