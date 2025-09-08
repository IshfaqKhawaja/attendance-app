from pydantic import BaseModel, Field # type: ignore

class AddTeacherRequest(BaseModel):
    teacher_id: str = Field(..., description="ID of the Teacher")
    teacher_name: str = Field(..., description="Name of the new Teacher")
    type: str = Field(..., description="Type of Teacher (GUEST, PERMANENT, CONTRACT)")
    dept_id: str = Field(..., description="Dept id to which Teacher belongs")


# Request model for displaying a teacher
class DisplayTeacherRequest(BaseModel):
    teacher_id: str = Field(..., description="Teacher ID")
