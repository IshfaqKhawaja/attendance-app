from fastapi import APIRouter # type: ignore
from fastapi.responses import FileResponse # type: ignore
from app.db.crud import course
from app.db.crud.course_students import (
    add_course_students_to_db,
    add_bulk_course_students_to_db,
    display_course_student_by_id,
    display_course_student_by_course_id,
    display_all,
    add_local_student_to_course,
    remove_student_from_course,
)
from app.db.crud.student import add_students_in_bulk, fetch_students_by_student_ids
from app.db.models.course_student_model import *



router = APIRouter(
    prefix="/course_students",
    tags=["course_students"]
)

@router.post("/add", response_model=dict, summary="Insert a new Course")
def add(course_student: CourseStudent) -> dict:
    return add_course_students_to_db(
        course_std=course_student
    )


@router.post("/add_all_courses_students", response_model=dict, summary="Insert a new Course-Students")
def add_all_teacher_courses(data: BulkCourseStudentInput) -> dict:
    return add_bulk_course_students_to_db(course_students=data)


@router.post("/display", response_model=dict, summary="Display Course")
def display(data: CourseStudent) -> dict:
    return display_course_student_by_id(
        data
        )


@router.post("/fetch_by_course_id", response_model=dict, summary="Display Course by ID")
def fetch_course_student_by_course_id(data: CourseIdInput) -> dict:
    return display_course_student_by_course_id(course_input=data)


@router.get("/fetch_all", response_model=list, summary="Display All Courses Students")
def get_all():
    return display_all()


@router.post("/add_students_to_course", response_model=dict, summary="Add Students to Course")
def add_students_to_course(data: BulkCourseStudentInput) -> dict:
    add_students_in_bulk(students=data)
    course_success = add_bulk_course_students_to_db(data).get("success", False)
    return {
        "success": course_success,
        "message": "Students Added Successfully" if course_success else "Couldn't Add Students"
    }


@router.post("/display_students_by_ids", response_model=dict, summary="Get Students of this Course")
def display_students_by_ids(data: CourseIdInput) -> dict:
    course_students = display_course_student_by_course_id(data).get("course_students", [])
    student_ids = [i["student_id"] for i in course_students]
    students = fetch_students_by_student_ids(student_ids=student_ids).get("students", [])
    return {
        "success": True,
        "students": students
    }


@router.post("/add_local_student", response_model=dict, summary="Add a local/backlog student to a course")
def add_local_student(data: LocalStudentInput) -> dict:
    """
    Add a local/backlog student directly to a course without semester enrollment.
    - If the student doesn't exist, creates them first (without semester enrollment)
    - Then adds them to the specified course only
    """
    return add_local_student_to_course(data)


@router.post("/remove_student_from_course", response_model=dict, summary="Remove a student from a course")
def remove_student(data: CourseStudent) -> dict:
    """
    Remove a student from a specific course only.
    This does NOT remove them from the semester enrollment - only from this course.
    """
    return remove_student_from_course(data)


