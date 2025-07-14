from fastapi import APIRouter, Body
from app.db.crud.teacher import (
    add_teacher_to_db,
    display_teacher_by_id,
)


router = APIRouter(
     prefix="/teacher",
     tags=["teacher"]
)

@router.post("/add", response_model=dict, summary="Insert a new Teacher")
def add(
    teacher_id : str = Body(..., embed=True,description="ID of the Teacher"),
    teacher_name: str = Body(..., embed=True, description="Name of the new Teacher"),
    type : str = Body(..., embed=True,description="Type of Teacher (GUEST, PERMENANT, CONTRACT)"),
    dept_id : str  = Body(..., embed=True, description="Dept id to which Teacher belongs"),
) -> dict:
    """
    Expects JSON payload: { "name": "Department of Engineering"}
    """
    return add_teacher_to_db(
       teacher_id=teacher_id,
       name=teacher_name,
       type=type,
       dept_id=dept_id,
    )


@router.post("/display", response_model=dict, summary="Display Teacher")
def display(teacher_id: str = Body(..., embed=True, description="Teacher ID")) -> dict:
    return display_teacher_by_id(teacher_id=teacher_id)
