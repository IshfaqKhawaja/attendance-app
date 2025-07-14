# app/schemas/course.py
from pydantic import BaseModel #type: ignore
from typing import List, Optional

class CourseCreate(BaseModel):
    courseid: str
    name: str
    sem_id: str
    prog_id: str
    dept_id: str
    fact_id: str

class CourseCreateResponse(BaseModel):
    success: bool
    message: str

class CourseDetailResponse(BaseModel):
    success: bool
    course_id: Optional[str] = None
    course_name: Optional[str] = None
    sem_id: Optional[str] = None
    prog_id: Optional[str] = None
    dept_id: Optional[str] = None
    fact_id: Optional[str] = None

class CourseListItem(BaseModel):
    course_id: str
    course_name: str
    sem_id: str
    prog_id: str
    dept_id: str
    fact_id: str

class BulkCourseCreate(BaseModel):
    courses: List[CourseCreate]

class BulkCourseCreateResponse(BaseModel):
    success: bool
    inserted_count: int
    skipped_count: int
    message: Optional[str] = None
