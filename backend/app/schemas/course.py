from pydantic import BaseModel

class CourseCreate(BaseModel):
    __tablename__ = "course"
    course_id: str
    course_name: str
    sem_id: str
