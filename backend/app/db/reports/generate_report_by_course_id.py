import pandas as pd
from app.db.connection import connection_to_db
from typing import Optional
def generate_report_by_course_id(course_id: str, start_date: Optional[str] = None, end_date: Optional[str] = None):
    """
    Fetch attendance records for a course (optionally filtered by date range).

    Args:
        course_id (str): Course ID to filter on.
        start_date (str, optional): Start date (inclusive), format 'YYYY-MM-DD'.
        end_date (str, optional): End date (inclusive), format 'YYYY-MM-DD'.

    Returns:
        pd.DataFrame: DataFrame containing studentid, student_name, date, present.
    """
    conn = connection_to_db()
    cur = conn.cursor()

    query = """
        SELECT 
            s.studentid,
            s.name AS student_name,
            a.date,
            a.present
        FROM attendance a
        JOIN students s ON a.studentid = s.studentid
        WHERE a.courseid = %s
    """

    params = [course_id]

    if start_date and end_date:
        query += " AND a.date BETWEEN %s AND %s"
        params.extend([start_date, end_date])
    elif start_date:
        query += " AND a.date >= %s"
        params.append(start_date)
    elif end_date:
        query += " AND a.date <= %s"
        params.append(end_date)

    query += " ORDER BY s.studentid, a.date;"

    cur.execute(query, tuple(params))
    rows = cur.fetchall()

    return pd.DataFrame(rows, columns=["studentid", "student_name", "date", "present"])
