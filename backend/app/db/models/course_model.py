# app/schemas/course.py
from pydantic import BaseModel #type: ignore
from typing import List, Optional
from uuid import uuid4
class CourseCreate(BaseModel):
    course_name: str 
    course_id: str
    sem_id: str
    assigned_teacher_id: str
    def __init__(self, **data):
        if 'course_id' not in data:
            data['course_id'] = str(uuid4())
        super().__init__(**data)


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

class CourseUpdate(BaseModel):
    course_id: str
    course_name: Optional[str] = None
    assigned_teacher_id: Optional[str] = None