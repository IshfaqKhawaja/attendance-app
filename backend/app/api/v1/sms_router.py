# app/api/sms.py
from fastapi import APIRouter, HTTPException, Depends # type: ignore
from app.api.sms import send_sms
from app.db.models.sms_model import (
    SMSRequest,
    SMSResponse,
)
from app.core.security import get_current_user
router = APIRouter(prefix="/send_sms", tags=["send_sms"])


@router.post("/send_sms", response_model=SMSResponse)
def sms_send(req: SMSRequest, user=Depends(get_current_user)):
    result = send_sms(req.to, req.body)
    if not result["success"]:
        # 500 for delivery failure
        raise HTTPException(status_code=500, detail=result["error"])
    return result
