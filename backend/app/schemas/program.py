from pydantic import BaseModel

class ProgramCreate(BaseModel):
    progid: str
    name: str
    deptid: str
    factid: str

class ProgramDetail(ProgramCreate):
    pass
