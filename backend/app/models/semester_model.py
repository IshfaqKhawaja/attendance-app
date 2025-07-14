# app/schemas/semester.py
from pydantic import BaseModel #type: ignore
from datetime import date
from typing import List, Optional

class SemesterCreate(BaseModel):
    semid: str
    name: str
    start_date: date
    end_date: date
    prog_id: str

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
 