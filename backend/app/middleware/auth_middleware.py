"""
JWT Authentication Middleware
Validates JWT tokens and extracts user information
"""
import logging
from typing import Optional
from fastapi import Request, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from starlette.middleware.base import BaseHTTPMiddleware

from app.core.security import decode_access_token

logger = logging.getLogger(__name__)

security = HTTPBearer()


class JWTAuthMiddleware(BaseHTTPMiddleware):
    """
    Middleware to validate JWT tokens on protected routes.
    Adds user_id to request.state if token is valid.
    """

    # Routes that don't require authentication
    EXCLUDED_PATHS = [
        "/",
        "/health",
        "/docs",
        "/redoc",
        "/openapi.json",
        "/authenticate/send_otp",
        "/authenticate/verify_otp",
        "/authenticate/check_user",
        "/authenticate/register_teacher",
        "/initial/get_all_data",  # Allow initial data fetching
    ]

    async def dispatch(self, request: Request, call_next):
        # Check if path should be excluded from auth
        path = request.url.path
        if any(path.startswith(excluded) for excluded in self.EXCLUDED_PATHS):
            return await call_next(request)

        # Get authorization header
        auth_header = request.headers.get("Authorization")

        if not auth_header:
            logger.warning(f"Missing Authorization header for {path}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Missing authentication token",
                headers={"WWW-Authenticate": "Bearer"},
            )

        # Extract token
        try:
            scheme, token = auth_header.split()
            if scheme.lower() != "bearer":
                raise ValueError("Invalid authentication scheme")
        except ValueError:
            logger.warning(f"Invalid Authorization header format for {path}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid authentication credentials",
                headers={"WWW-Authenticate": "Bearer"},
            )

        # Validate token
        try:
            payload = decode_access_token(token)
            user_id = payload.get("sub")

            if not user_id:
                raise ValueError("Token missing user_id")

            # Add user_id to request state for use in route handlers
            request.state.user_id = user_id
            logger.debug(f"Authenticated user: {user_id} for {path}")

        except Exception as e:
            logger.warning(f"Token validation failed for {path}: {str(e)}")
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired token",
                headers={"WWW-Authenticate": "Bearer"},
            )

        # Continue processing request
        response = await call_next(request)
        return response


def get_current_user_id(request: Request) -> str:
    """
    Dependency to extract user_id from request state.
    Use this in route handlers that need the authenticated user.

    Example:
        @router.get("/protected")
        def protected_route(user_id: str = Depends(get_current_user_id)):
            return {"user_id": user_id}
    """
    user_id = getattr(request.state, "user_id", None)
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required"
        )
    return user_id
