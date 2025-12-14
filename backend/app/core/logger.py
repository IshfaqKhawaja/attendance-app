"""
Logging configuration for the application.
"""
import logging
import sys
from pathlib import Path
from logging.handlers import RotatingFileHandler

from app.core.settings import settings


def setup_logging():
    """
    Configure application logging with file and console handlers.
    """
    # Get log level from settings
    log_level = getattr(logging, settings.LOG_LEVEL.upper(), logging.INFO)

    # Create formatters
    detailed_formatter = logging.Formatter(
        fmt='%(asctime)s - %(name)s - %(levelname)s - [%(filename)s:%(lineno)d] - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )

    simple_formatter = logging.Formatter(
        fmt='%(asctime)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )

    # Console handler (always available)
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(log_level)
    console_handler.setFormatter(simple_formatter if not settings.DEBUG else detailed_formatter)

    # Configure root logger
    root_logger = logging.getLogger()
    root_logger.setLevel(log_level)

    # Remove existing handlers to avoid duplicates
    root_logger.handlers.clear()

    # Add console handler first
    root_logger.addHandler(console_handler)

    # Try to add file handler (may fail due to permissions in Docker)
    try:
        # Create logs directory if it doesn't exist
        log_file = Path(settings.LOG_FILE)
        log_file.parent.mkdir(parents=True, exist_ok=True)

        # File handler with rotation
        file_handler = RotatingFileHandler(
            filename=settings.LOG_FILE,
            maxBytes=10 * 1024 * 1024,  # 10MB
            backupCount=5,
            encoding='utf-8'
        )
        file_handler.setLevel(log_level)
        file_handler.setFormatter(detailed_formatter)
        root_logger.addHandler(file_handler)

        file_logging_enabled = True
    except (PermissionError, OSError) as e:
        # If file logging fails, continue with console logging only
        logging.warning(f"File logging disabled due to permission error: {e}")
        logging.warning("Logs will only be written to console/stdout")
        file_logging_enabled = False

    # Set specific log levels for third-party libraries
    logging.getLogger("uvicorn").setLevel(logging.INFO)
    logging.getLogger("uvicorn.access").setLevel(logging.WARNING)
    logging.getLogger("fastapi").setLevel(logging.INFO)

    # Log startup message
    if file_logging_enabled:
        logging.info(f"Logging configured | Level: {settings.LOG_LEVEL} | File: {settings.LOG_FILE}")
    else:
        logging.info(f"Logging configured | Level: {settings.LOG_LEVEL} | Console only (file logging unavailable)")
    logging.info(f"Environment: {settings.ENVIRONMENT} | Debug: {settings.DEBUG}")
