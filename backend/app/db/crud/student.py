from typing import Union
from app.db.connection import connection_to_db


def add_student_to_db(
    student_id : str,
    name : str,
    phone_number : int,
    prog_id: str,
    sem_id:str,
    dept_id : str ):
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO students (studentid, name , phonenumber, progid, semid, deptid) VALUES (%s, %s, %s, %s, %s, %s)",
                (student_id, name , phone_number,  prog_id, sem_id, dept_id)
            )
        conn.commit()
        return {
            "success" : True,
            "message" : "Student Added to DB"
        }
    except Exception as e:
        conn.rollback()
        print("Insert failed:", e)
        return {
            "success" : False,
            "message" : f"Couldn't Add Student {e}"
        }
        
        
def display_student_by_id(student_id: str) -> dict:
    """
    Fetches the Semester row with the given ID and returns it as a dict,
    or returns None if not found.
    """
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT * FROM students WHERE studentid = %s",
            (student_id,)
        )
        row = cur.fetchone()
    print(row)
    if row:
        return {
            "success" : True ,
            "student_id": row[0],
            "student_name": row[1],
            "phone_number": row[2],
            "prog_id" : row[3],
            "sem_id": row[4],
            "dept_id": row[5]
            }
    else:
        return {
            "success" : False,
        }
        

def add_students_in_bulk(
    students: list[dict[str, Union[str, int]]]
) -> dict:
    """
    Inserts multiple students in one transaction.
    Skips students whose `student_id` already exists in the DB.
    Expects each student dict to have:
      - student_id (str)
      - student_name (str)
      - phone_number (int)
      - prog_id    (str)
      - sem_id     (str)
      - dept_id    (str)
    """
    if not isinstance(students, list):
        return {"success": False, "message": "Payload must be a list of student dicts"}

    records = []
    for idx, st in enumerate(students, start=1):
        if not isinstance(st, dict):
            return {"success": False, "message": f"Item #{idx} is not a dict"}
        try:
            records.append((
                st["student_id"],
                st["student_name"],
                st["phone_number"],
                st["prog_id"],
                st["sem_id"],
                st["dept_id"],
            ))
        except KeyError as missing:
            return {
                "success": False,
                "message": f"Item #{idx} missing field '{missing.args[0]}'"
            }

    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.executemany(
                """
                INSERT INTO students
                  (studentid, name, phonenumber, progid, semid, deptid)
                VALUES (%s, %s, %s, %s, %s, %s)
                ON CONFLICT (studentid) DO NOTHING
                """,
                records
            )
        conn.commit()
        return {
            "success": True,
            "message": f"Tried inserting {len(records)} students. Students with duplicate IDs were skipped."
        }
    except Exception as e:
        conn.rollback()
        print("Bulk insert failed:", e)
        return {
            "success": False,
            "message": f"Couldn't add students in bulk: {e}"
        }

        
def display_student_by__sem_id(sem_id: str) -> dict:
    """
    Fetches the Semester row with the given ID and returns it as a dict,
    or returns None if not found.
    """
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT * FROM students WHERE semid = %s",
            (sem_id,)
        )
        rows = cur.fetchall()
    data = []
    if rows:
        for row in rows:
            data.append({
                "student_id": row[0],
                "student_name": row[1],
                "phone_number": row[2],
                "prog_id" : row[3],
                "sem_id": row[4],
                "dept_id": row[5]
                }
            )
   
    return {
        "success" : True,
        "students" : data
    }
    
    
def fetch_students_by_student_ids(student_ids: list) -> dict:
    """
    Fetches the Students with student ids provided in the list.
    """
    if not student_ids:
        return {"success": True, "students": []}

    conn = connection_to_db()
    with conn.cursor() as cur:
        placeholders = ','.join(['%s'] * len(student_ids))
        query = f"SELECT * FROM students WHERE studentid IN ({placeholders})"
        cur.execute(query, student_ids) # type: ignore
        rows = cur.fetchall()

    data = []
    for row in rows:
        data.append({
            "student_id": row[0],
            "student_name": row[1],
            "phone_number": row[2],
            "prog_id": row[3],
            "sem_id": row[4],
            "dept_id": row[5]
        })

    return {
        "success": True,
        "students": data
    }
