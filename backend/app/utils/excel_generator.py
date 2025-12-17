import pandas as pd
from typing import Optional

def generate_attendance_excel(df: pd.DataFrame, output_path: str = "attendance_report.xlsx") -> Optional[str]:
    """
    Generates a pivoted attendance report supporting multiple daily sessions.

    Args:
        df (pd.DataFrame): Attendance data with columns:
                           student_id, student_name, date, lecture_num, status ('P' or 'A').
        output_path (str): File path to save the Excel report.
    """
    if df.empty:
        print("⚠️ No data available to generate report.")
        return None

    # CHANGED: The pivot now uses both 'date' and 'lecture_num' for columns.
    # This ensures each attendance session gets its own unique column.
    pivot_df = df.pivot_table(
        index=["student_id", "student_name"],
        columns=['date', 'lecture_num'],
        values='status',
        aggfunc='first',
        fill_value='N/A'  # Use 'N/A' for days/lectures where no attendance was taken.
    )

    # CHANGED: Format the new multi-level columns into a single, readable header.
    # The columns are now tuples like (Timestamp('2025-09-20'), 1).
    # We format them into strings like "2025-09-20 (Lec 1)".
    if isinstance(pivot_df.columns, pd.MultiIndex):
        pivot_df.columns = [
            f"{date.strftime('%Y-%m-%d')} (Lec {lec_num})"
            for date, lec_num in pivot_df.columns
        ]

    # This moves student_id and student_name from the index to columns.
    pivot_df.reset_index(inplace=True)

    # Calculate total classes held (maximum attendance records for any student)
    # This ensures all students show the same total, even if some joined late
    total_classes = df.groupby('student_id').size().max()

    # Get attendance columns (all columns except student_id and student_name)
    attendance_cols = [col for col in pivot_df.columns if col not in ['student_id', 'student_name']]

    # Calculate Present count for each student (count of 'P' values)
    pivot_df['Present'] = pivot_df[attendance_cols].apply(
        lambda row: (row == 'P').sum(), axis=1
    )

    # Total classes is the same for all students
    pivot_df['Total'] = total_classes

    # Calculate percentage
    pivot_df['Percentage'] = pivot_df.apply(
        lambda row: f"{(row['Present'] / row['Total'] * 100):.2f}%" if row['Total'] > 0 else "0.00%",
        axis=1
    )

    with pd.ExcelWriter(output_path, engine="openpyxl") as writer:
        pivot_df.to_excel(writer, sheet_name="Attendance Report", index=False)

        # Optional: Auto-adjust column widths for better readability
        worksheet = writer.sheets["Attendance Report"]
        for column in worksheet.columns:
            max_length = 0
            column_letter = column[0].column_letter
            for cell in column:
                try:
                    if len(str(cell.value)) > max_length:
                        max_length = len(str(cell.value))
                except:
                    pass
            adjusted_width = (max_length + 2)
            worksheet.column_dimensions[column_letter].width = adjusted_width


    print(f"✅ Excel report successfully generated at '{output_path}'")
    return output_path