from datetime import datetime
from pydantic import BaseModel, Field

from app.db.crud import course # type: ignore

class AttendenceModel(BaseModel):
    student_id:     str
    course_id:      str
    date:           datetime
    present:        bool

    class Config:
        extra = "ignore"


class AttendenceIdModel(BaseModel):
    attendance_id: str
    
class BulkAttendenceModel(BaseModel):
    attendances : list[AttendenceModel]
    
    
    class Config:
        extra = "ignore"
        
        
class BulkAttendenceResponseModel(BaseModel):
    success: bool
    message: str



class ReportInput(BaseModel):
    course_id: str = Field(..., description="Course ID")
    course_name: str = Field(..., description="Course Name")
    start_date: str = Field(..., description="Start date for the report")
    end_date: str = Field(..., description="End date for the report")