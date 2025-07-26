from fpdf import FPDF # type: ignore

def generate_pdf_report(data, course_id, start_date, end_date, filename="attendance_report.pdf"):
    pdf = FPDF()
    pdf.add_page()
    pdf.set_font("Arial", size=12)

    # Header
    pdf.cell(100, 10, txt=f"Attendance Report for Course: {course_id}", ln=True, align="C")  # type: ignore
    # Display date as dd/mm/yyyy
    pdf.cell(100, 10, txt=f"From: {start_date[:10]} to {end_date[:10]}", ln=True, align="C")  # type: ignore
    pdf.ln(10)

    # Table Headers
    pdf.set_font("Arial", "B", size=10)
    headers = ["Student ID", "Name", "Present", "Total", "Percentage"]
    col_widths = [40, 60, 20, 20, 30]
    for i, header in enumerate(headers):
        pdf.cell(col_widths[i], 10, txt=header, border=1) # type: ignore
    pdf.ln()

    # Table Data
    pdf.set_font("Arial", size=10)
    for student_id, name, present, total in data:
        percent = f"{(present / total * 100):.2f}%" if total else "0.00%"
        row = [student_id, name, str(present), str(total), percent]
        for i, cell in enumerate(row):
            pdf.cell(col_widths[i], 4, txt=cell, border=1) # type: ignore
        pdf.ln()
    pdf.output(filename)
    return filename
