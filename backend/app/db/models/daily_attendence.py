# app/schemas/attendance.py
from pydantic import BaseModel # type: ignore
from datetime import date
from typing import List

class DailyAttendance(BaseModel):
    student_id: str
    student_name: str
    phone_number: int
    present_count: int
    total_count: int
    percentage: float
