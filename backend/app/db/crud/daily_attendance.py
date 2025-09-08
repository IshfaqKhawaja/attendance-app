# app/db/attendance_crud.py
from datetime import date
from typing import List
from app.db.connection import connection_to_db
from app.db.models.daily_attendence import DailyAttendance

def fetch_daily_attendance(att_date: date) -> List[DailyAttendance]:
    """
    Returns one record per student for the given date, with:
      - present_count: # of times present that day
      - total_count:   # of total attendance records that day
      - percentage:    (present_count / total_count)*100
    """
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute("""
            SELECT
              a.studentid,
              s.name,
              s.phonenumber,
              COUNT(*) FILTER (WHERE a.present)     AS present_count,
              COUNT(*)                              AS total_count
            FROM attendance a
            JOIN students s USING(studentid)
            WHERE a.date = %s
            GROUP BY a.studentid, s.name, s.phonenumber
        """, (att_date,))
        rows = cur.fetchall()

    results = []
    for sid, name, phone, pres, tot in rows:
        pct = (pres / tot * 100) if tot else 0.0
        results.append(DailyAttendance(
            studentid=sid,
            name=name,
            phonenumber=phone,
            present_count=pres,
            total_count=tot,
            percentage=round(pct, 2),
        ))
    return results
