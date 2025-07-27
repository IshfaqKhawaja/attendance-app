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


class CourseListItem(BaseModel):
    course_id: str
    course_name: str
    sem_id: str
    prog_id: str
    dept_id: str
    fact_id: str
    

class CourseDetailResponse(BaseModel):
    success: bool
    courses: List[CourseListItem] = []

class BulkCourseCreate(BaseModel):
    courses: List[CourseCreate]

class BulkCourseCreateResponse(BaseModel):
    success: bool
    inserted_count: int
    skipped_count: int
    message: Optional[str] = None
