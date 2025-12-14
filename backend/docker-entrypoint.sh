#!/bin/bash
set -e

echo "=========================================="
echo "Attendance App Backend - Starting Up"
echo "=========================================="

# Run database initialization
echo "Running database initialization..."
python -m app.init_db

# Check if initialization was successful
if [ $? -eq 0 ]; then
    echo "Database initialization completed successfully"
else
    echo "Database initialization failed"
    exit 1
fi

echo "=========================================="
echo "Starting Gunicorn server..."
echo "=========================================="

# Execute the main command (Gunicorn)
exec "$@"
