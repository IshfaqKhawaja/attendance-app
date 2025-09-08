
from pydantic import BaseModel


class BulkStudentIn(BaseModel):
    student_id:   str
    student_name: str
    phone_number: int
    prog_id:      str
    sem_id:       str
    dept_id:      str

class StudentCreate(BaseModel):
    studentid: str
    name: str
    phonenumber: int
    progid: str
    semid: str
    deptid: str

class StudentDetail(StudentCreate):
    pass