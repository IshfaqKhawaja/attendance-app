from fastapi import APIRouter, HTTPException, Depends # type: ignore
from app.core.security import get_current_user
from concurrent.futures import ThreadPoolExecutor, as_completed

from app.db.crud.faculty import display_all as faculties
from app.db.crud.department import display_all_departments as departments
from app.db.crud.program import display_all_programs as programs
from app.db.crud.semester import display_all_semesters as semesters
from app.db.crud.course import display_all_courses as courses


router = APIRouter(
    prefix="/initial",
    tags=["initial"]
)

@router.get("/get_all_data", response_model=dict, summary="Get Initial Data")
def initial_data() -> dict:
    # current_user=Depends(get_current_user)
    try:
        # spin up a thread pool to call each display_all() in parallel
        with ThreadPoolExecutor(max_workers=4) as executor:
            future_to_key = {
                executor.submit(func): key
                for func, key in [
                    (faculties,    "faculties"),
                    (departments,  "departments"),
                    (programs,     "programs"),
                ]
            }

            results: dict[str, list] = {}
            for future in as_completed(future_to_key):
                key = future_to_key[future]
                # .result() will re-raise exceptions if any
                results[key] = future.result()
        return {
            "success": True,
            **results
        }

    except Exception as e:
        # log e if you have logging configured
        raise HTTPException(status_code=500, detail=f"Failed to load initial data: {e}")
