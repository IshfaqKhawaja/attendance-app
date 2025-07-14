from datetime import date
from fastapi import APIRouter, Body #type: ignore
from app.db.crud.semester import *
from app.models.semester_model import (
    SemesterCreate,
    SemesterCreateResponse,
    SemesterDetailResponse,
    SemesterListItem,
    BulkSemesterCreate,
    BulkSemesterCreateResponse,
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
    return add_semester_to_db(
       sem=semester
    )


@router.post("/display", response_model=dict, summary="Display Semester")
def display(sem_id: str = Body(..., embed=True, description="Semester ID")) -> dict:
    return display_semester_by_id(sem_id)


@router.get("/fetch_all", response_model=list, summary = "Get all Faculty Data")
def get_all():
    return display_all_semesters()


@router.post("/bulk_add", response_model=BulkSemesterCreateResponse)
def bulk_add_semesters(payload: BulkSemesterCreate):
    return add_semesters_bulk(payload)