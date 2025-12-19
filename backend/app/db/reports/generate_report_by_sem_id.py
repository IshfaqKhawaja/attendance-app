import pandas as pd # type: ignore
import psycopg  # type: ignore
import re
import os
from openpyxl.styles import Font, Alignment, PatternFill, Border, Side
from openpyxl.utils import get_column_letter
from openpyxl.cell.cell import MergedCell
from app.db.connection import connection_to_db # Assuming this is your connection module


def generate_semester_attendance_report_xls(sem_id: str, output_path: str):
    """
    Generates a comprehensive consolidated Excel attendance report for a semester.

    Creates a single-sheet report with:
    - Rows: Students
    - Columns: Student ID, Student Name, then each course showing "Present/Total (Percentage)"
    - Color-coded percentages for quick identification of low attendance

    This format is more readable for university administration compared to
    multiple sheets per course.

    Args:
        sem_id (str): The ID of the semester to generate the report for.
        output_path (str): The path to save the output .xlsx file.
    """
    print(f"🚀 Starting consolidated attendance report for semester: {sem_id}")

    # Query to get semester and program info
    info_sql = """
        SELECT
            sem.sem_name,
            p.prog_name
        FROM semester sem
        JOIN program p ON sem.prog_id = p.prog_id
        WHERE sem.sem_id = %(sem_id)s
        LIMIT 1;
    """

    # Query to get attendance summary per student per course
    # Only counts days where student has attendance record (P or A), excludes N/A
    sql = """
        SELECT
            s.student_id,
            s.student_name,
            c.course_id,
            c.course_name,
            COUNT(*) FILTER (WHERE a.present = true) AS present_count,
            COUNT(*) AS total_classes
        FROM students s
        JOIN student_enrollment se ON s.student_id = se.student_id
        JOIN course c ON c.sem_id = se.sem_id
        LEFT JOIN attendance a ON a.student_id = s.student_id AND a.course_id = c.course_id
        WHERE se.sem_id = %(sem_id)s
        GROUP BY s.student_id, s.student_name, c.course_id, c.course_name
        HAVING COUNT(*) > 0
        ORDER BY s.student_name, c.course_name;
    """

    try:
        with connection_to_db() as conn:
            print("✅ Database connection successful.")

            # Get semester and program info
            info_df = pd.read_sql_query(info_sql, conn, params={'sem_id': sem_id})
            sem_name = info_df['sem_name'].iloc[0] if not info_df.empty else sem_id
            prog_name = info_df['prog_name'].iloc[0] if not info_df.empty else "Unknown Program"

            df = pd.read_sql_query(sql, conn, params={'sem_id': sem_id})
            print(f"Found {len(df)} student-course attendance records.")

        if df.empty:
            print(f"⚠️ No attendance data found for semester '{sem_id}'.")
            # Create empty report with message
            empty_df = pd.DataFrame({'Message': ['No attendance data found for this semester']})
            empty_df.to_excel(output_path, index=False)
            return

        # Calculate percentage for each row
        df['percentage'] = df.apply(
            lambda row: round((row['present_count'] / row['total_classes'] * 100), 1)
            if row['total_classes'] > 0 else 0, axis=1
        )

        # Create formatted attendance string: "Present/Total (XX%)"
        df['attendance_str'] = df.apply(
            lambda row: f"{row['present_count']}/{row['total_classes']} ({row['percentage']}%)",
            axis=1
        )

        # Create column header with Course Name (Course ID)
        df['course_header'] = df.apply(
            lambda row: f"{row['course_name']} ({row['course_id']})",
            axis=1
        )

        # Pivot to get courses as columns
        pivot_df = df.pivot_table(
            index=['student_id', 'student_name'],
            columns='course_header',
            values='attendance_str',
            aggfunc='first',
            fill_value='-'
        )

        pivot_df.reset_index(inplace=True)

        # Rename columns for clarity
        pivot_df.rename(columns={
            'student_id': 'Student ID',
            'student_name': 'Student Name'
        }, inplace=True)

        # Also create a percentage pivot for color coding
        percent_pivot = df.pivot_table(
            index=['student_id', 'student_name'],
            columns='course_header',
            values='percentage',
            aggfunc='first',
            fill_value=0
        )
        percent_pivot.reset_index(inplace=True)

        # Reorder columns: Student ID, Student Name, then courses (alphabetically sorted)
        course_cols = [col for col in pivot_df.columns if col not in ['Student ID', 'Student Name']]
        ordered_cols = ['Student ID', 'Student Name'] + sorted(course_cols)
        pivot_df = pivot_df[ordered_cols]

        # Write to Excel with formatting
        with pd.ExcelWriter(output_path, engine='openpyxl') as writer:
            # Write main data
            pivot_df.to_excel(
                writer, sheet_name="Semester Attendance", index=False, startrow=3
            )

            worksheet = writer.sheets["Semester Attendance"]

            # Add title
            worksheet.merge_cells('A1:F1')
            title_cell = worksheet['A1']
            title_cell.value = "SEMESTER ATTENDANCE REPORT"
            title_cell.font = Font(bold=True, size=16)
            title_cell.alignment = Alignment(horizontal='center')

            # Add subtitle with semester and program info
            worksheet.merge_cells('A2:F2')
            subtitle_cell = worksheet['A2']
            subtitle_cell.value = f"Semester: {sem_name} | Program: {prog_name} | Format: Present/Total (Percentage)"
            subtitle_cell.font = Font(size=10, italic=True)
            subtitle_cell.alignment = Alignment(horizontal='center')

            # Style the header row
            header_fill = PatternFill(start_color="4472C4", end_color="4472C4", fill_type="solid")
            header_font = Font(bold=True, color="FFFFFF", size=10)
            thin_border = Border(
                left=Side(style='thin'),
                right=Side(style='thin'),
                top=Side(style='thin'),
                bottom=Side(style='thin')
            )

            for cell in worksheet[4]:  # Row 4 is the header
                cell.fill = header_fill
                cell.font = header_font
                cell.alignment = Alignment(horizontal='center', wrap_text=True)
                cell.border = thin_border

            # Define color fills
            green_fill = PatternFill(start_color="C6EFCE", end_color="C6EFCE", fill_type="solid")
            yellow_fill = PatternFill(start_color="FFEB9C", end_color="FFEB9C", fill_type="solid")
            orange_fill = PatternFill(start_color="FCD5B4", end_color="FCD5B4", fill_type="solid")
            red_fill = PatternFill(start_color="FFC7CE", end_color="FFC7CE", fill_type="solid")

            # Style data rows and apply conditional formatting
            for row_idx in range(5, worksheet.max_row + 1):
                for col_idx, cell in enumerate(worksheet[row_idx], 1):
                    cell.border = thin_border
                    cell.alignment = Alignment(horizontal='center')

                    # Color code cells containing percentages
                    if cell.value and isinstance(cell.value, str) and '%' in str(cell.value):
                        try:
                            # Extract percentage from string like "10/15 (66.7%)"
                            percent_str = str(cell.value).split('(')[1].replace('%)', '')
                            percent_val = float(percent_str)
                            if percent_val >= 90:
                                cell.fill = green_fill
                            elif percent_val >= 75:
                                cell.fill = yellow_fill
                            elif percent_val >= 60:
                                cell.fill = orange_fill
                            else:
                                cell.fill = red_fill
                        except (ValueError, IndexError):
                            pass

            # Auto-adjust column widths (skip merged cells)
            for col_idx in range(1, worksheet.max_column + 1):
                max_length = 0
                col_letter = get_column_letter(col_idx)
                for row_idx in range(4, worksheet.max_row + 1):  # Start from header row (4)
                    cell = worksheet.cell(row=row_idx, column=col_idx)
                    if not isinstance(cell, MergedCell) and cell.value:
                        try:
                            max_length = max(max_length, len(str(cell.value)))
                        except:
                            pass
                adjusted_width = min(max_length + 2, 20)
                worksheet.column_dimensions[col_letter].width = adjusted_width

            # Set specific column widths
            worksheet.column_dimensions['A'].width = 15  # Student ID
            worksheet.column_dimensions['B'].width = 25  # Student Name

            # Add legend at bottom
            last_row = worksheet.max_row + 2
            worksheet.cell(row=last_row, column=1, value="Legend:").font = Font(bold=True)
            worksheet.cell(row=last_row, column=2, value=">=90% (Excellent)").fill = green_fill
            worksheet.cell(row=last_row, column=3, value="75-89% (Good)").fill = yellow_fill
            worksheet.cell(row=last_row, column=4, value="60-74% (Warning)").fill = orange_fill
            worksheet.cell(row=last_row, column=5, value="<60% (Critical)").fill = red_fill

        print(f"\n🎉 Consolidated report saved to '{os.path.abspath(output_path)}'")

    except psycopg.Error as e:
        print(f"❌ Database Error: {e}")
        raise
    except Exception as e:
        print(f"❌ An unexpected error occurred: {e}")
        raise