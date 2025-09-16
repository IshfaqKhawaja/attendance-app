from app.db.connection import connection_to_db

def check_if_teacher_exists(email_id: str) -> dict:
    """
    Returns a dict of all columns for the user with given email_id (userid),
    or None if no such user is found.
    """
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT teacher_id,
                   teacher_name,
                    type,
                    dept_id
                FROM teachers
                WHERE teacher_id = %s
            """,
            (email_id,),
        )
        row = cur.fetchone()
    conn.close()
    if row:
        return {
            "success" : True,
            "is_registered" : True,
            "teacher_id" : row[0],
            "teacher_name" : row[1],
            "type" : row[2],
            "dept_id" : row[3]  
        }
    else:
        return {
            "success" : True,
            "is_registered": False,
        }

def add_teacher(email_id : str, teacher_name : str, type : str, dept_id : str) -> dict:
    """
    Returns a dict of all columns for the user with given email_id (userid),
    or None if no such user is found.
    """
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO  teachers (
                    teacher_id,
                    teacher_name,
                    type,
                    dept_id) VALUES (%s, %s , %s , %s)
                    
                """,
                (email_id, teacher_name, type, dept_id),
            )
        conn.close()
        return {
            "success" : True,
            "message" : f"{email_id} added to Users"
        }
    except Exception as e:
        conn.rollback()
        print("Insert failed:", e)
        return {
            "success" : False,
            "message" : f"Couldn't Add User {e}"
        }