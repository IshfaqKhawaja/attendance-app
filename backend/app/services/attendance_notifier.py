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
    sent_count = 0
    failed_count = 0

    for rec in stats:
        # ensure E.164 format; adjust country code as needed
        to_number = rec.phone_number
        if not f"{to_number}".startswith("+"):
            to_number = "+91" + str(to_number)

        message = (
            f"Hello {rec.student_name}, your attendance on "
            f"{att_date.isoformat()} was "
            f"{rec.present_count}/{rec.total_count} "
            f"({rec.percentage:.1f}%)."
        )
        resp = send_sms(to=f"{to_number}", body=message)
        if resp.get("success"):
            sent_count += 1
        else:
            failed_count += 1
            print(f"Failed to notify {rec.student_id}: {resp.get('error')}")

    return {"message": f"Sent {sent_count} SMS, {failed_count} failed", "sent": sent_count, "failed": failed_count}