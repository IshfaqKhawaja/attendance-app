# app/schemas/course.py
from pydantic import BaseModel #type: ignore
from typing import List, Optional

class CourseCreate(BaseModel):
    course_name: str 
    course_id: str
    sem_id: str


class CourseCreateResponse(BaseModel):
    success: bool
    message: str



class CourseDetailResponse(BaseModel):
    success: bool
    courses: List[CourseCreate] = []

class BulkCourseCreate(BaseModel):
    courses: List[CourseCreate]

class BulkCourseCreateResponse(BaseModel):
    success: bool
    inserted_count: int
    skipped_count: int
    message: Optional[str] = None
