from pydantic import BaseModel

class DepartmentCreate(BaseModel):
    deptid: str
    name: str
    factid: str

class DepartmentDetail(DepartmentCreate):
    pass
