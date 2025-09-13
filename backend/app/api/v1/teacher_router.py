from ast import Return
from fastapi import APIRouter  # type: ignore
from app.db.crud.teacher import (
    add_teacher_to_db,
    delete_teacher_by_teacher_id,
    display_teacher_by_dept_id,
    display_teacher_by_id,
    edit_teacher_by_id,
)
from app.db.models.teacher_model import (
    ReturnTeacherDetails,
    TeacherCreate,
    DisplayTeacherRequest,
    TeacherID,
    UpdateTeacherRequest,
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
def display_teacher(request: DisplayTeacherRequest) -> ReturnTeacherDetails:
    """
    Fetch teacher details by ID.
    """
    return display_teacher_by_id(teacher_id=request.teacher_id)


@router.get("/display/{dept_id}", response_model=ReturnTeacherDetails, summary="Fetch All Teachers")
def display_teachers_by_dept(dept_id: str) -> ReturnTeacherDetails:
    """
    Fetch all teachers by department ID.
    """
    return display_teacher_by_dept_id(dept_id=dept_id)



@router.post("/delete", response_model=dict, summary="Delete Teacher by ID")
def delete_teacher(teacher_id: TeacherID) -> dict:
    """
    Delete a teacher from the database.
    """
    return delete_teacher_by_teacher_id(teacher_id=teacher_id.teacher_id)

@router.post("/edit", response_model=dict, summary="Edit Teacher by ID")
def edit_teacher(teacher: UpdateTeacherRequest) -> dict:
    """
    Edit a teacher's details in the database.
    """
    return edit_teacher_by_id(teacher.previous_teacher_id, teacher)