


from pydantic import BaseModel


class StudentEnrolementModel(BaseModel):
    student_id: str
    sem_id: str
    
    
class BulkStudentEnrolementModel(BaseModel):
    enrolements : list[StudentEnrolementModel]
    
    