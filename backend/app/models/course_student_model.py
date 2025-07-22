from tracemalloc import start
from pydantic import BaseModel, Field # type: ignore
from typing import List


class CourseStudentInput(BaseModel):
    student_id: str = Field(..., description="ID of the Student")
    course_id: str = Field(..., description="ID of the Course")
    sem_id: str = Field(..., description="ID of Sem which Course Belongs to")
    dept_id: str = Field(..., description="ID of the Dept")
    prog_id: str = Field(..., description="ID of Program")


class BulkCourseStudentInput(BaseModel):
    course_students: List[dict] = Field(..., description="List of course-student mapping dicts")


class StudentCourseQuery(BaseModel):
    student_id: str = Field(..., description="Student ID")
    course_id: str = Field(..., description="Course ID")


class CourseIdInput(BaseModel):
    course_id: str = Field(..., description="Course ID")


class StudentsToCourseInput(BaseModel):
    students: List[dict] = Field(..., description="Student records")
    course_students: List[dict] = Field(..., description="Course-student mappings")
    
    
    
class ReportInput(BaseModel):
    course_id: str = Field(..., description="Course ID")
    start_date: str = Field(..., description="Start date for the report")
    end_date: str = Field(..., description="End date for the report")