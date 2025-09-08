from fastapi import APIRouter, Body # type: ignore
from fastapi.encoders import jsonable_encoder
from app.db.crud.department import *
from app.db.models.department_model import (
    DepartmentCreate,
    BulkDepartmentCreate,
    BulkDepartmentCreateResponse,
)


router = APIRouter(
     prefix="/department",
     tags=["department"]
)

@router.post("/add", response_model=dict, summary="Insert a new Department")
def add(
    dept: DepartmentCreate  
) -> dict:
    """
    Expects JSON payload: { "name": "Department of Engineering"}
    """
    response = add_department_to_db(dept=dept)
    return jsonable_encoder(response)


@router.post("/display", response_model=dict, summary="Display Department")
def display(dept_id: str = Body(..., embed=True, description="Department ID")) -> dict:
    response = display_department_by_id(dept_id)
    return jsonable_encoder(response)




@router.get("/fetch_all", response_model=list, summary = "Get all Faculty Data")
def get_all():
    return display_all_departments()


@router.post("/bulk_add", response_model=BulkDepartmentCreateResponse)
def bulk_add_departments(payload: BulkDepartmentCreate):
    return add_departments_bulk(payload)