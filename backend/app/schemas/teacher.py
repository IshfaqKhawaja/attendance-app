from pydantic import BaseModel
from enum import Enum

class TeacherType(str, Enum):
    PERMANENT = "PERMANENT"
    GUEST = "GUEST"
    CONTRACT = "CONTRACT"

class TeacherCreate(BaseModel):
    teacherid: str
    name: str
    type: TeacherType
    deptid: str

class TeacherDetail(TeacherCreate):
    pass
