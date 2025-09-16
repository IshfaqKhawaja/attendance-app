from fastapi import APIRouter, Body
from app.db.crud.teacher_course import add_bulk_teacher_courses_to_db, add_teacher_course_to_db, display_all, display_teacher_course_by_teacher_id
from app.db.models.teacher_course_model import BulkTeacherCourseIn, TeacherCourseDetail, TeacherCourseIn, TeacherCourseResponse



router = APIRouter(
     prefix="/teacher_course",
     tags=["teacher_course"]
)

@router.post("/add", response_model=dict, summary="Insert a new Course")
def add(
    teacher_course : TeacherCourseIn
) -> dict:
    """
    Expects JSON payload: { "name": "Department of Engineering"}
    """
    return add_teacher_course_to_db(
            teacher_course=teacher_course
    )
    
    
@router.post("/add_all_teacher_courses", response_model=dict, summary="Insert a new Course")
def add_all_teacher_courses(
    courses : BulkTeacherCourseIn
) -> dict:
    """
    Expects JSON payload: { "name": "Department of Engineering"}
    """
    return add_bulk_teacher_courses_to_db(courses)

@router.get("/display/{teacher_id}", response_model=TeacherCourseResponse, summary="Display Course")
def display(teacher_id: str) -> TeacherCourseResponse:
    return display_teacher_course_by_teacher_id(teacher_id=teacher_id)


@router.get("/fetch_all",  response_model=list, summary="Display All Teacher Courses")
def get_all():
    return display_all()