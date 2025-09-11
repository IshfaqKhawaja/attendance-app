from pydantic import BaseModel
from enum import Enum

class TeacherType(str, Enum):
    PERMANENT = "PERMANENT"
    GUEST = "GUEST"
    CONTRACT = "CONTRACT"

class TeacherCreate(BaseModel):
    __tablename__ = "teachers"
    teacher_id: str
    teacher_name: str
    type: TeacherType
    dept_id: str