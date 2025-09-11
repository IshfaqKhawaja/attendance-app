from pydantic import BaseModel
from typing import Optional, List

class FacultyCreate(BaseModel):
    fact_id: str
    fact_name: str

class FacultyDetail(FacultyCreate):
    pass


class FacultyCreateResponse(BaseModel):
    success: bool
    message: str

class FacultyDetailResponse(BaseModel):
    success: bool
    fact_id: Optional[str] = None
    fact_name: Optional[str] = None

class FacultyListItem(BaseModel):
    fact_id: str
    fact_name: str

class BulkFacultyCreate(BaseModel):
    faculties: List[FacultyCreate]

class BulkFacultyCreateResponse(BaseModel):
    success: bool
    inserted_count: int
    skipped_count: int
    message: Optional[str] = None
