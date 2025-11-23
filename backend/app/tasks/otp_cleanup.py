# app/tasks/otp_cleanup.py
"""
Background task for cleaning up expired OTPs.
This can be run as a cron job or scheduled task.
"""
import logging
import sys
from pathlib import Path

# Add parent directory to path for standalone execution
if __name__ == "__main__":
    backend_dir = Path(__file__).parent.parent.parent
    sys.path.insert(0, str(backend_dir))

from app.utils.otp_verifier_db import cleanup_expired_otps

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def run_otp_cleanup():
    """Run OTP cleanup task."""
    try:
        logger.info("Starting OTP cleanup task...")
        deleted_count = cleanup_expired_otps()
        logger.info(f"OTP cleanup completed. Deleted {deleted_count} expired OTPs.")
        return deleted_count
    except Exception as e:
        logger.error(f"OTP cleanup failed: {e}")
        raise


if __name__ == "__main__":
    """Run cleanup as standalone script."""
    try:
        deleted = run_otp_cleanup()
        print(f"✓ Cleanup complete. Removed {deleted} expired OTPs.")
        sys.exit(0)
    except Exception as e:
        print(f"✗ Cleanup failed: {e}")
        sys.exit(1)
