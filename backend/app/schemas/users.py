


from enum import Enum
from typing import Optional
from pydantic import BaseModel


class UserType(Enum):
    ADMIN = "ADMIN"
    TEACHER = "TEACHER"
    STUDENT = "STUDENT"

class UserCreate(BaseModel):
    __tablename__ = "users"
    user_id: str
    user_name: str
    type: UserType
    dept_id: Optional[str] = None
    fact_id : Optional[str] = None