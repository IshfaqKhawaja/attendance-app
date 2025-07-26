from fastapi import APIRouter  # type: ignore
from app.db.crud.teacher import (
    add_teacher_to_db,
    display_teacher_by_id,
)
from app.models.teacher_model import (
    AddTeacherRequest,
    DisplayTeacherRequest,
)

router = APIRouter(
    prefix="/teacher",
    tags=["teacher"]
)



@router.post("/add", response_model=dict, summary="Insert a new Teacher")
def add_teacher(request: AddTeacherRequest) -> dict:
    """
    Add a new teacher to the database.
    """
    return add_teacher_to_db(
        teacher_id=request.teacher_id,
        name=request.teacher_name,
        type=request.type,
        dept_id=request.dept_id,
    )


@router.post("/display", response_model=dict, summary="Display Teacher")
def display_teacher(request: DisplayTeacherRequest) -> dict:
    """
    Fetch teacher details by ID.
    """
    return display_teacher_by_id(teacher_id=request.teacher_id)
