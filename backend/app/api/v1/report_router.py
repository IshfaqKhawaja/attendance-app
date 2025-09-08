from app.db.models.report_by_course_id_model import ReportByCourseId
from fastapi import APIRouter # type: ignore
from fastapi.responses import FileResponse # type: ignore
from app.db.reports.generate_report_by_course_id import generate_report_by_course_id
from app.utils.excel_generator import generate_attendance_excel

router = APIRouter(
    prefix="/reports",
    tags=["reports"]
)

@router.post("/generate_course_report", summary="Generate Attendance Report")
def generate_report(course_model: ReportByCourseId) -> dict:
    data = generate_report_by_course_id(course_model.course_id)
    if data.empty:
        return {"success": False, "message": "No attendance data found for the specified course."}

    output_path = course_model.file_path or "attendance_report.xlsx"
    excel_file = generate_attendance_excel(data, output_path)

    if not excel_file:
        return {"success": False, "message": "Failed to generate report."}
    # Return the generated Excel file as a response and success message
    return {
        "success": True,
        "message": "Report generated successfully.",
        "file_path": excel_file
    }
