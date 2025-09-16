import os
from fastapi import APIRouter
from fastapi.responses import FileResponse # type: ignore
from app.db.models.attendence_model import AttendenceModel, AttendenceIdModel, BulkAttendenceModel, BulkAttendenceResponseModel
from app.db.crud.attendance import (
    add_attendence_bulk,
    add_attendence_to_db,
    display_attendence_by_id,
    fetch_attendance_report
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
    
    

@router.post(
    "/generate_report",
    summary="Generate Report for Course Students"
    # 2. REMOVED 'response_model=dict'
)
def generate_report(data: ReportInput): # <-- 3. REMOVED '-> dict'
    try:
        d = fetch_attendance_report(data)
        
        if not d:
            # Handle case where no data is found
            return {"success": False, "message": "No attendance data found for this report."}

        output_dir = "reports"
        file_name = f"{data.course_id}_{data.start_date}_{data.end_date}_report.pdf"
        full_path = os.path.join(output_dir, file_name)

        os.makedirs(output_dir, exist_ok=True)
        
        # This function returns the file path
        pdf_file_path = generate_pdf_report(
            data=d,
            course_id=data.course_name,
            start_date=data.start_date,
            end_date=data.end_date,
            filename=full_path
        )
        
        # 4. INSTEAD of returning JSON, return the file itself
        return FileResponse(
            path=pdf_file_path,
            media_type='application/pdf',
            filename=file_name  # This is the name the user will see if they "Save As"
        )

    except Exception as e:
        print(f"Error during report generation: {e}")
        # Return a JSON error if something goes wrong
        return {
            "success": False,
            "message": f"An error occurred: {e}"
        }