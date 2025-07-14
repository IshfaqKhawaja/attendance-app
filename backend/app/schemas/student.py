
from pydantic import BaseModel


class BulkStudentIn(BaseModel):
    student_id:   str
    student_name: str
    phone_number: int
    prog_id:      str
    sem_id:       str
    dept_id:      str