#!/usr/bin/env python3
"""
Standalone script to send attendance SMS notifications to all students for today.

Usage:
    python send_attendance_sms.py           # Send SMS for today's attendance
    python send_attendance_sms.py --date 2025-01-15  # Send for specific date
    python send_attendance_sms.py --dry-run  # Preview without sending
"""
import argparse
from datetime import date, datetime
import sys
import os

# Add parent directory to path so we can import from app
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.db.crud.daily_attendance import fetch_daily_attendance
from app.api.sms import send_sms


def send_attendance_notifications(att_date: date, dry_run: bool = False) -> dict:
    """
    Fetches daily attendance and sends SMS to each student.

    Args:
        att_date: The date to fetch attendance for
        dry_run: If True, only preview messages without sending

    Returns:
        dict with summary of sent/failed messages
    """
    print(f"\n{'='*60}")
    print(f"Attendance SMS Notification - {att_date.isoformat()}")
    print(f"{'='*60}")

    if dry_run:
        print("[DRY RUN MODE - No SMS will be sent]\n")

    stats = fetch_daily_attendance(att_date)

    if not stats:
        print(f"No attendance records found for {att_date.isoformat()}")
        return {"success": False, "message": "No attendance records found", "sent": 0, "failed": 0}

    print(f"Found {len(stats)} students with attendance records\n")

    sent_count = 0
    failed_count = 0
    failed_students = []

    for rec in stats:
        # Format phone number to E.164
        to_number = rec.phone_number
        if to_number and not str(to_number).startswith("+"):
            to_number = "+91" + str(to_number)

        message = (
            f"Hello {rec.student_name}, your attendance on "
            f"{att_date.isoformat()} was "
            f"{rec.present_count}/{rec.total_count} "
            f"({rec.percentage:.1f}%)."
        )

        print(f"  [{rec.student_id}] {rec.student_name}")
        print(f"      Phone: {to_number}")
        print(f"      Attendance: {rec.present_count}/{rec.total_count} ({rec.percentage:.1f}%)")

        if dry_run:
            print(f"      Message: {message}")
            print(f"      Status: [SKIPPED - DRY RUN]\n")
            sent_count += 1
            continue

        if not to_number or to_number == "+91None":
            print(f"      Status: [FAILED - No phone number]\n")
            failed_count += 1
            failed_students.append(rec.student_id)
            continue

        resp = send_sms(to=str(to_number), body=message)

        if resp.get("success"):
            print(f"      Status: [SENT] SID: {resp.get('sid')}\n")
            sent_count += 1
        else:
            print(f"      Status: [FAILED] {resp.get('error')}\n")
            failed_count += 1
            failed_students.append(rec.student_id)

    print(f"{'='*60}")
    print(f"Summary:")
    print(f"  Total students: {len(stats)}")
    print(f"  SMS sent: {sent_count}")
    print(f"  SMS failed: {failed_count}")
    if failed_students:
        print(f"  Failed students: {', '.join(failed_students)}")
    print(f"{'='*60}\n")

    return {
        "success": True,
        "message": f"Sent {sent_count} SMS, {failed_count} failed",
        "sent": sent_count,
        "failed": failed_count,
        "total": len(stats)
    }


def main():
    parser = argparse.ArgumentParser(
        description="Send attendance SMS notifications to students"
    )
    parser.add_argument(
        "--date", "-d",
        type=str,
        default=None,
        help="Date to send notifications for (YYYY-MM-DD format). Defaults to today."
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Preview messages without actually sending SMS"
    )

    args = parser.parse_args()

    # Parse date
    if args.date:
        try:
            att_date = datetime.strptime(args.date, "%Y-%m-%d").date()
        except ValueError:
            print(f"Error: Invalid date format '{args.date}'. Use YYYY-MM-DD format.")
            sys.exit(1)
    else:
        att_date = date.today()

    # Send notifications
    result = send_attendance_notifications(att_date, dry_run=args.dry_run)

    if not result.get("success"):
        sys.exit(1)


if __name__ == "__main__":
    main()
