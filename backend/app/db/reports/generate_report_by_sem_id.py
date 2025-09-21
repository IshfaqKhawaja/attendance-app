import pandas as pd
import psycopg
import re
import os
from app.db.connection import connection_to_db # Assuming this is your connection module

def generate_semester_attendance_report_xls(sem_id: str, output_path: str):
    """
    Generates a multi-sheet Excel attendance report for a given semester, 
    handling multiple daily sessions.

    Args:
        sem_id (str): The ID of the semester to generate the report for.
        output_path (str): The path to save the output .xlsx file.
    """
    print(f"🚀 Starting attendance report generation for semester: {sem_id}")

    # CHANGED: SQL query now uses a window function to generate a unique 'lecture_num' 
    # for each session on the same day and converts 'present' to 'P' or 'A'.
    sql = """
        WITH NumberedAttendance AS (
            SELECT
                course_id,
                student_id,
                date,
                present,
                ROW_NUMBER() OVER(PARTITION BY student_id, course_id, date ORDER BY ctid) as lecture_num
            FROM attendance
        )
        SELECT
            c.course_id,
            c.course_name,
            s.student_id,
            s.student_name,
            na.date,
            na.lecture_num,
            CASE WHEN na.present THEN 'P' ELSE 'A' END AS status
        FROM NumberedAttendance na
        JOIN students s ON na.student_id = s.student_id
        JOIN course c ON na.course_id = c.course_id
        WHERE
            c.sem_id = %(sem_id)s
        ORDER BY
            c.course_name, s.student_name, na.date, na.lecture_num;
    """

    try:
        with connection_to_db() as conn:
            print("✅ Database connection successful.")
            df = pd.read_sql_query(sql, conn, params={'sem_id': sem_id}) # type: ignore
            print(f"Found {len(df)} attendance records to process.")

        if df.empty:
            print(f"⚠️ No attendance data found for semester '{sem_id}'. No report will be generated.")
            return

        # REMOVED: Data transformation is now handled by the SQL query.

        # --- Excel File Generation ---
        with pd.ExcelWriter(output_path, engine='openpyxl') as writer:
            print(f"Writing data to Excel file: {output_path}")

            # Group the entire DataFrame by course to create a sheet for each one.
            for (course_id, course_name), course_df in df.groupby(['course_id', 'course_name']):
                
                # CHANGED: The pivot now uses 'date' and 'lecture_num' for columns.
                pivot_df = course_df.pivot_table(
                    index=['student_id', 'student_name'], 
                    columns=['date', 'lecture_num'], 
                    values='status', 
                    aggfunc='first',
                    fill_value='N/A'
                )

                # CHANGED: Format the new multi-level columns into a single, readable header.
                if isinstance(pivot_df.columns, pd.MultiIndex):
                    pivot_df.columns = [
                        f"{date.strftime('%Y-%m-%d')} (Lec {lec_num})" 
                        for date, lec_num in pivot_df.columns
                    ]
                
                pivot_df.reset_index(inplace=True)
                
                # Sanitize course name for the sheet title
                sanitized_sheet_name = re.sub(r'[\\/*?:"<>|]', "", course_name)[:31]
                
                pivot_df.to_excel(writer, sheet_name=sanitized_sheet_name, index=False)
                print(f"  -> Sheet '{sanitized_sheet_name}' created.")

        print(f"\n🎉 Report successfully generated and saved to '{os.path.abspath(output_path)}'")

    except psycopg.Error as e:
        print(f"❌ Database Error: {e}")
    except Exception as e:
        print(f"❌ An unexpected error occurred: {e}")