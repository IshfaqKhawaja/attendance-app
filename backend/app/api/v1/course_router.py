from fastapi import APIRouter, Body # type: ignore

from app.db.crud.course import *

from app.db.models.course_model import (
    CourseCreate,
    CourseCreateResponse,
    CourseDetailResponse,
    BulkCourseCreate,
    BulkCourseCreateResponse,
    CourseUpdate,
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
    return add_course_to_db(course)



@router.post("/display", response_model=CourseDetailResponse, summary="Display Course")
def display(course_id: str = Body(..., embed=True, description="Course ID")) -> CourseDetailResponse:
    return display_course_by_id(course_id)


@router.get("/display_all", response_model=list[CourseDetailResponse])
def list_courses():
    return display_all_courses()



@router.post("/bulk_add", response_model=BulkCourseCreateResponse)
def bulk_add_courses(payload: BulkCourseCreate):
    return add_courses_bulk(payload)



@router.get("/display_courses_by_semester_id/{sem_id}", response_model=CourseDetailResponse, summary="Get Course Details")
def display_courses_by_semester_id(sem_id: str) -> CourseDetailResponse:
    return fetch_courses_by_semester_id(sem_id)


@router.get("/delete/{course_id}", response_model=CourseCreateResponse, summary="Delete a Course")
def delete_course(course_id: str) -> CourseCreateResponse:
    return delete_course_by_id(course_id)


@router.post("/edit", response_model=CourseCreateResponse, summary="Update a Course")
def edit_course(course_update: CourseUpdate) -> CourseCreateResponse:
    """
    Update course name and/or assigned teacher.
    Expects JSON payload: { "course_id": "...", "course_name": "...", "assigned_teacher_id": "..." }
    """
    return update_course_by_id(course_update)
