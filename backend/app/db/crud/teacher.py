from app.db.connection import connection_to_db
from app.db.models.teacher_model import ReturnTeacherDetails, TeacherCreate, UpdateTeacherRequest


def add_teacher_to_db(teacher : TeacherCreate)->dict:
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO teachers (teacher_id, teacher_name, type, dept_id) VALUES (%s, %s, %s, %s)",
                (teacher.teacher_id, teacher.teacher_name, teacher.type, teacher.dept_id)
            )
        conn.commit()
        return {
            "success" : True,
            "message" : "Teacher Added to DB"
        }
    except Exception as e:
        conn.rollback()
        print("Insert failed:", e)
        return {
            "success" : False,
            "message" : f"Couldn't Add Teacher {e}"
        }
        
        
def display_teacher_by_id(teacher_id: str) -> ReturnTeacherDetails:
    """
    Fetches the Semester row with the given ID and returns it as a dict,
    or returns None if not found.
    """
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            """SELECT 
            * FROM 
            teachers 
            WHERE teacher_id = %s
            ORDER BY teacher_name ASC
            """,
            (teacher_id,)
        )
        row = cur.fetchone()
    if row:
        return ReturnTeacherDetails(
            success=True,
            teachers=[
                TeacherCreate(
                    teacher_id=row[0],
                    teacher_name=row[1],
                    type=row[2],
                    dept_id=row[3]
                )
            ]
        )
    else:
        return ReturnTeacherDetails(
            success=False,
        )

        
def delete_teacher_by_teacher_id(teacher_id: str) -> dict:
    conn = connection_to_db()
    affected_rows = 0
    try:
        with conn.cursor() as cur:
            cur.execute(
                "DELETE FROM teachers WHERE teacher_id = %s",
                (teacher_id,)
            )
            affected_rows = cur.rowcount
            print(f"Number of rows to be deleted: {affected_rows}")

        # Commit the transaction to make the deletion permanent
        if affected_rows > 0:
            conn.commit()
            print("Transaction committed.")
            return {"success": True}
        else:
            # No need to commit if nothing was deleted
            print("No matching teacher_id found, no changes made.")
            return {"success": False}

    except Exception as e:
        # If any error occurs, roll back the changes
        conn.rollback()
        print(f"An error occurred: {e}. Transaction rolled back.")
        return {"success": False, "error": str(e)}

    finally:
        # Always close the connection
        conn.close()
    
    
def display_teacher_by_dept_id(dept_id: str) -> ReturnTeacherDetails:
    """
    Fetches all teachers in a department and returns them as a list of dicts.
    """
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            """SELECT 
            * FROM 
            teachers 
            WHERE dept_id = %s
            ORDER BY teacher_name ASC
            """,
            (dept_id,)
        )
        rows = cur.fetchall()
    if rows:
        return ReturnTeacherDetails(
            success=True,
            teachers=[
                TeacherCreate(
                    teacher_id=row[0],
                    teacher_name=row[1],
                    type=row[2],
                    dept_id=row[3]
                ) for row in rows
            ]
        )
    else:
        return ReturnTeacherDetails(
            success=False,
        )

def edit_teacher_by_id(
    current_teacher_id: str, # The ID of the teacher you want to edit
    teacher_details: UpdateTeacherRequest # An object with the new details
) -> dict:
    conn = connection_to_db()
    try:
        # Extract new details from the request object
        new_teacher_id = teacher_details.details.teacher_id
        teacher_name = teacher_details.details.teacher_name
        teacher_type = teacher_details.details.type
        
        print(f"Attempting to update teacher {current_teacher_id} to new ID {new_teacher_id}")

        with conn.cursor() as cur:
            cur.execute(
                """
                UPDATE teachers
                SET teacher_id = %s, teacher_name = %s, type = %s
                WHERE teacher_id = %s
                """,
                # Use new values in SET, and the current_id in WHERE
                (new_teacher_id, teacher_name, teacher_type, current_teacher_id)
            )
            affected_rows = cur.rowcount
            if affected_rows == 0:
                print(f"No teacher found with ID: {current_teacher_id}. No changes made.")
                # No need to commit if nothing happened
                return {"success": False, "error": "Teacher not found"}

            conn.commit()
            print(f"Transaction committed. Teacher {current_teacher_id} updated to {new_teacher_id}.")
            return {"success": True}

    except Exception as e:
        conn.rollback()
        print(f"An error occurred: {e}. Transaction rolled back.")
        return {"success": False, "error": str(e)}

    finally:
        conn.close()