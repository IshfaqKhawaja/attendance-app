from datetime import date
from fastapi import APIRouter # type: ignore

from app.services.attendance_notifier import notify_attendance_for_date


router = APIRouter(
    prefix="/attendance_notifier",
    tags=["attendance_notifier"]
)

@router.get(
    "/notify",
    response_model=dict,
    summary="Notify Attendance"
)
def notify_attendance()-> dict:
    return notify_attendance_for_date(date.today())
