"""
FastAPI main application entry point.
Includes all routers, middleware, and startup configuration.
"""
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI #type: ignore
from fastapi.middleware.cors import CORSMiddleware #type: ignore

# Import settings and logging
from app.core.settings import settings
from app.core.logger import setup_logging

# Import middleware
from app.middleware.logging_middleware import RequestLoggingMiddleware
from app.middleware.rate_limit import RateLimitMiddleware
from app.middleware.auth_middleware import JWTAuthMiddleware

# Import API Routers
from app.api.v1.faculty_router import router as faculty_route
from app.api.v1.department_router import router as department_router
from app.api.v1.program_router import router as program_router
from app.api.v1.semester_router import router as semester_router
from app.api.v1.teacher_router import router as teacher_router
from app.api.v1.course_router import router as course_router
from app.api.v1.student_router import router as student_router
from app.api.v1.attendence_router import router as attendence_router
from app.api.v1.authenticate_router import router as authenticate_router
from app.api.v1.initial_router import router as initial_router
from app.api.v1.teacher_course_router import router as teacher_course_router
from app.api.v1.course_students_router import router as course_student_router
from app.api.v1.attendance_notifier_router import router as attendance_notifier_router
from app.api.v1.user_router import router as user_router
from app.api.v1.report_router import router as report_router
from app.api.v1.student_enrolement_router import router as student_enrolement_router

# Setup logging
setup_logging()
logger = logging.getLogger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Application lifespan events.
    Handles startup and shutdown events.
    """
    # Startup
    logger.info(f"Starting {settings.APP_NAME} v{settings.APP_VERSION}")
    logger.info(f"Environment: {settings.ENVIRONMENT}")
    logger.info(f"Debug mode: {settings.DEBUG}")
    yield
    # Shutdown
    logger.info(f"Shutting down {settings.APP_NAME}")


# Create FastAPI application
app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Backend API for Attendance Management System",
    debug=settings.DEBUG,
    lifespan=lifespan,
)

# Add CORS middleware with configured origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins_list,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH"],
    allow_headers=["*"],
)

# Add rate limiting middleware
app.add_middleware(RateLimitMiddleware)

# Add JWT authentication middleware
# IMPORTANT: Uncomment this line to enable JWT token validation on all protected routes
# app.add_middleware(JWTAuthMiddleware)

# Add request logging middleware
app.add_middleware(RequestLoggingMiddleware)


# Health check endpoint
@app.get("/health", tags=["Health"])
def health_check():
    """
    Health check endpoint for monitoring and load balancers.
    """
    return {
        "status": "healthy",
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "environment": settings.ENVIRONMENT
    }


@app.get("/", tags=["Root"])
def home():
    """Root endpoint with welcome message."""
    return {
        "message": f"Welcome to {settings.APP_NAME}",
        "version": settings.APP_VERSION,
        "docs": "/docs",
        "health": "/health"
    }


# Include API routers
# Initial Router (setup/initialization)
app.include_router(initial_router)

# Authenticate Routes
app.include_router(authenticate_router)

# Faculty Related Routes
app.include_router(faculty_route)

# Department Related Routes
app.include_router(department_router)

# Program Related Routes
app.include_router(program_router)

# Semester Router
app.include_router(semester_router)

# Teacher Router
app.include_router(teacher_router)

# Course Router
app.include_router(course_router)

# Teacher Course Router
app.include_router(teacher_course_router)

# Course Student Router
app.include_router(course_student_router)

# Student Router
app.include_router(student_router)

# Attendance Router
app.include_router(attendence_router)

# Attendance Notifier Router
app.include_router(attendance_notifier_router)

# User Router
app.include_router(user_router)

# Report Router
app.include_router(report_router)

# Student Enrollment Router
app.include_router(student_enrolement_router)


logger.info("Application initialized successfully")
