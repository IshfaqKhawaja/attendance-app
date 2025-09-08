# app/db/program_crud.py
from typing import List
from app.db.connection import connection_to_db
from app.db.models.program_model import (
    ProgramCreate,
    ProgramCreateResponse,
    ProgramDetailResponse,
    ProgramListItem,
    BulkProgramCreate,
    BulkProgramCreateResponse,
)

def add_program_to_db(program: ProgramCreate) -> ProgramCreateResponse:
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO program (progid, name, deptid, factid) VALUES (%s, %s, %s, %s)",
                (program.progid, program.name, program.dept_id, program.fact_id),
            )
        conn.commit()
        return ProgramCreateResponse(success=True, message="Program added to DB")
    except Exception as e:
        conn.rollback()
        return ProgramCreateResponse(
            success=False,
            message=f"Couldn't add program: {e}"
        )

def display_program_by_id(progid: str) -> ProgramDetailResponse:
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT progid, name, deptid, factid FROM program WHERE progid = %s",
            (progid,)
        )
        row = cur.fetchone()
    if row:
        return ProgramDetailResponse(
            success=True,
            prog_id=row[0],
            prog_name=row[1],
            dept_id=row[2],
            fact_id=row[3]
        )
    return ProgramDetailResponse(success=False)

def display_all_programs() -> List[ProgramListItem]:
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute("SELECT progid, name, deptid, factid FROM program")
        rows = cur.fetchall()
    return [
        ProgramListItem(prog_id=r[0], prog_name=r[1], dept_id=r[2], fact_id=r[3])
        for r in rows
    ]

def add_programs_bulk(payload: BulkProgramCreate) -> BulkProgramCreateResponse:
    conn = connection_to_db()
    inserted = 0
    skipped = 0
    try:
        with conn.cursor() as cur:
            for prog in payload.programs:
                cur.execute(
                    """
                    INSERT INTO program (progid, name, deptid, factid)
                    VALUES (%s, %s, %s, %s)
                    ON CONFLICT (progid) DO NOTHING
                    """,
                    (prog.progid, prog.name, prog.dept_id, prog.fact_id)
                )
                if cur.rowcount:
                    inserted += 1
                else:
                    skipped += 1
        conn.commit()
        return BulkProgramCreateResponse(
            success=True,
            inserted_count=inserted,
            skipped_count=skipped,
            message=f"{inserted} inserted, {skipped} skipped"
        )
    except Exception as e:
        conn.rollback()
        return BulkProgramCreateResponse(
            success=False,
            inserted_count=inserted,
            skipped_count=skipped,
            message=f"Bulk insert failed: {e}"
        )



def display_program_by_dept_id(dept_id: str) -> ProgramDetailResponse:
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT progid, name, deptid, factid FROM program WHERE deptid = %s",
            (dept_id,)
        )
        row = cur.fetchone()
    if row:
        return ProgramDetailResponse(
            success=True,
            prog_id=row[0],
            prog_name=row[1],
            dept_id=row[2],
            fact_id=row[3]
        )
    return ProgramDetailResponse(success=False)