import os
from app.db.models.attendence_model import ReportBySemId, ReportInput
from app.db.models.report_by_course_id_model import ReportByCourseId
from fastapi import APIRouter, BackgroundTasks # type: ignore
from fastapi.responses import FileResponse # type: ignore
from app.db.reports.generate_report_by_course_id import generate_report_by_course_id_xls, generate_report_by_course_id_pdf
from app.db.reports.generate_report_by_sem_id import  generate_semester_attendance_report_xls
from app.services.generate_course_report import generate_pdf_report
from app.utils.excel_generator import generate_attendance_excel


def delete_file(file_path: str):
    """Delete a file after it has been sent to the client."""
    try:
        if os.path.exists(file_path):
            os.remove(file_path)
            print(f"Deleted report file: {file_path}")
    except Exception as e:
        print(f"Error deleting file {file_path}: {e}")

router = APIRouter(
    prefix="/reports",
    tags=["reports"]
)
@router.post("/generate_course_report_xls", summary="Generate Attendance Report")
def generate_course_report_xls(course_model: ReportByCourseId, background_tasks: BackgroundTasks) -> FileResponse:
    result = generate_report_by_course_id_xls(course_model.course_id)
    data = result.get('data')
    course_info = result.get('info')

    if data is None or data.empty:
        return FileResponse(
            path="",
            filename="",
            media_type="text/plain",
        )

    # Always use server-side path, ignore client file_path (which may be a device path)
    output_dir = "reports"
    os.makedirs(output_dir, exist_ok=True)
    filename = f"attendance_report_{course_model.course_id}.xlsx"
    output_path = os.path.join(output_dir, filename)

    excel_file = generate_attendance_excel(data, output_path, course_info)

    if not excel_file:
        return FileResponse(
            path="",
            filename="",
            media_type="text/plain",
        )

    # Schedule file deletion after response is sent
    background_tasks.add_task(delete_file, excel_file)

    # Return the generated Excel file as a response
    return FileResponse(
        path=excel_file,
        filename=filename,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
    )



@router.post(
    "/generate_course_report_pdf",
    summary="Generate Report for Course Students"
)
def generate_report(data: ReportInput, background_tasks: BackgroundTasks):
    try:
        result = generate_report_by_course_id_pdf(data)
        d = result.get('data')
        course_info = result.get('info')

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
            filename=full_path,
            course_info=course_info
        )

        # Schedule file deletion after response is sent
        background_tasks.add_task(delete_file, pdf_file_path)

        # Return the file itself
        return FileResponse(
            path=pdf_file_path,
            media_type='application/pdf',
            filename=file_name  # This is the name the user will see if they "Save As"
        )

    except Exception as e:
        print(f"Error during report generation: {e}")
        return {
            "success": False,
            "message": f"An error occurred: {e}"
        }
        
        
@router.post("/generate_report_by_sem_id_xls", summary="Generate Attendance Report by Semester ID")
def report_by_sem_id(sem_id: ReportBySemId, background_tasks: BackgroundTasks) -> FileResponse:
    output_dir = "reports"
    os.makedirs(output_dir, exist_ok=True)
    output_path = f"{output_dir}/attendance_report_{sem_id.sem_id}.xlsx"
    generate_semester_attendance_report_xls(sem_id.sem_id, output_path)

    # Schedule file deletion after response is sent
    background_tasks.add_task(delete_file, output_path)

    return FileResponse(
        path=output_path,
        media_type="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        filename=os.path.basename(output_path)
    )