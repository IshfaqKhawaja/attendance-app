


from pydantic import BaseModel

class CourseStudentCreate(BaseModel):
    __tablename__ = "course_student"
    course_id: str
    student_id: str