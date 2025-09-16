


from typing import List, Optional
from pydantic import BaseModel


class TeacherCourseIn(BaseModel):
    teacher_id: str
    course_id: str
    
class TeacherCourseDetail(BaseModel):
    """
    This is the Python (Pydantic) equivalent of your Dart TeacherCourseModel.
    """
    teacher_id: str
    course_id: str
    course_name: Optional[str]
    sem_id: str
    sem_name: Optional[str]
    prog_id: str
    prog_name: Optional[str]

class TeacherCourseResponse(BaseModel):
    """A response model to send the list of assignments."""
    success: bool
    teacher_courses: Optional[List[TeacherCourseDetail]] = None    
    

class BulkTeacherCourseIn(BaseModel):
    teacher_courses : list[TeacherCourseIn]