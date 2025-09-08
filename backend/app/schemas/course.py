from pydantic import BaseModel

class CourseCreate(BaseModel):
    courseid: str
    name: str
    semid: str
    progid: str
    deptid: str
    factid: str

class CourseDetail(CourseCreate):
    pass
