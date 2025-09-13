# app/schemas/semester.py
import uuid
from pydantic import BaseModel #type: ignore
from datetime import date
from typing import List, Optional
from uuid import  uuid4

class SemesterCreate(BaseModel):
    sem_id: Optional[str] = None 
    sem_name: str
    start_date: date
    end_date: date
    prog_id: str
    # Create UUID for sem_id when creating a new semester
    def __init__(self, **data):
        super().__init__(**data)
        id = uuid4()
        if not self.sem_id:
            self.sem_id = str(id)

class SemesterCreateResponse(BaseModel):
    success: bool
    message: str

class SemesterDetailResponse(BaseModel):
    success: bool
    sem_id: Optional[str] = None
    sem_name: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    prog_id: Optional[str] = None
    message: Optional[str] = None
class SemesterListItem(BaseModel):
    sem_id: str
    sem_name: str
    start_date: date
    end_date: date
    prog_id: str

class BulkSemesterCreate(BaseModel):
    semesters: List[SemesterCreate]

class BulkSemesterCreateResponse(BaseModel):
    success: bool
    inserted_count: int
    skipped_count: int
    message: Optional[str] = None
 