#!/bin/bash
# =====================================================
# Attendance Management System - Docker Setup Script
# =====================================================
# This script sets up and starts the PostgreSQL database
# with Docker and initializes the database schema
# =====================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Print colored message
print_message() {
    echo -e "${GREEN}[SETUP]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if Docker is running
if ! docker info &> /dev/null; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi

print_message "Docker is installed and running"

# Check if .env file exists
if [ ! -f .env ]; then
    print_warning ".env file not found. Creating from example..."
    if [ -f .env.example ]; then
        cp .env.example .env
        print_message ".env file created. Please update it with your configuration."
    else
        print_warning "No .env.example found. You'll need to create .env manually."
    fi
fi

# Load environment variables
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Set defaults if not in .env
export DB_USER=${DB_USER:-myuser}
export DB_PASSWORD=${DB_PASSWORD:-mypassword}
export DB_NAME=${DB_NAME:-mydb}
export DB_PORT=${DB_PORT:-5432}

print_message "Using database configuration:"
echo "  - User: $DB_USER"
echo "  - Database: $DB_NAME"
echo "  - Port: $DB_PORT"

# Stop existing containers
print_message "Stopping existing containers..."
docker-compose down -v 2>/dev/null || true

# Start PostgreSQL and Redis
print_message "Starting PostgreSQL and Redis containers..."
docker-compose up -d postgres redis

# Wait for PostgreSQL to be ready
print_message "Waiting for PostgreSQL to be ready..."
max_attempts=30
attempt=0

while [ $attempt -lt $max_attempts ]; do
    if docker exec attendance-postgres pg_isready -U $DB_USER -d $DB_NAME > /dev/null 2>&1; then
        print_message "PostgreSQL is ready!"
        break
    fi
    attempt=$((attempt + 1))
    echo "  Attempt $attempt/$max_attempts..."
    sleep 2
done

if [ $attempt -eq $max_attempts ]; then
    print_error "PostgreSQL failed to start within the expected time"
    exit 1
fi

# The init scripts in init-db/ folder will be automatically executed by PostgreSQL
print_message "Database initialization scripts will run automatically..."
sleep 5

# Verify database setup
print_message "Verifying database setup..."
if docker exec attendance-postgres psql -U $DB_USER -d $DB_NAME -c "\dt" > /dev/null 2>&1; then
    print_message "Database tables verified!"
    echo ""
    docker exec attendance-postgres psql -U $DB_USER -d $DB_NAME -c "\dt" | head -20
else
    print_error "Failed to verify database tables"
    exit 1
fi

print_message "================================"
print_message "Setup completed successfully!"
print_message "================================"
echo ""
echo "Database connection details:"
echo "  Host: localhost"
echo "  Port: $DB_PORT"
echo "  Database: $DB_NAME"
echo "  User: $DB_USER"
echo ""
echo "To start the backend API:"
echo "  docker-compose up backend"
echo ""
echo "To start all services:"
echo "  docker-compose up"
echo ""
echo "To stop all services:"
echo "  docker-compose down"
echo ""
echo "To view logs:"
echo "  docker-compose logs -f"
echo ""
