from fastapi import APIRouter, HTTPException, status, Path # type: ignore
from app.db.models.attendence_model import AttendenceModel, BulkAttendenceModel
from app.db.crud.attendance import (
    add_attendence_bulk,
    update_attendance_record,
    check_attendance_exists,
    check_course_attendance_exists_for_date,
    get_student_attendance_summary,
    get_course_attendance_for_date,
)
from datetime import date
from typing import List

router = APIRouter(
    prefix="/attendance",
    tags=["attendance"]
)

@router.post(
    "/add_attendence_bulk",
    response_model=dict,
    summary="Add Attendance (Max 3 records, Course-Date locked after first submission)",
    status_code=status.HTTP_201_CREATED
)
def add_attendance(attendances: BulkAttendenceModel) -> dict:
    """
    Record attendance for students in a course on a specific date.
    
    **Rules:**
    1. Maximum 3 attendance records can be added at once
    2. All records must be for the same course and same date
    3. Once attendance is taken for a course on a date, no more attendance can be added for that course-date combination
    4. Duplicate student records within the same request are skipped
    
    **Request Body:**
    ```json
    {
      "attendances": [
        {
          "student_id": "student123",
          "course_id": "course456",
          "date": "2025-01-15",
          "present": true
        },
        {
          "student_id": "student124",
          "course_id": "course456",
          "date": "2025-01-15",
          "present": false
        }
      ]
    }
    ```
    
    **Responses:**
    - 201: Attendance recorded successfully
    - 400: Validation error (more than 3 records, different courses/dates, etc.)
    - 409: Attendance already exists for this course on this date
    - 500: Internal server error
    """
    try:
        result = add_attendence_bulk(attendances.attendances)
        
        if not result.get("success"):
            # Determine appropriate status code based on error message
            message = result.get("message", "")
            
            if "already been taken" in message.lower() or "already exists" in message.lower():
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail={
                        "error": "Attendance Already Taken",
                        "message": message,
                        "existing_records_count": result.get("existing_records_count", 0)
                    }
                )
            elif "more than 3" in message.lower() or "same course" in message.lower() or "same date" in message.lower():
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail={
                        "error": "Validation Error",
                        "message": message
                    }
                )
            else:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail={
                        "error": "Server Error",
                        "message": message
                    }
                )
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to record attendance"
        )

@router.put(
    "/update",
    response_model=dict,
    summary="Update Existing Attendance"
)
def update_attendance(attendance: AttendenceModel) -> dict:
    """
    Update existing attendance record (change present/absent status).
    This can only be done for existing records, not for adding new ones.
    
    **Request Body:**
    ```json
    {
      "student_id": "student123",
      "course_id": "course456", 
      "date": "2025-01-15",
      "present": false
    }
    ```
    """
    try:
        result = update_attendance_record(attendance)
        if not result.get("success"):
            if "not found" in result.get("message", "").lower():
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail={
                        "error": "Attendance not found",
                        "message": result["message"]
                    }
                )
            else:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail=result["message"]
                )
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to update attendance"
        )

@router.get(
    "/check-course/{course_id}/{date}",
    response_model=dict,
    summary="Check if Attendance Has Been Taken for Course"
)
def check_course_attendance(
    course_id: str = Path(..., description="Course ID"),
    date: date = Path(..., description="Date (YYYY-MM-DD)")
) -> dict:
    """
    Check if attendance has already been taken for a course on a specific date.
    
    **Response:**
    ```json
    {
      "exists": true,
      "course_id": "course456",
      "date": "2025-01-15",
      "records_count": 3
    }
    ```
    """
    try:
        exists = check_course_attendance_exists_for_date(course_id, date)
        
        if exists:
            # Get full details
            details = get_course_attendance_for_date(course_id, date)
            return {
                "exists": True,
                "course_id": course_id,
                "date": str(date),
                "records_count": details.get("total_records", 0),
                "message": "Attendance has already been taken for this course on this date"
            }
        else:
            return {
                "exists": False,
                "course_id": course_id,
                "date": str(date),
                "records_count": 0,
                "message": "Attendance has not been taken yet for this course on this date"
            }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to check attendance status"
        )

@router.get(
    "/course/{course_id}/{date}",
    response_model=dict,
    summary="Get All Attendance Records for Course on Date"
)
def get_course_attendance(
    course_id: str = Path(..., description="Course ID"),
    date: date = Path(..., description="Date (YYYY-MM-DD)")
) -> dict:
    """
    Get all attendance records for a course on a specific date.
    
    **Response:**
    ```json
    {
      "success": true,
      "course_id": "course456",
      "date": "2025-01-15",
      "total_records": 3,
      "attendance_records": [
        {
          "student_id": "student123",
          "course_id": "course456",
          "date": "2025-01-15",
          "present": true
        },
        ...
      ]
    }
    ```
    """
    try:
        result = get_course_attendance_for_date(course_id, date)
        
        if not result.get("success"):
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=result.get("message", "Failed to retrieve attendance")
            )
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to retrieve course attendance"
        )

@router.get(
    "/summary/{student_id}/{course_id}",
    response_model=dict,
    summary="Get Student Attendance Summary"
)
def get_attendance_summary(
    student_id: str = Path(..., description="Student ID"),
    course_id: str = Path(..., description="Course ID")
) -> dict:
    """
    Get attendance summary for a student in a specific course.
    
    **Response:**
    ```json
    {
      "success": true,
      "student_id": "student123",
      "course_id": "course456",
      "summary": {
        "total_classes": 20,
        "classes_attended": 18,
        "classes_missed": 2,
        "attendance_percentage": 90.0
      }
    }
    ```
    """
    try:
        result = get_student_attendance_summary(student_id, course_id)
        
        if not result.get("success"):
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=result["message"]
            )
        
        return result
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to get attendance summary"
        )

@router.get(
    "/check/{student_id}/{course_id}/{date}",
    response_model=dict,
    summary="Check if Attendance Exists for Student"
)
def check_student_attendance(
    student_id: str = Path(..., description="Student ID"),
    course_id: str = Path(..., description="Course ID"),
    date: date = Path(..., description="Date (YYYY-MM-DD)")
) -> dict:
    """
    Check if attendance record exists for a specific student in a course on a date.
    """
    try:
        attendance_record = check_attendance_exists(student_id, course_id, date)
        
        return {
            "exists": attendance_record is not None,
            "attendance": attendance_record
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to check attendance"
        )