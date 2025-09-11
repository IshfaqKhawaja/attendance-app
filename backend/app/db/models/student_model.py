from pydantic import BaseModel


class StudentIn(BaseModel):
    student_id : str
    student_name : str
    phone_number : int
    dept_id : str
class BulkStudentIn(BaseModel):
    students: list[StudentIn]