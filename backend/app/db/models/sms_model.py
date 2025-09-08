from pydantic import BaseModel # type: ignore

class SMSRequest(BaseModel):
    to: str
    body: str

class SMSResponse(BaseModel):
    success: bool
    sid:    str | None = None
    error:  str | None = None