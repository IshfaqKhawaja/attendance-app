#!/bin/bash
# Development startup script

set -e

echo "========================================="
echo "Starting Attendance App Backend (Dev)"
echo "========================================="

# Check if .env exists, if not copy from .env.development
if [ ! -f .env ]; then
    echo "Creating .env from .env.development..."
    cp .env.development .env
fi

# Create logs directory
mkdir -p logs

# Check if uv is installed
if command -v uv &> /dev/null; then
    echo "Using uv for faster dependency installation..."

    # Create virtual environment if it doesn't exist
    if [ ! -d ".venv" ]; then
        echo "Creating virtual environment with uv..."
        uv venv
    fi

    echo "Activating virtual environment..."
    source .venv/bin/activate

    echo "Installing dependencies with uv..."
    uv pip install fastapi uvicorn sqlalchemy psycopg psycopg2-binary pandas openpyxl pyjwt fpdf twilio pydantic pydantic-settings python-dotenv gunicorn python-multipart -q
else
    echo "uv not found, using pip..."

    # Create virtual environment if it doesn't exist
    if [ ! -d ".venv" ]; then
        echo "Creating virtual environment..."
        python -m venv .venv
    fi

    echo "Activating virtual environment..."
    source .venv/bin/activate

    echo "Installing dependencies..."
    pip install -q --upgrade pip
    pip install -q fastapi uvicorn sqlalchemy psycopg psycopg2-binary pandas openpyxl pyjwt fpdf twilio pydantic pydantic-settings python-dotenv gunicorn python-multipart
fi

# Unset DEBUG env var if it exists (can interfere with settings)
unset DEBUG

echo ""
echo "Starting development server..."
echo "API will be available at: http://localhost:8000"
echo "API docs at: http://localhost:8000/docs"
echo "Health check at: http://localhost:8000/health"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start the server with auto-reload
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
