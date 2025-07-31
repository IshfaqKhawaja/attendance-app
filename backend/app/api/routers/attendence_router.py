from typing import List
from fastapi import APIRouter # type: ignore
from app.models.attendence_model import AttendenceModel, AttendenceIdModel, BulkAttendenceModel
from app.db.crud.attendance import (
    add_attendence_bulk,
    add_attendence_to_db,
    display_attendence_by_id
)
from app.utils.make_id import make_attendance_id

router = APIRouter(
    prefix="/attendance",
    tags=["attendance"]
)

@router.post(
    "/add",
    response_model=dict,
    summary="Record New Attendence"
)
def add(attendance: AttendenceModel) -> dict:
    """
    Expects JSON payload matching AttendenceModel:
    {
      "attendence_id": "...",
      "student_id": "...",
      "course_id": "...",
      "date": "2025-07-14T10:00:00",
      "present": true,
      "prog_id": "...",
      "sem_id": "...",
      "dept_id": "..."
    }
    """
    return add_attendence_to_db(attendance)


@router.post(
    "/display",
    response_model=dict,
    summary="Display Attendence Details"
)
def display(payload: AttendenceIdModel) -> dict:
    """
    Expects JSON payload:
    { "attendance_id": "att123" }
    """
    return display_attendence_by_id(payload)



@router.post(
    "/add_attendence_bulk",
    response_model=dict,
    summary="Buld Add Attendence"
)
def add_attendence_bulk_endpoint(bulk_attendance: List[BulkAttendenceModel]) -> dict:
    """
    Expects JSON payload matching AttendenceModel:
    [{
      "student_id": "...",
      "course_id": "...",
      "date": "2025-07-14T10:00:00",
      "marked": [true],
      "prog_id": "...",
      "sem_id": "...",
      "dept_id": "..."
    }
    ...
    ]
    """
    attendance : List[AttendenceModel] = []
    
    for att in bulk_attendance:
        for mark in att.marked:
            a = AttendenceModel(
                        attendance_id = make_attendance_id(),
                        student_id = att.student_id,
                        course_id = att.course_id,
                        date =  att.date,
                        present = mark,
                        prog_id = att.prog_id,
                        sem_id = att.sem_id,
                        dept_id = att.dept_id
                        )
            attendance.append(a)
            
            
        
        
    return add_attendence_bulk(attendance)
    
    
