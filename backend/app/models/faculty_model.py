from pydantic import BaseModel # type: ignore
from typing import List, Optional

class FacultyCreate(BaseModel):
    factid: str
    name: str

class FacultyCreateResponse(BaseModel):
    success: bool
    message: str

class FacultyDetailResponse(BaseModel):
    success: bool
    factid: Optional[str] = None
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
