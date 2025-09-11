from pydantic import BaseModel
from datetime import date

class SemesterCreate(BaseModel):
    __tablename__ = "semester"
    sem_id: str
    sem_name: str
    start_date: date
    end_date: date
    prog_id: str