# app/utils/attendance_notifier.py
from datetime import date
from app.db.crud.daily_attendance import fetch_daily_attendance
from app.api.sms import send_sms

def notify_attendance_for_date(att_date: date) -> dict:
    """
    Fetches daily attendance then sends each student an SMS:
      "Hello {name}, your attendance on {YYYY-MM-DD} was
       {present_count}/{total_count} ({percentage}%)."
    """
    stats = fetch_daily_attendance(att_date)
    for rec in stats:
        # ensure E.164 format; adjust country code as needed
        to_number = rec.phonenumber
        if not f"{to_number}".startswith("+"):
            to_number = "+91" + str(to_number)

        message = (
            f"Hello {rec.name}, your attendance on "
            f"{att_date.isoformat()} was "
            f"{rec.present_count}/{rec.total_count} "
            f"({rec.percentage:.2f}%)."
        )
        resp = send_sms(to=f"{to_number}", body=message)
        if not resp.get("success"):
            # you could log or raise here
            print(f"Failed to notify {rec.studentid}: {resp.get('error')}")
    return {"message" : "Sent All SMSs"}