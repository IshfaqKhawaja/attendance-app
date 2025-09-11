from fastapi import APIRouter  # type: ignore
from app.db.crud.teacher import (
    add_teacher_to_db,
    display_teacher_by_id,
)
from app.db.models.teacher_model import (
    TeacherCreate,
    DisplayTeacherRequest,
)

router = APIRouter(
    prefix="/teacher",
    tags=["teacher"]
)



@router.post("/add", response_model=dict, summary="Insert a new Teacher")
def add_teacher(teacher: TeacherCreate) -> dict:
    """
    Add a new teacher to the database.
    """
    return add_teacher_to_db(
        teacher=teacher
    )


@router.post("/display", response_model=dict, summary="Display Teacher")
def display_teacher(request: DisplayTeacherRequest) -> dict:
    """
    Fetch teacher details by ID.
    """
    return display_teacher_by_id(teacher_id=request.teacher_id)
