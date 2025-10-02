from typing import List, Optional, Dict, Any
from datetime import date, datetime
from app.db.connection import connection_to_db
from app.db.models.attendence_model import AttendenceModel, AttendenceIdModel, BulkAttendenceResponseModel, ReportInput

def check_attendance_exists(student_id: str, course_id: str, date: date) -> Optional[Dict[str, Any]]:
    """
    Check if attendance record exists for student/course/date combination.
    
    Returns:
        Dict with attendance data if exists, None otherwise
    """
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT student_id, course_id, date, present 
                FROM attendance 
                WHERE student_id = %s AND course_id = %s AND date = %s
                """,
                (student_id, course_id, date)
            )
            
            row = cur.fetchone()
            if row:
                return {
                    "student_id": row[0],
                    "course_id": row[1],
                    "date": row[2],
                    "present": row[3]
                }
            return None
            
    except Exception as e:
        raise
    finally:
        conn.close()

def check_course_attendance_exists_for_date(course_id: str, attendance_date: date) -> bool:
    """
    Check if ANY attendance record exists for a course on a specific date.
    This is used to determine if attendance has already been taken for the course.
    
    Returns:
        True if attendance exists for this course on this date, False otherwise
    """
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT EXISTS(
                    SELECT 1 FROM attendance 
                    WHERE course_id = %s AND date = %s
                )
                """,
                (course_id, attendance_date)
            )
            
            result = cur.fetchone()
            print(result)
            return result[0] if result else False
            
    except Exception as e:
        raise
    finally:
        conn.close()

def get_attendance_count_for_course_date(course_id: str, attendance_date: date) -> int:
    """
    Get the count of attendance records for a course on a specific date.
    
    Returns:
        Number of attendance records
    """
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT COUNT(*) FROM attendance 
                WHERE course_id = %s AND date = %s
                """,
                (course_id, attendance_date)
            )
            
            result = cur.fetchone()
            return result[0] if result else 0
            
    except Exception as e:
        raise
    finally:
        conn.close()

def add_attendence_to_db(model: AttendenceModel) -> dict:
    """
    Insert a single attendance record using an AttendenceModel.
    NOT RECOMMENDED: Use add_attendence_bulk instead for proper validation.
    """
    return add_attendence_bulk([model])

def update_attendance_record(model: AttendenceModel) -> dict:
    """
    Update existing attendance record.
    
    Args:
        model: AttendenceModel object
        
    Returns:
        Dict with success status and updated attendance data
    """
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                UPDATE attendance 
                SET present = %s
                WHERE student_id = %s AND course_id = %s AND date = %s
                RETURNING student_id, course_id, date, present
                """,
                (model.present, model.student_id, model.course_id, model.date)
            )
            
            row = cur.fetchone()
            if not row:
                return {
                    "success": False,
                    "message": f"No attendance record found for student {model.student_id} in course {model.course_id} on {model.date}"
                }
            
            conn.commit()
            
            return {
                "success": True,
                "message": "Attendance updated successfully",
                "attendance": {
                    "student_id": row[0],
                    "course_id": row[1],
                    "date": row[2],
                    "present": row[3]
                }
            }
            
    except Exception as e:
        conn.rollback()
        return {"success": False, "message": f"Couldn't update attendance: {e}"}
    finally:
        conn.close()

