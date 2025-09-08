from pydantic import BaseModel
from datetime import date

class AttendanceCreate(BaseModel):
    attendanceid: str
    studentid: str
    courseid: str
    date: date
    present: bool = False
    semid: str
    deptid: str
    progid: str

class AttendanceDetail(AttendanceCreate):
    pass
