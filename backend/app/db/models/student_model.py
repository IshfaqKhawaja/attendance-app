from pydantic import BaseModel
from typing import Optional


class StudentIn(BaseModel):
    student_id : str
    student_name : str
    phone_number : int
    sem_id : str

class StudentUpdate(BaseModel):
    student_id: str
    student_name: Optional[str] = None
    phone_number: Optional[int] = None

class BulkStudentIn(BaseModel):
    students: list[StudentIn]