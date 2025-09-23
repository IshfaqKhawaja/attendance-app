

from fastapi import APIRouter, Body, HTTPException, Request # type: ignore
import jwt
from app.core.secrets import JWT_SECRET_KEY, ALGORITHM
# ...existing code...

# ...existing code...

from app.db.crud.authenticate import (
    check_if_teacher_exists,
)
from app.core.mail import send_mail
from app.db.models.teacher_model import TeacherCreate
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


# --- Token Refresh Endpoint ---
@router.post("/token/refresh", response_model=dict, summary="Refresh Access Token")
async def refresh_access_token(request: Request):
    # Accept refresh token from Authorization header or body
    refresh_token = None
    auth_header = request.headers.get("Authorization")
    if auth_header and auth_header.startswith("Bearer "):
        refresh_token = auth_header.split(" ", 1)[1]
    else:
        try:
            data = await request.json()
            refresh_token = data.get("refresh_token")
        except Exception:
            refresh_token = None
    if not refresh_token:
        return {"success": False, "message": "Refresh token required"}
    try:
        payload = jwt.decode(refresh_token, JWT_SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        if not user_id:
            return {"success": False, "message": "Invalid refresh token"}
        new_access_token = create_access_token(user_id)
        return {
            "success": True,
            "access_token": new_access_token,
            "message": "Access token refreshed"
        }
    except jwt.ExpiredSignatureError:
        return {"success": False, "message": "Refresh token expired"}
    except Exception:
        return {"success": False, "message": "Invalid refresh token"}
from fastapi import APIRouter, Body, HTTPException # type: ignore
from app.db.crud.authenticate import (
    check_if_teacher_exists,
)
from app.core.mail import send_mail
from app.db.models.teacher_model import TeacherCreate
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
