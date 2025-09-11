from fastapi import APIRouter

from app.db.crud.student_enrolement import add_student_enrolled_in_sem, add_students_enrolled_in_sem_bulk, display_student_by_sem_id
from app.db.models.student_enrolement_model import BulkStudentEnrolementModel, StudentEnrolementModel





router = APIRouter(
     prefix="/student_enrolement",
     tags=["student_enrolement"]
)

@router.post("/add", response_model=dict, summary="Enroll a student in a semester")
def add_student_enrolement(student: StudentEnrolementModel):
    """Add a student enrollment record."""
    return add_student_enrolled_in_sem(student)


@router.post("/add_bulk", response_model=dict, summary="Enroll multiple students in semesters")
def add_students_enrolement(students: BulkStudentEnrolementModel):
    """Add multiple student enrollment records."""
    return add_students_enrolled_in_sem_bulk(students)

@router.get("/display_by_sem_id/{sem_id}", response_model=dict, summary="Get students enrolled in a semester")
def display_students(sem_id: str):
    """Get students enrolled in a specific semester."""
    return display_student_by_sem_id(sem_id)