from typing import Optional
from pydantic import BaseModel
from uuid import uuid4
class TeacherCreate(BaseModel):
    teacher_id: Optional[str] = None
    teacher_name: str
    type: str
    dept_id: str
    
    def __init__(self, **data):
        if 'teacher_id' not in data or data['teacher_id'] is None:
            data['teacher_id'] = str(uuid4())
        super().__init__(**data)


# Request model for displaying a teacher
class DisplayTeacherRequest(BaseModel):
    teacher_id: str
    
class ReturnTeacherDetails(BaseModel):
    success : bool
    teachers : list[TeacherCreate] = []
    
class TeacherID(BaseModel):
    teacher_id: str
    
class TeacherEditRequest(BaseModel):
    teacher_id: Optional[str] = None
    teacher_name: Optional[str] = None
    type: Optional[str] = None
    
class UpdateTeacherRequest(BaseModel):
    previous_teacher_id: str
    details : TeacherEditRequest
