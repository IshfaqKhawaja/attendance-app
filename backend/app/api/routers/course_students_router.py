from fastapi import APIRouter, Body
from app.db.crud.course_students import *
from app.db.crud.student import (
    add_students_in_bulk,
    fetch_students_by_student_ids
)


router = APIRouter(
     prefix="/course_students",
     tags=["course_students"]
)

@router.post("/add", response_model=dict, summary="Insert a new Course")
def add(
    student_id : str = Body(..., embed=True,description="ID of the Student"),
    course_id: str = Body(..., embed=True, description="ID of the Course"),
    sem_id : str = Body(..., embed=True,description="ID of Sem which Course Belongs to"),
    dept_id : str  = Body(..., embed=True, description="ID of the Dept"),
    prog_id : str  = Body(..., embed=True, description="ID of Program"),
) -> dict:
    """
    Expects JSON payload: { "name": "Department of Engineering"}
    """
    return add_course_students_to_db(
      student_id=student_id,
      course_id=course_id,
      dept_id=dept_id,
      prog_id=prog_id,
      sem_id=sem_id,
    )
    
    
@router.post("/add_all_courses_students", response_model=dict, summary="Insert a new Course-Students")
def add_all_teacher_courses(
    courses_students : list = Body(...,embed=True, description="Adding Courses in Teacher Course in bulk")
) -> dict:
    """
    Expects JSON payload: { "name": "Department of Engineering"}
    """
    return add_bulk_course_students_to_db(course_students=courses_students)

@router.post("/display", response_model=dict, summary="Display Course")
def display(
    student_id: str = Body(..., embed=True, description="Student ID"),
    course_id : str = Body(..., embed=True, description="Course ID")) -> dict:
    return display_course_student_by_id(course_id=course_id, students_id=student_id)

@router.post("/fetch_by_course_id", response_model=dict, summary="Display Course by ID")
def fetch_course_student_by_course_id(course_id : str = Body(..., embed=True, description="Course ID")) -> dict:
    return display_course_student_by_course_id(course_id=course_id)

@router.get("/fetch_all",  response_model=list, summary="Display All Courses Students::")
def get_all():
    return display_all()


@router.post("/add_students_to_course", response_model=dict, summary="Add Students to Course")
def add_students_to_course(
    students: list = Body(..., embed=True, description="Student IDs"),
    course_students: list = Body(..., embed=True, description="Course IDs")
)-> dict:
    students_success  = add_students_in_bulk(students=students).get("success", False)
    course_success = add_bulk_course_students_to_db(course_students=course_students).get("success", False)
    
    return {
        "success" : course_success,
        "message" : "Students Added Successfully" if course_success else "Couldn't Add Students"
    }
        
@router.post("/display_students_by_ids",response_model=dict, summary="Get Students of this Course")
def display_students_by_ids(
    course_id: str = Body(..., embed=True, description="Course ID"),
)-> dict:
    course_students = display_course_student_by_course_id(course_id=course_id).get("course_students", [])
    student_ids = [i["student_id"] for i in course_students]
    students  = fetch_students_by_student_ids(student_ids=student_ids).get("students", [])
    return {
        "success" : True,
        "students" : students
    }
    