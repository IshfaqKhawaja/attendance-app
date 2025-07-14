import secrets
import smtplib
from email.message import EmailMessage

def send_mail(
    to_addrs,
    use_tls: bool = True,
):
    """
    Generates a 6-digit OTP, emails it as HTML, and returns the OTP.
    """
    smtp_host = "smtp.gmail.com"
    smtp_port = 587      # use 465 and use_tls=False to use SSL instead
    smtp_email = "ishfaqkhawaja08@gmail.com"
    smtp_password = "uhdn bafn cucz ejei" 
  

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
            If you didn’t request this, you can safely ignore this email.
          </p>
        </div>
      </body>
    </html>
    """

    # 3. Create the email message
    msg = EmailMessage()
    msg["Subject"] = "no reply"
    msg["From"] = smtp_email
    msg["To"] = to_addrs
    # Plain-text fallback
    msg.set_content(f"Your verification code is {otp}")
    # HTML version
    msg.add_alternative(html_body, subtype="html")

    # 4. Send via SMTP
    if use_tls:
        server = smtplib.SMTP(smtp_host, smtp_port)
        server.ehlo()
        server.starttls()
        server.ehlo()
    else:
        server = smtplib.SMTP_SSL(smtp_host, smtp_port)

    try:
        server.login(smtp_email, smtp_password)
        server.send_message(msg)
        print(f"Sent OTP to {to_addrs}")
    finally:
        server.quit()

    # 5. Return the generated code
    return otp