from typing import List
from app.db.connection import connection_to_db
from app.db.models.department_model import (
    DepartmentCreate,
    DepartmentCreateResponse,
    DepartmentDetailResponse,
    DepartmentListItem,
    BulkDepartmentCreate,
    BulkDepartmentCreateResponse,
)

def add_department_to_db(dept: DepartmentCreate) -> DepartmentCreateResponse:
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                "INSERT INTO department (deptid, name, factid) VALUES (%s, %s, %s)",
                (dept.deptid, dept.name, dept.fact_id),
            )
        conn.commit()
        return DepartmentCreateResponse(success=True, message="Department added to DB")
    except Exception as e:
        conn.rollback()
        return DepartmentCreateResponse(
            success=False,
            message=f"Couldn't add department: {e}"
        )

def display_department_by_id(deptid: str) -> DepartmentDetailResponse:
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT deptid, name, factid FROM department WHERE deptid = %s",
            (deptid,)
        )
        row = cur.fetchone()
    if row:
        return DepartmentDetailResponse(
            success=True,
            dept_id=row[0],
            dept_name=row[1],
            fact_id=row[2]
        )
    return DepartmentDetailResponse(success=False)

def display_all_departments() -> List[DepartmentListItem]:
    conn = connection_to_db()
    with conn.cursor() as cur:
        cur.execute("SELECT deptid, name, factid FROM department")
        rows = cur.fetchall()
    return [
        DepartmentListItem(dept_id=r[0], dept_name=r[1], fact_id=r[2])
        for r in rows
    ]

def add_departments_bulk(payload: BulkDepartmentCreate) -> BulkDepartmentCreateResponse:
    conn = connection_to_db()
    inserted = 0
    skipped = 0
    try:
        with conn.cursor() as cur:
            for dept in payload.departments:
                cur.execute(
                    """
                    INSERT INTO department (deptid, name, factid)
                    VALUES (%s, %s, %s)
                    ON CONFLICT (deptid) DO NOTHING
                    """,
                    (dept.deptid, dept.name, dept.fact_id)
                )
                if cur.rowcount:
                    inserted += 1
                else:
                    skipped += 1
        conn.commit()
        return BulkDepartmentCreateResponse(
            success=True,
            inserted_count=inserted,
            skipped_count=skipped,
            message=f"{inserted} inserted, {skipped} skipped"
        )
    except Exception as e:
        conn.rollback()
        return BulkDepartmentCreateResponse(
            success=False,
            inserted_count=inserted,
            skipped_count=skipped,
            message=f"Bulk insert failed: {e}"
        )
