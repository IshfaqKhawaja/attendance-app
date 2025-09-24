# app/core/security.py
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi import Request
import jwt
import datetime

from app.core.secrets import JWT_SECRET_KEY, ALGORITHM
def create_access_token(user_id: str):
    expire = datetime.datetime.utcnow() + datetime.timedelta(minutes=15)
    payload = {"sub": user_id, "exp": expire}
    return jwt.encode(payload, JWT_SECRET_KEY, algorithm=ALGORITHM)

def create_refresh_token(user_id: str) -> str:
    expire = datetime.datetime.utcnow() + datetime.timedelta(days=15)
    payload = {"sub": user_id, "exp": expire}
    return jwt.encode(payload, JWT_SECRET_KEY, algorithm=ALGORITHM)


# Use HTTPBearer for Swagger UI bearer token support

# Custom HTTPBearer that returns 401 instead of 403 if header is missing
class CustomHTTPBearer(HTTPBearer):
    async def __call__(self, request: Request) -> HTTPAuthorizationCredentials:
        try:
            return await super().__call__(request)
        except HTTPException as exc:
            if exc.status_code == status.HTTP_403_FORBIDDEN:
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Not authenticated",
                    headers={"WWW-Authenticate": "Bearer"},
                )
            raise

http_bearer = CustomHTTPBearer()

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(http_bearer)) -> dict:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    token = credentials.credentials
    try:
        payload = jwt.decode(token, JWT_SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        if user_id is None or not isinstance(user_id, str):
            raise credentials_exception
    except:
        raise credentials_exception

    user = {"user_id": user_id}
    print("User is ", user_id)
    if user is None:
        raise credentials_exception
    return user
