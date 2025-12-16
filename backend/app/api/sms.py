import logging
import os
from twilio.rest import Client # type: ignore
from twilio.base.exceptions import TwilioRestException # type: ignore

TWILIO_ACCOUNT_SID = os.getenv('TWILIO_ACCOUNT_SID')
TWILIO_AUTH_TOKEN = os.getenv('TWILIO_AUTH_TOKEN')
TWILIO_PHONE_NUMBER = os.getenv('TWILIO_PHONE_NUMBER', '+18125545086')

_client = Client(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)

def send_sms(to: str, body: str) -> dict:
    """
    Send an SMS via Twilio.

    Args:
      to:   Destination phone number, in E.164 format (e.g. "+919876543210")
      body: The text message body.

    Returns:
      dict with:
        - success: bool
        - sid:     message SID (if success)
        - error:   error string (if failure)
    """
    try:
        if len(to) == 10:
            to = f"+91{to}"
        msg = _client.messages.create(
            body=body,
            to=to,
            from_=TWILIO_PHONE_NUMBER,
        )
        return {"success": True, "sid": msg.sid}
    except TwilioRestException as e:
        logging.error(f"Twilio error sending SMS to {to}: {e}")
        return {"success": False, "error": str(e)}
    except Exception as e:
        logging.exception(f"Unexpected error sending SMS to {to}")
        return {"success": False, "error": str(e)}
