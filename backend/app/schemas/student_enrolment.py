


from pydantic import BaseModel


class StudentEnrollmentCreate(BaseModel):
    __tablename__ = "student_enrollment"
    student_id: str
    sem_id: str