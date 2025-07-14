# app/schemas/department.py
from pydantic import BaseModel # type: ignore
from typing import List, Optional

class DepartmentCreate(BaseModel):
    deptid: str
    name: str
    fact_id: str

class DepartmentCreateResponse(BaseModel):
    success: bool
    message: str

class DepartmentDetailResponse(BaseModel):
    success: bool
    dept_id: Optional[str] = None
    dept_name: Optional[str] = None
    fact_id: Optional[str] = None

class DepartmentListItem(BaseModel):
    dept_id: str
    dept_name: str
    fact_id: str

class BulkDepartmentCreate(BaseModel):
    departments: List[DepartmentCreate]

class BulkDepartmentCreateResponse(BaseModel):
    success: bool
    inserted_count: int
    skipped_count: int
    message: Optional[str] = None
