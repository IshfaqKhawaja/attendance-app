# app/db/crud/daily_attendance.py
from datetime import date
from typing import List, Dict
from dataclasses import dataclass
from app.db.connection import connection_to_db


@dataclass
class CourseAttendanceSummary:
    """Summarized attendance for a course (handles multiple classes in a day)."""
    course_id: str
    course_name: str
    total_classes: int
    attended: int


@dataclass
class StudentDailyAttendance:
    """Consolidated daily attendance for a student across all courses."""
    student_id: str
    student_name: str
    phone_number: int
    courses: List[CourseAttendanceSummary]


def fetch_daily_attendance(att_date: date) -> List[StudentDailyAttendance]:
    """
    Returns consolidated attendance for each student for the given date.
    Groups multiple classes of the same course and summarizes attendance.
    """
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute("""
            SELECT
              a.student_id,
              s.student_name,
              s.phone_number,
              a.course_id,
              c.course_name,
              a.present
            FROM attendance a
            JOIN students s USING(student_id)
            JOIN course c USING(course_id)
            WHERE a.date = %s
            ORDER BY a.student_id, c.course_name
        """, (att_date,))
        rows = cur.fetchall()

    # Group by student, then by course
    students_dict: Dict[str, Dict] = {}

    for student_id, student_name, phone_number, course_id, course_name, present in rows:
        if student_id not in students_dict:
            students_dict[student_id] = {
                "student_name": student_name,
                "phone_number": phone_number or 0,
                "courses": {}  # course_id -> {course_name, total, attended}
            }

        student = students_dict[student_id]
        if course_id not in student["courses"]:
            student["courses"][course_id] = {
                "course_name": course_name,
                "total_classes": 0,
                "attended": 0
            }

        # Count this class
        student["courses"][course_id]["total_classes"] += 1
        if present:
            student["courses"][course_id]["attended"] += 1

    # Convert to dataclass list
    result = []
    for student_id, data in students_dict.items():
        courses = [
            CourseAttendanceSummary(
                course_id=course_id,
                course_name=info["course_name"],
                total_classes=info["total_classes"],
                attended=info["attended"]
            )
            for course_id, info in data["courses"].items()
        ]
        # Sort courses by name
        courses.sort(key=lambda c: c.course_name)

        result.append(StudentDailyAttendance(
            student_id=student_id,
            student_name=data["student_name"],
            phone_number=data["phone_number"],
            courses=courses
        ))

    return result
