import pandas as pd
from typing import Optional
def generate_attendance_excel(df: pd.DataFrame, output_path: str = "attendance_report.xlsx") -> Optional[str]:
    """
    Generates a pivoted attendance report and writes it to Excel.

    Args:
        df (pd.DataFrame): Attendance data with columns: studentid, student_name, date, present.
        output_path (str): File path to save the Excel report.
    """
    if df.empty:
        print("⚠️ No data available to generate report.")
        return 

    df["present_mark"] = df["present"].apply(lambda x: "✔️" if x else "❌")

    pivot_df = df.pivot_table(
        index=["studentid", "student_name"],
        columns="date",
        values="present_mark",
        aggfunc="first",
        fill_value="❌"
    )

    # Format date columns as strings
    pivot_df.columns = [col.strftime("%Y-%m-%d") for col in pivot_df.columns] # type: ignore
    pivot_df.reset_index(inplace=True)

    with pd.ExcelWriter(output_path, engine="openpyxl") as writer:
        pivot_df.to_excel(writer, sheet_name="Attendance Report", index=False)

    return output_path
