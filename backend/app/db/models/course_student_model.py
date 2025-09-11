from tracemalloc import start
from pydantic import BaseModel, Field # type: ignore
from typing import List


class CourseStudent(BaseModel):
    student_id: str = Field(..., description="ID of the Student")
    course_id: str = Field(..., description="ID of the Course")


class BulkCourseStudentInput(BaseModel):
    course_students: List[CourseStudent] = Field(..., description="List of course-student mappings")


class CourseIdInput(BaseModel):
    course_id: str = Field(..., description="Course ID")


class StudentsToCourseInput(BaseModel):
    students: List[dict] = Field(..., description="Student records")
    course_students: List[CourseStudent] = Field(..., description="Course-student mappings")


class ReportInput(BaseModel):
    course_id: str = Field(..., description="Course ID")
    start_date: str = Field(..., description="Start date for the report")
    end_date: str = Field(..., description="End date for the report")