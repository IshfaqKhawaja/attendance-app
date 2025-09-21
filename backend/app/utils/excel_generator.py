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

    # REMOVED: The 'present_mark' conversion is no longer needed
    # as the status is already 'P' or 'A'.

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