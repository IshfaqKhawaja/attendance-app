from fastapi import APIRouter, Body # type: ignore

from app.db.crud.course import *

from app.models.course_model import (
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

@router.post("/add", response_model=dict, summary="Insert a new Course")
def add(
    course : CourseCreate
) -> dict:
    """
    Expects JSON payload: { "name": "Department of Engineering"}
    """
    return add_course_to_db(
       course=course
    )


@router.post("/display", response_model=dict, summary="Display Course")
def display(course_id: str = Body(..., embed=True, description="Course ID")) -> dict:
    return display_course_by_id(course_id)


@router.get("/display_all", response_model=list[CourseListItem])
def list_courses():
    return display_all_courses()



@router.post("/bulk_add", response_model=BulkCourseCreateResponse)
def bulk_add_courses(payload: BulkCourseCreate):
    return add_courses_bulk(payload)