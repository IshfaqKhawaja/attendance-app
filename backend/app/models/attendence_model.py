from datetime import datetime
from typing import Optional
from pydantic import BaseModel # type: ignore

class AttendenceModel(BaseModel):
    attendance_id:  str
    student_id:     str
    course_id:      str
    date:           datetime
    present:        bool
    prog_id:        str
    sem_id:         str
    dept_id:        str


class AttendenceIdModel(BaseModel):
    attendance_id: str
    
class BulkAttendenceModel(BaseModel):
    student_id:     str
    student_name:  Optional[str] = None
    course_id:      str
    date:           str
    marked:         list[bool]
    prog_id:        str
    sem_id:         str
    dept_id:        str
    
    
    class Config:
        extra = "ignore"
