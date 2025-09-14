


from pydantic import BaseModel

class StudentEnrolementModel(BaseModel):
    student_id: str
    sem_id: str
    
    
class BulkStudentEnrolementModel(BaseModel):
    enrolements : list[StudentEnrolementModel]
    


class StudentEnrolementResponseModel(BaseModel):
    success: bool
    message: str
    
class UploadResponseModel(BaseModel):
    filename: str
    size: int
    message: str

class StudentResponseModel(BaseModel):
    student_id: str
    student_name: str
    phone_number: str
    sem_id: str

class DisplayStudentsBySemIdResponseModel(BaseModel):
    success: bool
    students : list[StudentResponseModel]
