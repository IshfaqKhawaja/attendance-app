import logging
from twilio.rest import Client
from twilio.base.exceptions import TwilioRestException

from app.core.settings import settings

logger = logging.getLogger(__name__)


def send_sms(to: str, body: str) -> dict:
    """
    Send an SMS via Twilio.

    Args:
      to:   Destination phone number (with country code, e.g. "+919876543210")
      body: The text message body.

    Returns:
      dict with:
        - success: bool
        - sid: message SID from Twilio (if success)
        - error: error string (if failure)
    """
    try:
        # Clean the phone number
        phone = str(to).strip()

        # Add country code if not present (assume India +91)
        if not phone.startswith("+"):
            if phone.startswith("91") and len(phone) == 12:
                phone = "+" + phone
            elif len(phone) == 10 and phone.isdigit():
                phone = "+91" + phone
            else:
                phone = "+" + phone

        if not settings.TWILIO_ACCOUNT_SID or not settings.TWILIO_AUTH_TOKEN:
            logger.error("Twilio credentials not configured")
            return {"success": False, "error": "SMS service not configured"}

        if not settings.TWILIO_PHONE_NUMBER:
            logger.error("Twilio phone number not configured")
            return {"success": False, "error": "SMS sender not configured"}

        client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)

        message = client.messages.create(
            body=body,
            from_=settings.TWILIO_PHONE_NUMBER,
            to=phone
        )

        logger.info(f"SMS sent successfully to {phone}, SID: {message.sid}")
        return {
            "success": True,
            "sid": message.sid,
            "status": message.status
        }

    except TwilioRestException as e:
        logger.error(f"Twilio error sending SMS to {to}: {e.msg}")
        return {"success": False, "error": e.msg}
    except Exception as e:
        logger.exception(f"Unexpected error sending SMS to {to}")
        return {"success": False, "error": str(e)}
