from datetime import date
from fastapi import APIRouter, Depends # type: ignore

from app.services.attendance_notifier import notify_attendance_for_date
from app.core.security import get_current_user


router = APIRouter(
    prefix="/attendance_notifier",
    tags=["attendance_notifier"]
)

@router.get(
    "/notify",
    response_model=dict,
    summary="Notify Attendance"
)
def notify_attendance(user=Depends(get_current_user))-> dict:
    return notify_attendance_for_date(date.today())
