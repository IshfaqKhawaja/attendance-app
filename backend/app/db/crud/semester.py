# app/db/semester_crud.py
from typing import List
from app.db.connection import connection_to_db
from app.db.models.semester_model import (
    SemesterCreate,
    SemesterCreateResponse,
    SemesterDetailResponse,
    SemesterListItem,
    BulkSemesterCreate,
    BulkSemesterCreateResponse,
)

def add_semester_to_db(sem: SemesterCreate) -> SemesterCreateResponse:
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO semester (sem_id, sem_name, start_date, end_date, prog_id) VALUES (%s, %s, %s, %s, %s)",
                (sem.sem_id, sem.sem_name, sem.start_date, sem.end_date, sem.prog_id),
            )
        conn.commit()
        return SemesterCreateResponse(success=True, message="Semester added to DB")
    except Exception as e:
        conn.rollback()
        return SemesterCreateResponse(
            success=False,
            message=f"Couldn't add semester: {e}"
        )

def display_semester_by_id(semid: str) -> SemesterDetailResponse:
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT sem_id, sem_name, start_date, end_date, prog_id FROM semester WHERE sem_id = %s",
            (semid,)
        )
        row = cur.fetchone()
    if row:
        return SemesterDetailResponse(
            success=True,
            sem_id=row[0],
            sem_name=row[1],
            start_date=row[2],
            end_date=row[3],
            prog_id=row[4]
        )
    return SemesterDetailResponse(success=False)

def display_all_semesters() -> List[SemesterListItem]:
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute("SELECT sem_id, sem_name, start_date, end_date, prog_id FROM semester")
        rows = cur.fetchall()
    return [
        SemesterListItem(
            sem_id=r[0],
            sem_name=r[1],
            start_date=r[2],
            end_date=r[3],
            prog_id=r[4]
        )
        for r in rows
    ]

def add_semesters_bulk(payload: BulkSemesterCreate) -> BulkSemesterCreateResponse:
    conn = connection_to_db()
    inserted = 0
    skipped = 0
    try:
        with conn.cursor() as cur:
            for sem in payload.semesters:
                cur.execute(
                    """
                    INSERT INTO semester (sem_id, sem_name, start_date, end_date, prog_id)
                    VALUES (%s, %s, %s, %s, %s)
                    ON CONFLICT (sem_id) DO NOTHING
                    """,
                    (sem.sem_id, sem.sem_name, sem.start_date, sem.end_date, sem.prog_id)
                )
                if cur.rowcount:
                    inserted += 1
                else:
                    skipped += 1
        conn.commit()
        return BulkSemesterCreateResponse(
            success=True,
            inserted_count=inserted,
            skipped_count=skipped,
            message=f"{inserted} inserted, {skipped} skipped"
        )
    except Exception as e:
        conn.rollback()
        return BulkSemesterCreateResponse(
            success=False,
            inserted_count=inserted,
            skipped_count=skipped,
            message=f"Bulk insert failed: {e}"
        )


def display_semesters_by_program_id(prog_id: str) -> dict:
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT sem_id, sem_name, start_date, end_date FROM semester WHERE prog_id = %s",
            (prog_id,)
        )
        rows = cur.fetchall()
    return {
        "success": True,
        "semesters": [
        SemesterListItem(
            sem_id=r[0],
            sem_name=r[1],
            start_date=r[2],
            end_date=r[3],
            prog_id=prog_id
        )
        for r in rows
    ]
    } if rows else {"success": False, "semesters": []}

def display_semester_with_details_by_id(sem_id: str) -> SemesterDetailResponse:
    """
    Fetch semester details along with program's deptid and factid for a given semid.
    """
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT 
                s.sem_id,
                s.sem_name,
                s.start_date,
                s.end_date,
                s.prog_id,
                p.dept_id,
                p.fact_id
            FROM semester s
            JOIN program p ON s.prog_id = p.prog_id
            WHERE s.sem_id = %s
            """,
            (sem_id,)
        )
        row = cur.fetchone()
    
    if row:
        return SemesterDetailResponse(
            success=True,
            sem_id=row[0],
            sem_name=row[1],
            start_date=row[2],
            end_date=row[3],
            prog_id=row[4],
        )
    return SemesterDetailResponse(success=False, message="Semester not found")



def delete_semester_by_id(semid: str) -> SemesterCreateResponse:
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "DELETE FROM semester WHERE sem_id = %s",
                (semid,)
            )
        conn.commit()
        if cur.rowcount:
            return SemesterCreateResponse(success=True, message="Semester deleted")
        else:
            return SemesterCreateResponse(success=False, message="Semester not found")
    except Exception as e:
        conn.rollback()
        return SemesterCreateResponse(
            success=False,
            message=f"Couldn't delete semester: {e}"
        )