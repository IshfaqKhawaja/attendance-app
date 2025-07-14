from datetime import date
from app.db.connection import connection_to_db

def check_if_user_exists(email_id: str) -> dict:
    """
    Returns a dict of all columns for the user with given email_id (userid),
    or None if no such user is found.
    """
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT teacherid,
                    name,
                    type,
                    deptid
                FROM teachers
                WHERE teacherid = %s
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
            "name" : row[1],
            "type" : row[2],
            "dept_id" : row[3]  
        }
    else:
        return {
            "success" : True,
            "is_registered": False,
        }

def add_user(email_id : str, name : str, type : str, dept_id : str) -> dict:
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
                    teacherid,
                    name,
                    type,
                    dept_id) VALUES (%s, %s , %s , %s)
                    
                """,
                (email_id, name, type, dept_id),
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