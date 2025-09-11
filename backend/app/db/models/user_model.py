




from typing import Optional
from pydantic import BaseModel
from sqlalchemy import Enum

class TeacherType(str, Enum):
    HOD = "HOD"
    ADMIN = "ADMIN"
    SUPERADMIN = "SUPERADMIN"
    
    
class UserIn(BaseModel):
    user_id: str
    user_name: str
    type: TeacherType
    dept_id: Optional[str] = None
    fact_id: Optional[str] = None
    class Config:
        orm_mode = True
        
class DisplayUser(BaseModel):
    user_id: str
    user_name: str
    type: TeacherType
    dept_id: Optional[str] = None
    fact_id: Optional[str] = None
    class Config:
        orm_mode = True