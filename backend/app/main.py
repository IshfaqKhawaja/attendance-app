# API Routers:
from app.api.routers.faculty_router import router as faculty_route
from app.api.routers.department_router import router as department_router
from app.api.routers.program_router import router as program_router
from app.api.routers.semester_router import router as semester_router
from app.api.routers.teacher_router import router as teacher_router
from app.api.routers.course_router import router as course_router
from app.api.routers.student_router import router as student_router
from app.api.routers.attendence_router import router as attendence_router
from app.api.routers.authenticate_router import router as authenticate_router
from app.api.routers.initial_router import router as initial_router
from app.api.routers.teacher_course_router import router as teacher_course_router
from app.api.routers.course_students_router import router as course_student_router
from app.api.routers.attendance_notifier_router import router as attendance_notifier_router
from app.api.routers.user_router import router as user_router
# from app.core.security import get_current_user

from fastapi import FastAPI # type: ignore
app = FastAPI(
    title="Attendence App Backend",
    version="0.0.1"
)

@app.get("/")
def home():
    return {"message" : "Welcome to JMI Attendence Server"}


# Initial Router:   p   r
app.include_router(initial_router)
# Authenticate Routes:
app.include_router(authenticate_router)
# Faculty Related Routes
app.include_router(faculty_route)
# Department Related Routes
app.include_router(department_router)
# Program Related Routes:
app.include_router(program_router)
# Semester Rourter:
app.include_router(semester_router)
# Teacher Router:
app.include_router(teacher_router)
# Course Router:
app.include_router(course_router)
# Teacher Course Router:
app.include_router(teacher_course_router)
# Course Student Router:
app.include_router(course_student_router)
# Student Router:
app.include_router(student_router)
# Attendence Router:
app.include_router(attendence_router)
# Attendance Notifier Router:
app.include_router(attendance_notifier_router)
# User Router:
app.include_router(user_router)