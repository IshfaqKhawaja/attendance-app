# app/db/semester_crud.py
from typing import List
from app.db.connection import connection_to_db
from app.models.semester_model import (
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
                "INSERT INTO semester (semid, name, startdate, enddate, progid) VALUES (%s, %s, %s, %s, %s)",
                (sem.semid, sem.name, sem.start_date, sem.end_date, sem.prog_id),
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
            "SELECT semid, name, startdate, enddate, progid FROM semester WHERE semid = %s",
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
        cur.execute("SELECT semid, name, startdate, enddate, progid FROM semester")
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
                    INSERT INTO semester (semid, name, startdate, enddate, progid)
                    VALUES (%s, %s, %s, %s, %s)
                    ON CONFLICT (semid) DO NOTHING
                    """,
                    (sem.semid, sem.name, sem.start_date, sem.end_date, sem.prog_id)
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


def display_semesters_by_program_id(program_id: str) -> List[SemesterListItem]:
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT semid, name, startdate, enddate FROM semester WHERE progid = %s",
            (program_id,)
        )
        rows = cur.fetchall()
    return [
        SemesterListItem(
            sem_id=r[0],
            sem_name=r[1],
            start_date=r[2],
            end_date=r[3],
            prog_id=program_id
        )
        for r in rows
    ]