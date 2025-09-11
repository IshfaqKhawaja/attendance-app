# app/schemas/program.py
from pydantic import BaseModel # type: ignore
from typing import List, Optional

class ProgramCreate(BaseModel):
    prog_id: str
    prog_name: str
    dept_id: str

class ProgramCreateResponse(BaseModel):
    success: bool
    message: str

class ProgramDetailResponse(BaseModel):
    success: bool
    prog_id: Optional[str] = None
    prog_name: Optional[str] = None
    dept_id: Optional[str] = None

class ProgramListItem(BaseModel):
    prog_id: str
    prog_name: str
    dept_id: str

class BulkProgramCreate(BaseModel):
    programs: List[ProgramCreate]

class BulkProgramCreateResponse(BaseModel):
    success: bool
    inserted_count: int
    skipped_count: int
    message: Optional[str] = None
