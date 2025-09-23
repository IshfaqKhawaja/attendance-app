from fastapi import APIRouter, Body, Depends # type: ignore
from app.db.crud.program import *
from app.core.security import get_current_user
from app.db.models.program_model import (
    ProgramCreate,
    ProgramCreateResponse,
    ProgramDetailResponse,
    BulkProgramCreate,
    BulkProgramCreateResponse,
)


router = APIRouter(
     prefix="/program",
     tags=["program"]
)

@router.post("/add", response_model=ProgramCreateResponse, summary="Insert a new Program")
def add(
    prog : ProgramCreate,  
    user=Depends(get_current_user)
) -> ProgramCreateResponse:
    """
    Expects JSON payload: { "name": "Department of Engineering"}
    """
    return add_program_to_db(
       program=prog
    )


@router.post("/display", response_model=ProgramDetailResponse, summary="Display Program")
def display(prog_id: str = Body(..., embed=True, description="Program ID"), user=Depends(get_current_user)) -> ProgramDetailResponse:
    return display_program_by_id(prog_id)


   
@router.get("/fetch_all", response_model=list, summary = "Get all Faculty Data")
def get_all(user=Depends(get_current_user)):
    return display_all_programs()



@router.post("/bulk_add", response_model=BulkProgramCreateResponse)
def bulk_add_programs(payload: BulkProgramCreate, user=Depends(get_current_user)):
    return add_programs_bulk(payload)


@router.get('/display_programs_by_dept_id/{dept_id}', response_model=ProgramDetailResponse, summary="Get Program Details by Department ID")
def get_program_details(dept_id: str, user=Depends(get_current_user)):
    return display_program_by_dept_id(dept_id)
