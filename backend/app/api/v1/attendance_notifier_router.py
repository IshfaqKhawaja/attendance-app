from datetime import date, datetime
from typing import Optional
from fastapi import APIRouter, Query # type: ignore

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
def notify_attendance(
    att_date: Optional[str] = Query(None, description="Date in YYYY-MM-DD format. Defaults to today.")
) -> dict:
    """
    Send SMS notifications for attendance on a specific date.
    If no date is provided, uses today's date.
    """
    if att_date:
        try:
            target_date = datetime.strptime(att_date, "%Y-%m-%d").date()
        except ValueError:
            return {"error": "Invalid date format. Use YYYY-MM-DD", "success": False}
    else:
        target_date = date.today()

    return notify_attendance_for_date(target_date)
