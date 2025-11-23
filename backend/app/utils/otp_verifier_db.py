# app/utils/otp_verifier_db.py
"""
Database-backed OTP storage with expiration.
Replaces the JSON file-based storage with PostgreSQL.
"""
import datetime
import logging
from app.db.connection import connection_to_db

logger = logging.getLogger(__name__)

# OTP expires after 10 minutes
OTP_EXPIRY_MINUTES = 10
MAX_ATTEMPTS = 5


def save_otp(email: str, otp: str) -> None:
    """
    Save OTP to database with expiration time.
    Replaces existing OTP if one exists for this email.
    """
    conn = connection_to_db()
    try:
        expires_at = datetime.datetime.now() + datetime.timedelta(minutes=OTP_EXPIRY_MINUTES)

        with conn.cursor() as cur:
            cur.execute(
                """
                INSERT INTO otp_storage (email, otp, created_at, expires_at, attempts)
                VALUES (%s, %s, CURRENT_TIMESTAMP, %s, 0)
                ON CONFLICT (email)
                DO UPDATE SET
                    otp = EXCLUDED.otp,
                    created_at = CURRENT_TIMESTAMP,
                    expires_at = EXCLUDED.expires_at,
                    attempts = 0
                """,
                (email, otp, expires_at)
            )
        conn.commit()
        logger.info(f"OTP saved for {email}, expires at {expires_at}")
    except Exception as e:
        conn.rollback()
        logger.error(f"Failed to save OTP for {email}: {e}")
        raise
    finally:
        conn.close()


def get_otp(email: str) -> dict | None:
    """
    Retrieve OTP for email if it exists and hasn't expired.
    Returns None if OTP doesn't exist or has expired.
    Automatically deletes expired OTPs.
    """
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            # Get OTP and check if it's expired
            cur.execute(
                """
                SELECT otp, created_at, expires_at, attempts
                FROM otp_storage
                WHERE email = %s
                """,
                (email,)
            )
            row = cur.fetchone()

            if not row:
                return None

            otp, created_at, expires_at, attempts = row

            # Check if expired
            if datetime.datetime.now() > expires_at:
                # Delete expired OTP
                cur.execute("DELETE FROM otp_storage WHERE email = %s", (email,))
                conn.commit()
                logger.info(f"Expired OTP deleted for {email}")
                return None

            # Check if too many attempts
            if attempts >= MAX_ATTEMPTS:
                logger.warning(f"Max attempts reached for {email}")
                return None

            return {
                "otp": otp,
                "created_at": str(created_at),
                "expires_at": str(expires_at),
                "attempts": attempts
            }
    except Exception as e:
        logger.error(f"Failed to get OTP for {email}: {e}")
        return None
    finally:
        conn.close()


def verify_otp(email: str, submitted_otp: str) -> bool:
    """
    Verify OTP and increment attempt counter.
    Returns True if OTP is correct, False otherwise.
    Deletes OTP if verification succeeds.
    """
    conn = connection_to_db()
    try:
        otp_data = get_otp(email)

        if not otp_data:
            return False

        stored_otp = otp_data["otp"]
        attempts = otp_data["attempts"]

        # Increment attempts
        with conn.cursor() as cur:
            if stored_otp == submitted_otp:
                # Correct OTP - delete it
                cur.execute("DELETE FROM otp_storage WHERE email = %s", (email,))
                conn.commit()
                logger.info(f"OTP verified successfully for {email}")
                return True
            else:
                # Wrong OTP - increment attempts
                cur.execute(
                    """
                    UPDATE otp_storage
                    SET attempts = attempts + 1
                    WHERE email = %s
                    """,
                    (email,)
                )
                conn.commit()
                logger.warning(f"Invalid OTP attempt for {email}, attempts: {attempts + 1}")
                return False
    except Exception as e:
        conn.rollback()
        logger.error(f"Failed to verify OTP for {email}: {e}")
        return False
    finally:
        conn.close()


def delete_otp(email: str) -> None:
    """
    Delete OTP for the given email.
    """
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute("DELETE FROM otp_storage WHERE email = %s", (email,))
        conn.commit()
        logger.info(f"OTP deleted for {email}")
    except Exception as e:
        conn.rollback()
        logger.error(f"Failed to delete OTP for {email}: {e}")
    finally:
        conn.close()


def cleanup_expired_otps() -> int:
    """
    Delete all expired OTPs from the database.
    Returns the number of OTPs deleted.
    Should be called periodically (e.g., via a cron job).
    """
    conn = connection_to_db()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                DELETE FROM otp_storage
                WHERE expires_at < CURRENT_TIMESTAMP
                """
            )
            deleted_count = cur.rowcount
        conn.commit()
        logger.info(f"Cleaned up {deleted_count} expired OTPs")
        return deleted_count
    except Exception as e:
        conn.rollback()
        logger.error(f"Failed to cleanup expired OTPs: {e}")
        return 0
    finally:
        conn.close()
