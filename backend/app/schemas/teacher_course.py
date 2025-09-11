



from pydantic import BaseModel


class TeacherCourseCreate(BaseModel):
    __tablename__ = "teacher_course"
    teacher_id: str
    course_id: str
    sem_id: str