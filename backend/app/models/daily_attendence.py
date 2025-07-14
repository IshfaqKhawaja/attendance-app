# app/schemas/attendance.py
from pydantic import BaseModel # type: ignore
from datetime import date
from typing import List

class DailyAttendance(BaseModel):
    studentid: str
    name: str
    phonenumber: int
    present_count: int
    total_count: int
    percentage: float
