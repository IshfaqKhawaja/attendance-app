
from pydantic import BaseModel



class StudentCreate(BaseModel):
    __tablename__ = "students"
    student_id: str
    student_name: str
    phone_number: int
    dept_id: str