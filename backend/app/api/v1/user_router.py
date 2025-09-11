from fastapi import APIRouter, Body, HTTPException # type: ignore
from app.db.crud.user import (
    add_user_to_db,
    display_user_by_id
)

from app.db.models.user_model import DisplayUser, UserIn


email_otp_pairs = {}
router = APIRouter(
     prefix="/users",
     tags=["users"]
)



@router.post("/add", response_model=dict, summary="Add a User")
def add_user(user: UserIn):
    result = add_user_to_db(user)
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result["message"])
    return result




@router.get("/display/{user_id}", response_model=DisplayUser, summary="Display User by ID")
def display_user(user_id: str):
    user_data = display_user_by_id(user_id)
    if not user_data:
        raise HTTPException(status_code=404, detail="User not found")
    return user_data