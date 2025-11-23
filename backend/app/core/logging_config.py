"""
Logging configuration for the application.
Replace print() statements with proper logging using this configuration.
"""

import logging
import sys
from pathlib import Path
from logging.handlers import RotatingFileHandler, TimedRotatingFileHandler


def setup_logging(
    log_level: str = "INFO",
    log_file: str = "logs/app.log",
    enable_console: bool = True,
    enable_file: bool = True,
    max_bytes: int = 10 * 1024 * 1024,  # 10MB
    backup_count: int = 5,
):
    """
    Set up logging configuration for the application.

    Args:
        log_level: Logging level (DEBUG, INFO, WARNING, ERROR, CRITICAL)
        log_file: Path to log file
        enable_console: Enable console logging
        enable_file: Enable file logging
        max_bytes: Maximum size of each log file (default 10MB)
        backup_count: Number of backup log files to keep
    """

    # Create logs directory if it doesn't exist
    log_path = Path(log_file)
    log_path.parent.mkdir(parents=True, exist_ok=True)

    # Configure root logger
    logger = logging.getLogger()
    logger.setLevel(getattr(logging, log_level.upper()))

    # Remove existing handlers
    logger.handlers.clear()

    # Create formatters
    detailed_formatter = logging.Formatter(
        fmt='%(asctime)s - %(name)s - %(levelname)s - %(filename)s:%(lineno)d - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )

    simple_formatter = logging.Formatter(
        fmt='%(asctime)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )

    # Console handler
    if enable_console:
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setLevel(logging.INFO)
        console_handler.setFormatter(simple_formatter)
        logger.addHandler(console_handler)

    # File handler with rotation
    if enable_file:
        file_handler = RotatingFileHandler(
            filename=log_file,
            maxBytes=max_bytes,
            backupCount=backup_count,
            encoding='utf-8'
        )
        file_handler.setLevel(logging.DEBUG)
        file_handler.setFormatter(detailed_formatter)
        logger.addHandler(file_handler)

    # Error file handler (separate file for errors)
    error_log_file = str(log_path.parent / "error.log")
    error_handler = RotatingFileHandler(
        filename=error_log_file,
        maxBytes=max_bytes,
        backupCount=backup_count,
        encoding='utf-8'
    )
    error_handler.setLevel(logging.ERROR)
    error_handler.setFormatter(detailed_formatter)
    logger.addHandler(error_handler)

    # Set logging level for third-party libraries
    logging.getLogger('uvicorn').setLevel(logging.WARNING)
    logging.getLogger('fastapi').setLevel(logging.WARNING)
    logging.getLogger('sqlalchemy').setLevel(logging.WARNING)

    logger.info(f"Logging initialized - Level: {log_level}, File: {log_file}")

    return logger


def get_logger(name: str) -> logging.Logger:
    """
    Get a logger instance for a specific module.

    Usage:
        from app.core.logging_config import get_logger
        logger = get_logger(__name__)
        logger.info("This is an info message")
        logger.error("This is an error message")

    Args:
        name: Name of the logger (typically __name__)

    Returns:
        Logger instance
    """
    return logging.getLogger(name)


# Example usage in other files:
"""
# At the top of your file:
from app.core.logging_config import get_logger
logger = get_logger(__name__)

# Instead of print():
print("Debug message")  # ❌ Don't do this

# Use:
logger.debug("Debug message")  # ✓ For debug information
logger.info("Info message")    # ✓ For general information
logger.warning("Warning")      # ✓ For warnings
logger.error("Error", exc_info=True)  # ✓ For errors with stack trace
logger.critical("Critical")    # ✓ For critical errors

# Example in exception handling:
try:
    result = some_operation()
    logger.info(f"Operation completed successfully: {result}")
except Exception as e:
    logger.error(f"Operation failed: {str(e)}", exc_info=True)
    raise
"""
