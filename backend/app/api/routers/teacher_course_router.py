from fastapi import APIRouter, Body
from app.db.crud.teacher_course import *


router = APIRouter(
     prefix="/teacher_course",
     tags=["teacher_course"]
)

@router.post("/add", response_model=dict, summary="Insert a new Course")
def add(
    teacher_id : str = Body(..., embed=True,description="ID of the Teacher"),
    course_id: str = Body(..., embed=True, description="ID of the Course"),
    sem_id : str = Body(..., embed=True,description="ID of Sem which Course Belongs to"),
    dept_id : str  = Body(..., embed=True, description="ID of the Dept"),
    prog_id : str  = Body(..., embed=True, description="ID of Program"),
    fact_id : str = Body(..., embed = True , description = "ID of Faculty")
) -> dict:
    """
    Expects JSON payload: { "name": "Department of Engineering"}
    """
    return add_teacher_course_to_db(
      teacher_id=teacher_id,
      course_id=course_id,
      dept_id=dept_id,
      fact_id=fact_id,
      prog_id=prog_id,
      sem_id=sem_id,
    )
    
    
@router.post("/add_all_teacher_courses", response_model=dict, summary="Insert a new Course")
def add_all_teacher_courses(
    courses : list = Body(...,embed=True, description="Adding Courses in Teacher Course in bulk")
) -> dict:
    """
    Expects JSON payload: { "name": "Department of Engineering"}
    """
    return add_bulk_teacher_courses_to_db(courses=courses)

@router.post("/display", response_model=dict, summary="Display Course")
def display(teacher_id: str = Body(..., embed=True, description="Teacher ID")) -> dict:
    return display_teacher_course_by_teacher_id(teacher_id=teacher_id)


@router.get("/fetch_all",  response_model=list, summary="Display All Teacher Courses")
def get_all():
    return display_all()