from typing import List
from app.db.connection import connection_to_db
from app.db.models.faculty_model import (
    FacultyCreate,
    FacultyListItem,
    BulkFacultyCreate, BulkFacultyCreateResponse
)
from app.db.models.faculty_model import FacultyCreateResponse  # Adjust the import path if needed

def add_faculty_to_db(faculty: FacultyCreate) -> FacultyCreateResponse:
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO faculty (fact_id, fact_name) VALUES (%s, %s)",
                (faculty.fact_id, faculty.fact_name)
            )
        conn.commit()
        return FacultyCreateResponse(success=True, message="Added to DB")
    except Exception as e:
        conn.rollback()
        return FacultyCreateResponse(
            success=False,
            message=f"Couldn't add faculty: {e}"
        )

def display_faculty_by_id(fact_id: str) -> dict:
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT fact_id, fact_name FROM faculty WHERE fact_id = %s",
            (fact_id,)
        )
        row = cur.fetchone()
    if row:
        return {
            "success": True,
            "fact_id": row[0],
            "fact_name": row[1]
        }
    return {"success": False, "fact_id": None, "fact_name": None}

def display_all() -> List[FacultyListItem]:
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute("SELECT fact_id, fact_name FROM faculty")
        rows = cur.fetchall()
    return [FacultyListItem(fact_id=r[0], fact_name=r[1]) for r in rows]

def add_faculties_bulk(payload: BulkFacultyCreate) -> BulkFacultyCreateResponse:
    """
    Inserts each FacultyCreate in payload.faculties.
    Skips any fact_id that already exists (using PostgreSQL ON CONFLICT).
    """
    conn = connection_to_db()
    inserted = 0
    skipped = 0
    try:
        with conn.cursor() as cur:
            for fac in payload.faculties:
                # uses Postgres ON CONFLICT; adjust if you’re on MySQL (e.g. INSERT IGNORE)
                cur.execute(
                    """
                    INSERT INTO faculty (fact_id, fact_name)
                    VALUES (%s, %s)
                    ON CONFLICT (fact_id) DO NOTHING
                    """,
                    (fac.fact_id, fac.fact_name)
                )
                # rowcount == 1 if inserted, 0 if conflict
                if cur.rowcount:
                    inserted += 1
                else:
                    skipped += 1
        conn.commit()
        return BulkFacultyCreateResponse(
            success=True,
            inserted_count=inserted,
            skipped_count=skipped,
            message=f"{inserted} inserted, {skipped} skipped"
        )
    except Exception as e:
        conn.rollback()
        return BulkFacultyCreateResponse(
            success=False,
            inserted_count=inserted,
            skipped_count=skipped,
            message=f"Bulk insert failed: {e}"
        )
