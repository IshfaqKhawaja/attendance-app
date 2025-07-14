# app/api/sms.py
from fastapi import APIRouter, HTTPException # type: ignore
from app.api.sms import send_sms
from app.models.sms_model import (
    SMSRequest,
    SMSResponse,
)
router = APIRouter(prefix="/send_sms", tags=["send_sms"])


@router.post("/send_sms", response_model=SMSResponse)
def sms_send(req: SMSRequest):
    result = send_sms(req.to, req.body)
    if not result["success"]:
        # 500 for delivery failure
        raise HTTPException(status_code=500, detail=result["error"])
    return result
