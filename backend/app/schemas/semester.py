from pydantic import BaseModel
from datetime import date

class SemesterCreate(BaseModel):
    semid: str
    name: str
    startdate: date
    enddate: date
    progid: str

class SemesterDetail(SemesterCreate):
    pass
