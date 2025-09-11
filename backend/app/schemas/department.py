from pydantic import BaseModel

class DepartmentCreate(BaseModel):
    __tablename__ = "department"
    dept_id: str
    dept_name: str
    fact_id: str
