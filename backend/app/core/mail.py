import secrets
import smtplib
from email.message import EmailMessage
import logging

from app.core.settings import settings

logger = logging.getLogger(__name__)


def send_mail(
    to_addrs,
    use_tls: bool = None,
):
    """
    Generates a 6-digit OTP, emails it as HTML, and returns the OTP.

    Args:
        to_addrs: Email address(es) to send to
        use_tls: Whether to use TLS (defaults to settings.SMTP_USE_TLS)

    Returns:
        str: The generated OTP code
    """
    if use_tls is None:
        use_tls = settings.SMTP_USE_TLS

    # 1. Generate a 6-digit OTP
    otp = f"{secrets.randbelow(10**6):06d}"

    # 2. Build the HTML content
    html_body = f"""\
    <!DOCTYPE html>
    <html>
      <body style="font-family: Arial, sans-serif; background: #f4f4f4; padding: 20px;">
        <div style="max-width:600px; margin:0 auto; background:#fff; padding:20px; border-radius:8px; text-align:center;">
          <h2 style="color:#333;">Your One-Time Verification Code</h2>
          <p>Enter the code below to complete your sign-in:</p>
          <div style="
            display:inline-block;
            background:#eee;
            padding:16px 24px;
            font-size:32px;
            letter-spacing:4px;
            border-radius:4px;
            margin:16px 0;
          ">
            <strong>{otp}</strong>
          </div>
          <p style="color:#555; font-size:14px;">
            This code will expire in 10 minutes.
          </p>
          <hr style="margin:24px 0; border:none; border-top:1px solid #ddd;" />
          <p style="color:#888; font-size:12px;">
            If you didn't request this, you can safely ignore this email.
          </p>
        </div>
      </body>
    </html>
    """

    # 3. Create the email message
    msg = EmailMessage()
    msg["Subject"] = f"{settings.APP_NAME} - Verification Code"
    msg["From"] = settings.SMTP_EMAIL
    msg["To"] = to_addrs
    # Plain-text fallback
    msg.set_content(f"Your verification code is {otp}")
    # HTML version
    msg.add_alternative(html_body, subtype="html")

    # 4. Send via SMTP
    try:
        if use_tls:
            server = smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT)
            server.ehlo()
            server.starttls()
            server.ehlo()
        else:
            server = smtplib.SMTP_SSL(settings.SMTP_HOST, settings.SMTP_PORT)

        server.login(settings.SMTP_EMAIL, settings.SMTP_PASSWORD)
        server.send_message(msg)
        logger.info(f"Sent OTP to {to_addrs}")
        server.quit()
    except smtplib.SMTPException as e:
        logger.error(f"SMTP error sending email to {to_addrs}: {str(e)}")
        raise Exception(f"Failed to send email: {str(e)}")
    except Exception as e:
        logger.error(f"Unexpected error sending email to {to_addrs}: {str(e)}")
        raise Exception(f"Failed to send email: {str(e)}")

    # 5. Return the generated code
    return otp
