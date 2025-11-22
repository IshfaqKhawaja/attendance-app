"""
Database connection parameters.
Now loaded from settings instead of hardcoded values.
"""
from app.core.settings import settings

conn_params = {
    "host":     settings.DB_HOST,
    "port":     settings.DB_PORT,
    "dbname":   settings.DB_NAME,
    "user":     settings.DB_USER,
    "password": settings.DB_PASSWORD,
}