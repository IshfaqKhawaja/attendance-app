# app/core/otp_store.py
import datetime
import json
import threading
from pathlib import Path

_OTP_FILE = Path("email_otps.json")
_lock = threading.Lock()

def _read_store() -> dict:
    if not _OTP_FILE.exists():
        return {}
    try:
        return json.loads(_OTP_FILE.read_text())
    except json.JSONDecodeError:
        return {}

def _write_store(data: dict) -> None:
    # atomic replace
    tmp = _OTP_FILE.with_suffix(".tmp")
    tmp.write_text(json.dumps(data))
    tmp.rename(_OTP_FILE)

def save_otp(email: str, otp: str) -> None:
    with _lock:
        store = _read_store()
        store[email] = {
            "otp" : otp,
            "created_at" : str(datetime.datetime.now()),
        }
        _write_store(store)

def get_otp(email: str) -> dict:
    store = _read_store()
    return store.get(email) #type: ignore

def delete_otp(email: str) -> None:
    with _lock:
        store = _read_store()
        if email in store:
            del store[email]
            _write_store(store)
