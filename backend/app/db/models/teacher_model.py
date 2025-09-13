from pydantic import BaseModel

class TeacherCreate(BaseModel):
    teacher_id: str
    teacher_name: str
    type: str
    dept_id: str


# Request model for displaying a teacher
class DisplayTeacherRequest(BaseModel):
    teacher_id: str