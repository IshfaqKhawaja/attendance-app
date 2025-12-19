"""
Authentication router for handling user login and registration.
"""
import logging
from fastapi import APIRouter, Body, HTTPException

from app.db.crud.authenticate import check_if_teacher_exists
from app.core.mail import send_mail
from app.db.models.teacher_model import TeacherCreate
from app.utils.otp_verifier_db import save_otp, verify_otp as verify_otp_db, delete_otp
from app.db.crud.teacher import add_teacher_to_db
from app.db.crud.user import check_if_user_exists
from app.core.security import create_access_token, create_refresh_token
from app.core.settings import settings

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/authenticate",
    tags=["authenticate"]
)


@router.post("/send_otp", response_model=dict)
def send_email(email_id: str = Body(..., embed=True)):
    """
    Send OTP to user's email address.
    Returns success status only - OTP is NOT returned for security.
    """
    try:
        otp = send_mail(to_addrs=[email_id])
        save_otp(email_id, otp)

        # TODO: Remove this logging before production deployment
        print(f"\n{'='*50}")
        print(f"OTP GENERATED - {email_id} -> {otp}")
        print(f"{'='*50}\n")
        logger.info(f"OTP sent successfully to {email_id}")
        logger.warning(f"[DEV] OTP for {email_id}: {otp}")

        # SECURITY: Do NOT return OTP in production
        response = {"success": True, "message": "OTP sent to your email"}

        # Only include OTP in development mode for testing
        if settings.DEBUG and settings.ENVIRONMENT == "development":
            response["otp"] = otp

        return response
    except Exception as e:
        logger.error(f"Failed to send OTP to {email_id}: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to send OTP. Please try again.")


@router.post("/verify_otp", response_model=dict)
def verify_otp(
    email_id: str = Body(..., embed=True),
    otp: str = Body(..., embed=True),
):
    """
    Verify OTP and authenticate user.
    Returns access and refresh tokens on success.
    """
    logger.debug(f"Verifying OTP for {email_id}")

    # Verify OTP using database-backed verification
    if not verify_otp_db(email_id, otp):
        logger.warning(f"OTP verification failed for {email_id}")
        return {"success": False, "isRegistered": False, "message": "Invalid or expired OTP"}

    # Generate tokens
    access_token = create_access_token(email_id)
    refresh_token = create_refresh_token(email_id)

    # Check if user exists in users table
    user_check = check_if_user_exists(user_id=email_id)
    if user_check["success"]:
        logger.info(f"User authenticated successfully: {email_id} (type: {user_check.get('type', 'N/A')})")
        return {
            **user_check,
            "is_registered": True,
            "access_token": access_token,
            "refresh_token": refresh_token,
            "is_hod": user_check.get("type", "") == "HOD",
            "is_super_admin": user_check.get("type", "") == "SUPER_ADMIN",
            "message": "Login Success",
        }

    # Check if teacher exists
    teacher_check = check_if_teacher_exists(email_id=email_id)
    logger.info(f"Teacher authenticated successfully: {email_id}")
    return {
        **teacher_check,
        "access_token": access_token,
        "refresh_token": refresh_token,
        "message": "Login Success",
        "is_regular_user": True,
    }


@router.post("/register_teacher", response_model=dict, summary="Register a new teacher")
def register_teacher(teacher: TeacherCreate) -> dict:
    """
    Register a new teacher in the system.
    """
    try:
        data = add_teacher_to_db(teacher=teacher)

        if data["success"]:
            logger.info(f"Teacher registered successfully: {data.get('teacher_id', '')}")
            return {
                "success": True,
                "message": "Teacher added successfully",
                "teacher_id": data.get("teacher_id", ""),
                "name": data.get("teacher_name", ""),
                "type": data.get("type", ""),
                "dept_id": data.get("dept_id", ""),
            }

        logger.warning("Teacher registration failed")
        return {
            "success": False,
            "message": "Teacher could not be added"
        }
    except Exception as e:
        logger.error(f"Error registering teacher: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to register teacher")


@router.post("/check_user", response_model=dict, summary="Check if user exists")
def check(email_id: str = Body(..., embed=True, description="Email ID")) -> dict:
    """
    Check if a user exists in the system by email ID.
    """
    logger.debug(f"Checking user existence: {email_id}")
    return check_if_teacher_exists(email_id=email_id)
