import pandas as pd
from app.db.connection import connection_to_db
from typing import List, Optional, Dict, Any
from app.db.models.attendence_model import ReportInput


def get_course_info(course_id: str) -> Dict[str, str]:
    """
    Get course, semester, and program information for the report header.
    """
    with connection_to_db() as conn:
        with conn.cursor() as cur:
            query = """
                SELECT
                    c.course_id,
                    c.course_name,
                    sem.sem_name,
                    p.prog_name
                FROM course c
                JOIN semester sem ON c.sem_id = sem.sem_id
                JOIN program p ON sem.prog_id = p.prog_id
                WHERE c.course_id = %s
                LIMIT 1;
            """
            cur.execute(query, (course_id,))
            row = cur.fetchone()
            if row:
                return {
                    'course_id': row[0],
                    'course_name': row[1],
                    'sem_name': row[2],
                    'prog_name': row[3]
                }
            return {
                'course_id': course_id,
                'course_name': 'Unknown Course',
                'sem_name': 'Unknown Semester',
                'prog_name': 'Unknown Program'
            }


def generate_report_by_course_id_xls(course_id: str, start_date: Optional[str] = None, end_date: Optional[str] = None) -> Dict[str, Any]:
    """
    Fetches all individual attendance records for a course, handling multiple
    sessions per day by assigning a lecture number.

    Args:
        course_id (str): The course ID to filter on.
        start_date (str, optional): Start date (YYYY-MM-DD).
        end_date (str, optional): End date (YYYY-MM-DD).

    Returns:
        Dict with 'data' (pd.DataFrame) and 'info' (course info dict).
    """
    # Get course info for report header
    course_info = get_course_info(course_id)

    # Using 'with' statements for safe connection handling
    with connection_to_db() as conn:
        with conn.cursor() as cur:
            # The SQL query generates a lecture number and formats the status
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
            if cur.description:
                columns = [desc[0] for desc in cur.description]
                df = pd.DataFrame(rows, columns=columns)
            else:
                df = pd.DataFrame(rows)

            return {
                'data': df,
                'info': course_info
            }


def generate_report_by_course_id_pdf(report: ReportInput) -> Dict[str, Any]:
    """
    Fetches an aggregated summary of attendance for a course,
    perfect for summary reports like PDFs.

    Args:
        report (ReportInput): Pydantic model with course_id, start_date, and end_date.

    Returns:
        Dict with 'data' (List of tuples) and 'info' (course info dict).

    Note: Total classes is calculated per student - only counts days where
          that student has an attendance record. Students who joined late
          won't be penalized for days before they were enrolled.
    """
    # Get course info for report header
    course_info = get_course_info(report.course_id)

    with connection_to_db() as conn:
        with conn.cursor() as cur:
            # Get per-student attendance where total is based on their own records
            # This ensures students who joined late are not penalized
            query = """
                SELECT
                  s.student_id,
                  s.student_name,
                  COUNT(*) FILTER (WHERE a.present = true) AS present_days,
                  COUNT(*) AS total_classes
                FROM attendance a
                JOIN students s ON a.student_id = s.student_id
                WHERE a.course_id = %s
                  AND a.date BETWEEN %s AND %s
                GROUP BY s.student_id, s.student_name
                ORDER BY s.student_name;
            """
            cur.execute(query, (report.course_id, report.start_date, report.end_date))
            rows = cur.fetchall()

    return {
        'data': rows,
        'info': course_info
    }