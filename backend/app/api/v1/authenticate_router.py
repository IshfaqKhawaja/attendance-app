from app.db.crud import user
from fastapi import APIRouter, Body, HTTPException # type: ignore
from app.db.crud.authenticate import (
    check_if_teacher_exists,
)
from app.core.mail import send_mail
from app.schemas.teacher import TeacherCreate
from app.schemas.teacher_course import TeacherCourseCreate
from app.utils.otp_verifier import *
from app.db.crud.teacher import add_teacher_to_db
from app.db.crud.user import (
    check_if_user_exists,
)
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
    # Check in teachers relation:::
    access_token = create_access_token(email_id)
    refresh_token = create_refresh_token(email_id) 
    
    # Check if user exists in users table
    user_check = check_if_user_exists(user_id=email_id)
    if user_check["success"]:
        print(user_check)
        return {
            **user_check,
            "is_registered": True,
            "access_token": access_token,
            "refresh_token": refresh_token,
            "is_regular_user": False,
            "message": "Login Success",
        }

    return {
        **check_if_teacher_exists(email_id=email_id),
        "access_token": access_token,
        "refresh_token" : refresh_token,
        "message":"Login Success",
        "is_regular_user": True,
    }

@router.post("/register_teacher", response_model=dict, summary="Add a User")
def register_teacher(
    teacher : TeacherCreate
) -> dict:
    data = add_teacher_to_db(
        teacher=teacher
    )
    if data["success"]:
        return {
            "success" : True,
            "message": "Teacher added",
            "teacher_id": data.get("teacher_id", ""),
            "name" : data.get("teacher_name", ""),
            "type" : data.get("type", ""),
            "dept_id": data.get("dept_id", ""),
        }
    return {
        "success": False,
        "message": "Teacher Could not be added"
    }
        

@router.post("/check_user", response_model=dict, summary="Check If User Exists")
def check(email_id: str = Body(..., embed=True, description="Email ID")) -> dict:
    return check_if_teacher_exists(email_id=email_id)
