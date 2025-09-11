from pydantic import BaseModel

class ProgramCreate(BaseModel):
    __tablename__ = "program"
    prog_id: str
    prog_name: str
    dept_id: str
