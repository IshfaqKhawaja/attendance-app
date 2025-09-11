from datetime import datetime
from typing import Optional
from pydantic import BaseModel # type: ignore

class AttendenceModel(BaseModel):
    student_id:     str
    course_id:      str
    date:           datetime
    present:        bool


class AttendenceIdModel(BaseModel):
    attendance_id: str
    
class BulkAttendenceModel(BaseModel):
    student_id:     str
    course_id:      str
    date:           datetime
    marked:         list[bool]
    
    
    class Config:
        extra = "ignore"
