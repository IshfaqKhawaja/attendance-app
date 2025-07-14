from fastapi import APIRouter, Body, HTTPException
import datetime

from app.db.crud import course
from app.db.crud import teacher
from app.db.crud.authenticate import (
    check_if_user_exists,
)
from app.core.mail import send_mail
from app.utils.otp_verifier import *
from app.db.crud.teacher import add_teacher_to_db
from app.core.security import (
    create_access_token,
    create_refresh_token,
    )


email_otp_pairs = {}
router = APIRouter(
     prefix="/authenticate",
     tags=["authenticate"]
)



@router.post("/send_otp", response_model=dict)
def send_email(email_id: str = Body(..., embed=True)):
    otp = send_mail(to_addrs=[email_id])
    save_otp(email_id, otp)
    return {"success": True, "otp":otp}

@router.post("/verify_otp", response_model=dict)
def verify_otp(
    email_id: str = Body(..., embed=True),
    otp:      str = Body(..., embed=True),
):
    stored = get_otp(email_id)
    
    if stored is None:
        raise HTTPException(status_code=404, detail="OTP not found or expired")
    print(stored)
    if otp != stored["otp"]:
        return {"success": False, "isRegistered" : False, "message": "Wrong OTP"}
    # Check if User Exists:
    # delete_otp(email_id)
    # Check in teachers relation:::
    access_token = create_access_token(email_id)
    refresh_token = create_refresh_token(email_id) 
    return {
        **check_if_user_exists(email_id=email_id),
        "access_token": access_token,
        "refresh_token" : refresh_token,
        "message":"Login Success",
    }

@router.post("/register_teacher", response_model=dict, summary="Add a User")
def register_teacher(
    teacher_id : str = Body(..., embed=True,description="Teacher ID"),
    teacher_name : str = Body(...,embed=True, description="Teacher Name"),
    type : str = Body(..., embed=True, description="Type of Teacher"),
    dept_id : str = Body(...,embed = True, description="Dept to which teacher belongs to")
    
) -> dict:
    data = add_teacher_to_db(
                teacher_id=teacher_id,
                name=teacher_name,
                dept_id=dept_id,
                type=type,
            )
    if data["success"]:
        return {
            "success" : True,
            "message": "Teacher added",
            "teacher_id": teacher_id,
            "name" : teacher_name,
            "type" : type,
            "dept_id": dept_id, 
        }
    return {
        "success": False,
        "message": "Teacher Could not be added"
    }
        

@router.post("/check_user", response_model=dict, summary="Check If User Exists")
def check(email_id: str = Body(..., embed=True, description="Email ID")) -> dict:
    return check_if_user_exists(email_id=email_id)
