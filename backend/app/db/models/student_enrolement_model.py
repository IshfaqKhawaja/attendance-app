


from pydantic import BaseModel

from app.db.crud import student

class StudentEnrolementModel(BaseModel):
    student_id: str
    sem_id: str
    
class StudentCourseEnrolementModel(BaseModel):
    student_id: str
    course_id: str
    student_name: str
    phone_number: str
class StudentEnrollmentDetailsModel(BaseModel):
    success : bool
    students: list[StudentCourseEnrolementModel]



    
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


class DeleteStudentEnrollment(BaseModel):
    student_id: str
    sem_id: str
    
class DeleteStudentEnrollmentResponseModel(BaseModel):
    success: bool
    message: str