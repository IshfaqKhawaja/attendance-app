from app.db.connection import connection_to_db


def add_teacher_to_db(teacher_id : str, name : str, type : str, dept_id: str)->dict:
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO teachers (teacherid, name , type, deptid) VALUES (%s, %s, %s, %s)",
                (teacher_id, name , type, dept_id)
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
        
        
def display_teacher_by_id(teacher_id: str) -> dict:
    """
    Fetches the Semester row with the given ID and returns it as a dict,
    or returns None if not found.
    """
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT * FROM teachers WHERE teacherid = %s",
            (teacher_id,)
        )
        row = cur.fetchone()
    if row:
        return {
            "success" : True ,
            "teacher_id": row[0],
            "teacher_name": row[1],
            "type": row[2],
            "dept_id" : row[3],
            }
    else:
        return {
            "success" : False,
        }
        
        
def delete_teacher_by_teacher_id(teacher_id: str):
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "DELETE FROM teachers WHERE teacherid = %s",
            (teacher_id,)
        )
        row = cur.fetchone()
    if row:
        return {
            "success" : True ,
            }
    else:
        return {
            "success" : False,
        }
    