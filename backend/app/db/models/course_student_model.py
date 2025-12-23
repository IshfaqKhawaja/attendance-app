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


class LocalStudentInput(BaseModel):
    """Input model for adding a local/backlog student directly to a course (without semester enrollment)"""
    student_id: str = Field(..., description="ID of the Student")
    student_name: str = Field(..., description="Name of the Student")
    phone_number: int = Field(..., description="Phone number of the Student")
    course_id: str = Field(..., description="ID of the Course to add the student to")

