from app.db.connection import connection_to_db
from app.db.models.user_model import UserModelIn

def add_user_to_db(user: UserModelIn) -> dict:
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO users (user_id, user_name, type, dept_id, fact_id) VALUES (%s, %s, %s, %s, %s)",
                (user.user_id, user.user_name, user.type, user.dept_id, user.fact_id)
            )
        conn.commit()
        return {
            "success" : True,
            "message" : "User Added to DB"
        }
    except Exception as e:
        conn.rollback()
        print("Insert failed:", e)
        return {
            "success" : False,
            "message" : f"Couldn't Add User {e}"
        }
        
        
def check_if_user_exists(user_id: str) -> dict:
    """
    Returns a dict of all columns for the user with given email_id (userid),
    or None if no such user is found.
    """
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT * FROM users WHERE user_id = %s",
            (user_id,)
        )
        row = cur.fetchone()
    if row:
        return {
            "success" : True,
            "user_id": row[0],
            "user_name": row[1],
            "type": row[2],
            "dept_id": row[3],
            "fact_id": row[4]
        }
    else:
        return {
            "success" : False,
        }
        
        
def display_user_by_id(user_id: str) -> dict:
    """Fetches the User row with the given ID and returns it as a dict,
    or returns None if not found.
    """
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT * FROM users WHERE user_id = %s",
            (user_id,)
        )
        row = cur.fetchone()
    if row:
        return {
            "success" : True ,
            "user_id": row[0],
            "user_name": row[1],
            "type": row[2],
            "dept_id": row[3],
            "fact_id": row[4]
        }
    else:
        return {
            "success" : False,
        }


def delete_user_by_user_id(user_id: str):
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "DELETE FROM users WHERE user_id = %s",
            (user_id,)
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