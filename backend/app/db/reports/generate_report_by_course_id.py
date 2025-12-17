import pandas as pd
from app.db.connection import connection_to_db
from typing import List, Optional
from app.db.models.attendence_model import ReportInput



def generate_report_by_course_id_xls(course_id: str, start_date: Optional[str] = None, end_date: Optional[str] = None) -> pd.DataFrame:
    """
    Fetches all individual attendance records for a course, handling multiple 
    sessions per day by assigning a lecture number.

    Args:
        course_id (str): The course ID to filter on.
        start_date (str, optional): Start date (YYYY-MM-DD).
        end_date (str, optional): End date (YYYY-MM-DD).

    Returns:
        pd.DataFrame with columns: student_id, student_name, date, lecture_num, status ('P' or 'A').
    """
    # CHANGED: Using 'with' statements for safe connection handling
    with connection_to_db() as conn:
        with conn.cursor() as cur:
            # CHANGED: The SQL query now generates a lecture number and formats the status
            query = """
                WITH NumberedAttendance AS (
                    SELECT
                        student_id,
                        date,
                        present,
                        -- Assign a unique number to each attendance record for a student on the same day.
                        -- We order by ctid, a system column that reflects physical row order, ensuring a stable sort.
                        ROW_NUMBER() OVER(PARTITION BY student_id, date ORDER BY ctid) as lecture_num
                    FROM attendance
                    WHERE course_id = %(course_id)s
                )
                SELECT 
                    s.student_id,
                    s.student_name,
                    na.date,
                    na.lecture_num,
                    CASE WHEN na.present THEN 'P' ELSE 'A' END AS status
                FROM NumberedAttendance na
                JOIN students s ON na.student_id = s.student_id
            """

            params = {'course_id': course_id}

            # Append date filters safely
            date_filters = []
            if start_date:
                date_filters.append("na.date >= %(start_date)s")
                params['start_date'] = start_date
            if end_date:
                date_filters.append("na.date <= %(end_date)s")
                params['end_date'] = end_date
            
            if date_filters:
                query += " WHERE " + " AND ".join(date_filters)

            query += " ORDER BY s.student_name, na.date, na.lecture_num;"

            cur.execute(query, params)
            rows = cur.fetchall()
            
            # Get column names from the cursor description
            # cur.description can be None (some DB adapters or queries without result sets),
            # so guard against that to avoid iterating over None.
            if cur.description:
                columns = [desc[0] for desc in cur.description]
                df = pd.DataFrame(rows, columns=columns)
            else:
                # No column description available; let pandas infer column labels
                df = pd.DataFrame(rows)
            return df


def generate_report_by_course_id_pdf(report: ReportInput) -> List:
    """
    Fetches an aggregated summary of attendance for a course,
    perfect for summary reports like PDFs.

    Args:
        report (ReportInput): Pydantic model with course_id, start_date, and end_date.

    Returns:
        List of tuples: (student_id, student_name, present_days, total_classes).
    """
    with connection_to_db() as conn:
        with conn.cursor() as cur:
            # Get total number of classes held for this course in the date range
            # Total classes = maximum attendance records for any student
            # This represents the actual number of class sessions held
            total_classes_query = """
                SELECT COALESCE(MAX(student_attendance_count), 0)
                FROM (
                    SELECT COUNT(*) as student_attendance_count
                    FROM attendance
                    WHERE course_id = %s
                      AND date BETWEEN %s AND %s
                    GROUP BY student_id
                ) AS student_counts;
            """

            cur.execute(total_classes_query, (
                report.course_id, report.start_date, report.end_date
            ))
            total_classes = cur.fetchone()[0] or 0

            # Now get per-student attendance with the fixed total for all students
            query = """
                SELECT
                  s.student_id,
                  s.student_name,
                  COUNT(*) FILTER (WHERE a.present = true) AS present_days,
                  %s AS total_classes
                FROM attendance a
                JOIN students s ON a.student_id = s.student_id
                WHERE a.course_id = %s
                  AND a.date BETWEEN %s AND %s
                GROUP BY s.student_id, s.student_name
                ORDER BY s.student_name;
            """
            cur.execute(query, (total_classes, report.course_id, report.start_date, report.end_date))
            rows = cur.fetchall()

    return rows