import logging
from twilio.rest import Client # type: ignore
from twilio.base.exceptions import TwilioRestException # type: ignore

# load these from your environment (e.g. via .env + python-dotenv or your deployment system)
TWILIO_ACCOUNT_SID = 'AC0c1da1f9fc67f45611cd1277e166f99b'
TWILIO_AUTH_TOKEN  = 'fb1e49b7aebd8592e1eb25b9d0f2c1d0'

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
            from_='+17817346527',
        )
        return {"success": True, "sid": msg.sid}
    except TwilioRestException as e:
        logging.error(f"Twilio error sending SMS to {to}: {e}")
        return {"success": False, "error": str(e)}
    except Exception as e:
        logging.exception(f"Unexpected error sending SMS to {to}")
        return {"success": False, "error": str(e)}
