"""
Rate limiting middleware to prevent abuse of API endpoints.
"""
from fastapi import Request, HTTPException, status
from starlette.middleware.base import BaseHTTPMiddleware
from typing import Dict, Tuple
import time
import logging

from app.core.settings import settings

logger = logging.getLogger(__name__)


class RateLimitMiddleware(BaseHTTPMiddleware):
    """
    Simple in-memory rate limiter.
    Tracks requests per IP address within a time window.

    For production, consider using Redis-based rate limiting.
    """

    def __init__(self, app, calls: int = None, period: int = 60):
        """
        Initialize rate limiter.

        Args:
            app: FastAPI application
            calls: Number of calls allowed per period (defaults to settings)
            period: Time period in seconds (default: 60)
        """
        super().__init__(app)
        self.calls = calls or settings.RATE_LIMIT_PER_MINUTE
        self.period = period
        # Storage: {ip_address: [(timestamp1, timestamp2, ...)]}
        self.requests: Dict[str, list] = {}

    async def dispatch(self, request: Request, call_next):
        # Get client IP
        client_ip = request.client.host if request.client else "unknown"

        # Skip rate limiting for health checks
        if request.url.path in ["/health", "/", "/docs", "/openapi.json"]:
            return await call_next(request)

        # Check rate limit
        current_time = time.time()

        if client_ip not in self.requests:
            self.requests[client_ip] = []

        # Remove old requests outside the time window
        self.requests[client_ip] = [
            req_time for req_time in self.requests[client_ip]
            if current_time - req_time < self.period
        ]

        # Check if rate limit exceeded
        if len(self.requests[client_ip]) >= self.calls:
            logger.warning(
                f"Rate limit exceeded for IP: {client_ip} | "
                f"Path: {request.url.path} | "
                f"Requests: {len(self.requests[client_ip])}/{self.calls}"
            )
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail=f"Rate limit exceeded. Maximum {self.calls} requests per {self.period} seconds."
            )

        # Record this request
        self.requests[client_ip].append(current_time)

        # Process request
        response = await call_next(request)

        # Add rate limit headers
        remaining = self.calls - len(self.requests[client_ip])
        response.headers["X-RateLimit-Limit"] = str(self.calls)
        response.headers["X-RateLimit-Remaining"] = str(max(0, remaining))
        response.headers["X-RateLimit-Reset"] = str(int(current_time + self.period))

        return response

    def cleanup_old_entries(self):
        """
        Cleanup old entries to prevent memory leaks.
        Should be called periodically.
        """
        current_time = time.time()
        for ip in list(self.requests.keys()):
            self.requests[ip] = [
                req_time for req_time in self.requests[ip]
                if current_time - req_time < self.period
            ]
            if not self.requests[ip]:
                del self.requests[ip]
