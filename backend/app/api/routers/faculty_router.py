from fastapi import APIRouter, Body # type: ignore
from app.db.crud.faculty import *
from app.models.faculty_model import (
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
    return add_faculty_to_db(fac)


@router.post("/display", response_model=dict, summary="Display faculty")
def display(faculty_id: str = Body(..., embed=True, description="Display faculty")) -> dict:
    return display_faculty_by_id(faculty_id)
    
@router.get("/fetch_all", response_model=list, summary = "Get all Faculty Data")
def get_all():
    return display_all()

@router.post("/bulk_add", response_model=BulkFacultyCreateResponse)
def bulk_add_faculty(payload: BulkFacultyCreate):
    return add_faculties_bulk(payload)