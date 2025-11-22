from fastapi import APIRouter, Body # type: ignore
from app.db.crud.student import (
    add_student_to_db,
    add_students_in_bulk,
    display_student_by_id,
    update_student_by_id,
)
from app.db.crud.student_enrolement import display_students_by_sem_id, fetch_students_by_course_id
from app.db.models.student_enrolement_model import DisplayStudentsBySemIdResponseModel, StudentCourseEnrolementModel, StudentEnrollmentDetailsModel
from app.db.models.student_model import BulkStudentIn, StudentIn, StudentUpdate


router = APIRouter(
     prefix="/student",
     tags=["student"]
)

@router.post("/add", response_model=dict, summary="Insert a new Student")
def add(
    student : StudentIn
) -> dict:
    """
    Expects JSON payload: { "name": "Department of Engineering"}
    """
    return add_student_to_db(
         student=student
    )


@router.post("/display", response_model=dict, summary="Display Student Details")
def display(student_id: str = Body(..., embed=True, description="Student ID")) -> dict:
    return display_student_by_id(student_id=student_id)




@router.post("/add_students_in_bulk", response_model=dict, summary="Insert multiple students")
def bulk_add_students(
    students: BulkStudentIn = Body(..., embed=True, description="List of students to add")
) -> dict:
    # Pydantic will have parsed the JSON into a list of dicts under the hood
    return add_students_in_bulk(students=students)




@router.post("/display_students_by_sem_id", response_model=DisplayStudentsBySemIdResponseModel, summary="Display Student Details")
def display_by_sem_id(sem_id: str = Body(..., embed=True, description="Semester ID")) -> DisplayStudentsBySemIdResponseModel:
    return display_students_by_sem_id(sem_id=sem_id)


@router.post("/edit", response_model=dict, summary="Update a Student")
def edit_student(student_update: StudentUpdate) -> dict:
    """
    Update student name and/or phone number.
    Expects JSON payload: { "student_id": "...", "student_name": "...", "phone_number": ... }
    """
    return update_student_by_id(student_update)
