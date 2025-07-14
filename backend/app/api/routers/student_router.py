from fastapi import APIRouter, Body
from app.db.crud.student import (
    add_student_to_db,
    add_students_in_bulk,
    display_student_by_id,
    display_student_by__sem_id,
    fetch_students_by_student_ids,
    
)
from app.schemas.student import BulkStudentIn


router = APIRouter(
     prefix="/student",
     tags=["student"]
)

@router.post("/add", response_model=dict, summary="Insert a new Student")
def add(
    student_id : str = Body(..., embed=True,description="ID of the Student"),
    student_name: str = Body(..., embed=True, description="Name of the new Student"),
    phone_number: int = Body(..., embed=True, description="Phone Number of the new Student"),
    prog_id : str = Body(..., embed=True, description="Program ID to which student belongs to"),
    sem_id : str = Body(..., embed=True,description="ID of Sem which Course Belongs to"),
    dept_id : str  = Body(..., embed=True, description="Departmebt who student belongs"),
) -> dict:
    """
    Expects JSON payload: { "name": "Department of Engineering"}
    """
    return add_student_to_db(
        student_id=student_id,
        name=student_name,
        phone_number=phone_number,
        prog_id=prog_id,
        sem_id=sem_id,
        dept_id=dept_id,
    )


@router.post("/display", response_model=dict, summary="Display Student Details")
def display(student_id: str = Body(..., embed=True, description="Student ID")) -> dict:
    return display_student_by_id(student_id=student_id)




@router.post("/add_students_in_bulk", response_model=dict, summary="Insert multiple students")
def bulk_add_students(
    students: list[BulkStudentIn] = Body(..., embed=True, description="List of students to add")
) -> dict:
    # Pydantic will have parsed the JSON into a list of dicts under the hood
    return add_students_in_bulk([s.dict() for s in students])




@router.post("/display_students_by_sem_id", response_model=dict, summary="Display Student Details")
def display_by_sem_id(sem_id: str = Body(..., embed=True, description="Semester ID")) -> dict:
    return display_student_by__sem_id(sem_id=sem_id)


@router.post("/display_students_by_ids" , response_model=dict, summary="Display Student Details by ids")
def display_students_by_ids(student_ids: list = Body(..., embed=True, description="Student IDs")) -> dict:
    return fetch_students_by_student_ids(student_ids=student_ids)