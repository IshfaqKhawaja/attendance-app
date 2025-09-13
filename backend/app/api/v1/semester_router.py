from datetime import date
from fastapi import APIRouter, Body #type: ignore
from fastapi.encoders import jsonable_encoder
from app.db.crud.semester import *
from app.db.models.semester_model import (
    SemesterCreate,
    SemesterListItem,
    BulkSemesterCreate,
    BulkSemesterCreateResponse,
    UpdateSemester,
)


router = APIRouter(
     prefix="/semester",
     tags=["semester"]
)

@router.post("/add", response_model=dict, summary="Insert a new Semester")
def add(
    semester : SemesterCreate
) -> dict:
    """
    Expects JSON payload: { "name": "Department of Engineering"}
    """
    response = add_semester_to_db(sem=semester)
    return jsonable_encoder(response)


@router.post("/display", response_model=dict, summary="Display Semester")
def display(sem_id: str = Body(..., embed=True, description="Semester ID")) -> dict:
    response = display_semester_by_id(sem_id)
    return jsonable_encoder(response)


@router.get("/fetch_all", response_model=list, summary = "Get all Faculty Data")
def get_all():
    return display_all_semesters()


@router.post("/bulk_add", response_model=BulkSemesterCreateResponse)
def bulk_add_semesters(payload: BulkSemesterCreate):
    return add_semesters_bulk(payload)



@router.get("/display_semester_by_program_id/{program_id}", response_model=dict, summary="List all Semesters by Program ID")
def get_semesters_by_program_id(program_id: str):
    return display_semesters_by_program_id(program_id)



@router.get("/delete/{sem_id}", response_model=SemesterCreateResponse, summary="Delete Semester by ID")
def delete_semester(sem_id: str):
    return delete_semester_by_id(sem_id)


@router.post("/edit/{sem_id}", response_model=SemesterCreateResponse, summary="Edit Semester by ID")
def edit_semester(sem_id: str, semester: UpdateSemester):
    return edit_semester_by_id(sem_id, semester)