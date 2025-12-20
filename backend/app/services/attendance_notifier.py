from datetime import date
from app.db.crud.daily_attendance import fetch_daily_attendance
from app.api.sms import send_sms


def notify_attendance_for_date(att_date: date) -> dict:
    """
    Fetches daily attendance and sends ONE consolidated SMS per student.

    SMS Format:
    Attendance (21-12-2024)
    John Doe (20208783)

    Data Structures (CS201): Present
    Operating Systems (CS301): Attended 2/3
    """
    students = fetch_daily_attendance(att_date)
    sent_count = 0
    failed_count = 0
    skipped_count = 0

    formatted_date = att_date.strftime("%d-%m-%Y")

    for student in students:
        # Skip if no phone number
        if not student.phone_number:
            skipped_count += 1
            print(f"Skipped {student.student_id}: No phone number")
            continue

        # Skip if no courses for the day
        if not student.courses:
            skipped_count += 1
            continue

        # Build consolidated message
        course_lines = []
        for course in student.courses:
            # Format: Course Name (CODE)
            course_header = f"{course.course_name} ({course.course_id})"

            if course.total_classes == 1:
                # Single class: just show Present/Absent
                status = "Present" if course.attended == 1 else "Absent"
                course_lines.append(f"{course_header}: {status}")
            else:
                # Multiple classes: show "Present X/Y"
                course_lines.append(f"{course_header}: Present {course.attended}/{course.total_classes}")

        message = (
            f"Attendance ({formatted_date})\n"
            f"{student.student_name} ({student.student_id})\n\n"
            + "\n".join(course_lines)
        )

        # Send SMS
        phone = str(student.phone_number)
        resp = send_sms(to=phone, body=message)

        if resp.get("success"):
            sent_count += 1
        else:
            failed_count += 1
            print(f"Failed to notify {student.student_id}: {resp.get('error')}")

    return {
        "message": f"Sent {sent_count} SMS, {failed_count} failed, {skipped_count} skipped",
        "sent": sent_count,
        "failed": failed_count,
        "skipped": skipped_count,
        "date": att_date.isoformat()
    }
