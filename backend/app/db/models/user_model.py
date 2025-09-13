




from typing import Optional
from pydantic import BaseModel
from sqlalchemy import Enum


    
class UserIn(BaseModel):
    user_id: str
    user_name: str
    type: str
    dept_id: Optional[str] = None
    fact_id: Optional[str] = None
        
class DisplayUser(BaseModel):
    user_id: str
    user_name: str
    type: str
    dept_id: Optional[str] = None
    fact_id: Optional[str] = None