from fpdf import FPDF # type: ignore
from datetime import datetime
from typing import Optional, Dict


def generate_pdf_report(data, course_id, start_date, end_date, filename="attendance_report.pdf", course_info: Optional[Dict[str, str]] = None):
    """
    Generate a comprehensive PDF attendance report for a single course.

    Args:
        data: List of tuples (student_id, student_name, present_count, total_classes)
        course_id: Course name/ID for the header (fallback if course_info not provided)
        start_date: Report start date
        end_date: Report end date
        filename: Output filename
        course_info: Dict with course_id, course_name, sem_name, prog_name
    """
    pdf = FPDF(orientation='P', unit='mm', format='A4')
    pdf.add_page()

    # Page width for centering calculations
    page_width = 210  # A4 width in mm
    margin = 10
    usable_width = page_width - (2 * margin)

    # ===== HEADER SECTION =====
    pdf.set_font("Arial", "B", size=16)
    pdf.cell(0, 10, txt="ATTENDANCE REPORT", ln=True, align="C")

    # Use course_info if available, otherwise fallback
    if course_info:
        course_name = course_info.get('course_name', course_id)
        course_id_str = course_info.get('course_id', '')
        sem_name = course_info.get('sem_name', '')
        prog_name = course_info.get('prog_name', '')

        pdf.set_font("Arial", "B", size=12)
        pdf.cell(0, 8, txt=f"Course: {course_name} ({course_id_str})", ln=True, align="C")

        pdf.set_font("Arial", size=10)
        pdf.cell(0, 6, txt=f"Semester: {sem_name} | Program: {prog_name}", ln=True, align="C")
    else:
        pdf.set_font("Arial", "B", size=12)
        pdf.cell(0, 8, txt=f"Course: {course_id}", ln=True, align="C")

    # Format dates nicely
    try:
        start_formatted = datetime.strptime(start_date[:10], "%Y-%m-%d").strftime("%d/%m/%Y")
        end_formatted = datetime.strptime(end_date[:10], "%Y-%m-%d").strftime("%d/%m/%Y")
    except:
        start_formatted = start_date[:10]
        end_formatted = end_date[:10]

    pdf.set_font("Arial", size=10)
    pdf.cell(0, 6, txt=f"Period: {start_formatted} to {end_formatted}", ln=True, align="C")
    pdf.cell(0, 6, txt=f"Generated on: {datetime.now().strftime('%d/%m/%Y %H:%M')}", ln=True, align="C")

    pdf.ln(5)

    # ===== SUMMARY SECTION =====
    if data:
        total_students = len(data)
        total_classes = data[0][3] if data else 0
        avg_attendance = sum(row[2] for row in data) / (total_students * total_classes) * 100 if total_classes > 0 else 0

        # Count students by attendance percentage
        excellent = sum(1 for row in data if row[3] > 0 and (row[2] / row[3] * 100) >= 90)
        good = sum(1 for row in data if row[3] > 0 and 75 <= (row[2] / row[3] * 100) < 90)
        warning = sum(1 for row in data if row[3] > 0 and 60 <= (row[2] / row[3] * 100) < 75)
        critical = sum(1 for row in data if row[3] > 0 and (row[2] / row[3] * 100) < 60)

        # Summary box
        pdf.set_fill_color(240, 240, 240)
        pdf.set_font("Arial", "B", size=10)
        pdf.cell(0, 7, txt="SUMMARY", ln=True, align="L", fill=True)

        pdf.set_font("Arial", size=9)
        col_width = usable_width / 4

        pdf.cell(col_width, 6, txt=f"Total Students: {total_students}", border=0)
        pdf.cell(col_width, 6, txt=f"Total Classes: {total_classes}", border=0)
        pdf.cell(col_width, 6, txt=f"Avg Attendance: {avg_attendance:.1f}%", border=0)
        pdf.cell(col_width, 6, txt="", border=0, ln=True)

        # Attendance distribution
        pdf.cell(col_width, 5, txt=f">=90% (Excellent): {excellent}", border=0)
        pdf.cell(col_width, 5, txt=f"75-89% (Good): {good}", border=0)
        pdf.cell(col_width, 5, txt=f"60-74% (Warning): {warning}", border=0)
        pdf.cell(col_width, 5, txt=f"<60% (Critical): {critical}", border=0, ln=True)

        pdf.ln(5)

    # ===== TABLE SECTION =====
    pdf.set_font("Arial", "B", size=10)
    pdf.set_fill_color(200, 200, 200)

    # Column widths
    col_widths = [15, 35, 70, 20, 20, 30]  # S.No, ID, Name, Present, Total, %
    headers = ["S.No", "Student ID", "Student Name", "Present", "Total", "Percentage"]

    for i, header in enumerate(headers):
        pdf.cell(col_widths[i], 8, txt=header, border=1, align="C", fill=True)
    pdf.ln()

    # Table Data
    pdf.set_font("Arial", size=9)
    for idx, (student_id, name, present, total) in enumerate(data, 1):
        percent_val = (present / total * 100) if total else 0
        percent = f"{percent_val:.1f}%"

        # Color coding for attendance percentage
        if percent_val >= 90:
            pdf.set_fill_color(200, 255, 200)  # Green
        elif percent_val >= 75:
            pdf.set_fill_color(255, 255, 200)  # Yellow
        elif percent_val >= 60:
            pdf.set_fill_color(255, 230, 200)  # Orange
        else:
            pdf.set_fill_color(255, 200, 200)  # Red

        # Truncate long names
        display_name = name[:35] + "..." if len(name) > 35 else name
        display_id = student_id[:18] + "..." if len(student_id) > 18 else student_id

        row = [str(idx), display_id, display_name, str(present), str(total), percent]
        for i, cell in enumerate(row):
            align = "C" if i in [0, 3, 4, 5] else "L"
            fill = (i == 5)  # Only fill percentage column
            pdf.cell(col_widths[i], 6, txt=cell, border=1, align=align, fill=fill)
        pdf.ln()

        # Add new page if needed
        if pdf.get_y() > 270:
            pdf.add_page()
            # Repeat headers on new page
            pdf.set_font("Arial", "B", size=10)
            pdf.set_fill_color(200, 200, 200)
            for i, header in enumerate(headers):
                pdf.cell(col_widths[i], 8, txt=header, border=1, align="C", fill=True)
            pdf.ln()
            pdf.set_font("Arial", size=9)

    # ===== FOOTER =====
    pdf.ln(5)
    pdf.set_font("Arial", "I", size=8)
    pdf.cell(0, 5, txt="Note: Attendance percentage below 75% may affect eligibility for examinations.", ln=True, align="L")

    pdf.output(filename)
    return filename