def add_attendence_bulk(attendances: List[AttendenceModel]) -> dict:
    """
    Bulk-insert multiple attendance records with validation:
    
    RULES:
    1. Allow: First time attendance for any course on any date
    2. Allow: Attendance for different dates (even same course)  
    3. Block: Attendance for same course + same date (if already exists)
    
    Args:
        attendances: List of AttendenceModel objects
        
    Returns:
        Dict with success status, added records, and validation messages
    """
    print(f"Received {len(attendances)} attendance records")
    
    # Validation 1: Check if list is empty
    if not attendances:
        return {
            "success": False,
            "message": "No attendance records provided",
            "total_records": 0,
            "added": 0,
            "skipped": 0
        }
    
    # Extract course_id and date (convert datetime to date if needed)
    first_course_id = attendances[0].course_id
    first_datetime = attendances[0].date
    
    # Convert datetime to date for comparison
    if isinstance(first_datetime, datetime):
        first_date = first_datetime.date()
    else:
        first_date = first_datetime
        
    # Validation 3: Group records by student and check max 3 per student
    student_records = {}
    for attendance in attendances:
        student_id = attendance.student_id
        if student_id not in student_records:
            student_records[student_id] = []
        student_records[student_id].append(attendance)
    
    # Check if any student has more than 3 records
    for student_id, records in student_records.items():
        if len(records) > 3:
            return {
                "success": False,
                "message": f"Student {student_id} has {len(records)} attendance records. Maximum 3 records per student allowed.",
                "total_records": len(attendances),
                "added": 0,
                "skipped": 0
            }
    
    print(f"Found {len(student_records)} unique students")
    
    # Validation 4: THE MAIN RULE - Check if attendance already exists for this course on this date
    try:
        if check_course_attendance_exists_for_date(first_course_id, first_date):
            existing_count = get_attendance_count_for_course_date(first_course_id, first_date)
            print(f"BLOCKED: Attendance already exists for course {first_course_id} on {first_date}")
            return {
                "success": False,
                "message": f"Attendance already taken for this course on {first_date}. Cannot add new attendance.",
                "existing_records_count": existing_count,
                "course_id": first_course_id,
                "date": str(first_date),
                "total_records": len(attendances),
                "added": 0,
                "skipped": len(attendances)
            }
        else:
            print(f"ALLOWED: No existing attendance for course {first_course_id} on {first_date}")
    except Exception as e:
        print(f"Error checking existing attendance: {str(e)}")
        return {
            "success": False,
            "message": f"Error validating attendance: {str(e)}",
            "total_records": len(attendances),
            "added": 0,
            "skipped": 0
        }
    
    # All validations passed, now insert records
    conn = connection_to_db()
    try:
        added_count = 0
        skipped_count = 0
        added_records = []
        skipped_records = []
        
        with conn.cursor() as cur:
            for model in attendances:
                try:
                    # Convert datetime to date for database insertion
                    date_value = model.date.date() if isinstance(model.date, datetime) else model.date
                    
                    # Insert new record
                    cur.execute(
                        """
                        INSERT INTO attendance (student_id, course_id, date, present)
                        VALUES (%s, %s, %s, %s)
                        RETURNING student_id, course_id, date, present
                        """,
                        (model.student_id, model.course_id, date_value, model.present)
                    )
                    
                    row = cur.fetchone()
                    added_count += 1
                    added_records.append({
                        "student_id": row[0],
                        "course_id": row[1],
                        "date": str(row[2]),
                        "present": row[3]
                    })
                    
                except Exception as e:
                    print(f"Error inserting record for student {model.student_id}: {str(e)}")
                    skipped_count += 1
                    skipped_records.append({
                        "student_id": model.student_id,
                        "course_id": model.course_id,
                        "date": str(model.date),
                        "reason": f"Error: {str(e)}"
                    })
                    continue
        
        conn.commit()
        
        print(f"SUCCESS: Attendance added for course {first_course_id} on {first_date}")
        print(f"Results: {added_count} added, {skipped_count} skipped")
        
        return {
            "success": True,
            "message": f"Attendance recorded successfully: {added_count} added, {skipped_count} skipped",
            "course_id": first_course_id,
            "date": str(first_date),
            "total_records": len(attendances),
            "unique_students": len(student_records),
            "added": added_count,
            "skipped": skipped_count,
            "added_records": added_records,
            "skipped_records": skipped_records
        }
        
    except Exception as e:
        conn.rollback()
        print(f"Bulk operation failed: {str(e)}")
        return {
            "success": False,
            "message": f"Bulk operation failed: {str(e)}",
            "total_records": len(attendances),
            "added": 0,
            "skipped": 0
        }
    finally:
        conn.close()

def display_attendence_by_id(attendence_id: AttendenceIdModel) -> dict:
    """
    Fetches the attendance row with the given ID and returns it as a dict,
    or returns success=False if not found.
    """
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT student_id, course_id, date, present 
                FROM attendance 
                WHERE attendance_id = %s
                """,
                (attendence_id.attendance_id,)
            )
            row = cur.fetchone()

        if not row:
            return {
                "success": False,
                "message": f"No attendance record found with ID: {attendence_id.attendance_id}"
            }

        return {
            "success": True,
            "attendance": {
                "student_id": row[0],
                "course_id": row[1],
                "date": row[2],
                "present": row[3]
            }
        }
        
    except Exception as e:
        return {"success": False, "message": f"Couldn't retrieve attendance: {e}"}
    finally:
        conn.close()

def get_attendance_by_student_course_date(student_id: str, course_id: str, attendance_date: date) -> Optional[Dict[str, Any]]:
    """
    Get attendance record by student, course, and date.
    
    Returns:
        Dict with attendance data if found, None otherwise
    """
    return check_attendance_exists(student_id, course_id, attendance_date)

def get_student_attendance_summary(student_id: str, course_id: str) -> dict:
    """
    Get attendance summary for a student in a specific course.
    
    Returns:
        Dict with attendance statistics
    """
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT 
                    COUNT(*) as total_classes,
                    COUNT(*) FILTER (WHERE present = true) as classes_attended,
                    COUNT(*) FILTER (WHERE present = false) as classes_missed,
                    ROUND(
                        (COUNT(*) FILTER (WHERE present = true) * 100.0 / NULLIF(COUNT(*), 0)), 2
                    ) as attendance_percentage
                FROM attendance 
                WHERE student_id = %s AND course_id = %s
                """,
                (student_id, course_id)
            )
            
            row = cur.fetchone()
            
            return {
                "success": True,
                "student_id": student_id,
                "course_id": course_id,
                "summary": {
                    "total_classes": row[0],
                    "classes_attended": row[1],
                    "classes_missed": row[2],
                    "attendance_percentage": float(row[3]) if row[3] else 0.0
                }
            }
            
    except Exception as e:
        return {"success": False, "message": f"Couldn't get attendance summary: {e}"}
    finally:
        conn.close()

def get_course_attendance_for_date(course_id: str, attendance_date: date) -> dict:
    """
    Get all attendance records for a course on a specific date.
    
    Returns:
        Dict with list of attendance records
    """
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT student_id, course_id, date, present 
                FROM attendance 
                WHERE course_id = %s AND date = %s
                ORDER BY student_id
                """,
                (course_id, attendance_date)
            )
            
            rows = cur.fetchall()
            
            records = []
            for row in rows:
                records.append({
                    "student_id": row[0],
                    "course_id": row[1],
                    "date": str(row[2]),
                    "present": row[3]
                })
            
            return {
                "success": True,
                "course_id": course_id,
                "date": str(attendance_date),
                "total_records": len(records),
                "attendance_records": records
            }
            
    except Exception as e:
        return {"success": False, "message": f"Couldn't get course attendance: {e}"}
    finally:
        conn.close()