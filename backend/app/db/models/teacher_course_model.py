


from pydantic import BaseModel


class TeacherCourseIn(BaseModel):
    teacher_id: str
    course_id: str
    
class BulkTeacherCourseIn(BaseModel):
    teacher_courses : list[TeacherCourseIn]