import os
from fastapi import APIRouter
from fastapi.responses import FileResponse # type: ignore
from app.db.models.attendence_model import AttendenceModel, AttendenceIdModel, BulkAttendenceModel, BulkAttendenceResponseModel
from app.db.crud.attendance import (
    add_attendence_bulk,
    add_attendence_to_db,
    display_attendence_by_id,
)
from app.db.models.attendence_model import ReportInput
from app.services.generate_course_report import  generate_pdf_report

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
      "student_id": "...",
      "course_id": "...",
      "date": "2025-07-14T10:00:00",
      "present": true,
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
    response_model=BulkAttendenceResponseModel,
    summary="Bulk Add Attendence"
)
def add_attendence_bulk_endpoint(attendances: BulkAttendenceModel) -> BulkAttendenceResponseModel :
    """
    Expects JSON payload matching AttendenceModel:
    [{
      "student_id": "...",
      "course_id": "...",
      "date": "2025-07-14T10:00:00",
      "marked": [true],
    }
    ...
    ]
    """ 
    return add_attendence_bulk(attendances.attendances)