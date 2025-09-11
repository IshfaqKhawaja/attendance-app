from fastapi import APIRouter, Body # type: ignore
from fastapi.encoders import jsonable_encoder
from app.db.crud.faculty import *
from app.db.models.faculty_model import (
    FacultyCreate,
    BulkFacultyCreate, BulkFacultyCreateResponse
)
router = APIRouter(
    prefix="/faculty",
    tags=["faculty"]
)

@router.post("/add", response_model=dict, summary="Insert a new faculty member")
def add(
    fac: FacultyCreate
) -> dict:
    """
    Expects JSON payload: { "name": "Dr. Ishfaq Khawaja" }
    """
    response = add_faculty_to_db(fac)
    return jsonable_encoder(response)


@router.post("/display", response_model=dict, summary="Display faculty")
def display(faculty_id: str = Body(..., embed=True, description="Display faculty")) -> dict:
    response = display_faculty_by_id(faculty_id)
    return jsonable_encoder(response)
    
@router.get("/fetch_all", response_model=list, summary = "Get all Faculty Data")
def get_all():
    return display_all()

@router.post("/bulk_add", response_model=BulkFacultyCreateResponse)
def bulk_add_faculty(payload: BulkFacultyCreate):
    return add_faculties_bulk(payload)