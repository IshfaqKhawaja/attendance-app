#!/bin/bash
# Production deployment script for Attendance App Backend

set -e  # Exit on error

echo "========================================="
echo "Attendance App Backend - Deployment"
echo "========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo "Please create .env file from .env.example"
    echo "cp .env.example .env"
    exit 1
fi

# Check if webapp directory exists
if [ ! -d webapp ]; then
    echo -e "${YELLOW}Warning: webapp directory not found!${NC}"
    echo "Creating empty webapp directory..."
    mkdir -p webapp
    echo "To deploy the web app, build the Flutter app with:"
    echo "  cd ../app && flutter build web --release --dart-define=FLAVOR=production --base-href=/webapp/"
    echo "  cp -r build/web/* ../backend/webapp/"
fi

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running!${NC}"
    echo "Please start Docker and try again."
    exit 1
fi

# Load environment variables
source .env

echo -e "${GREEN}✓${NC} Environment variables loaded"

# Stop existing containers
echo -e "${YELLOW}Stopping existing containers...${NC}"
docker compose down || true

# Pull latest images
echo -e "${YELLOW}Pulling latest images...${NC}"
docker compose pull || true

# Build the application
echo -e "${YELLOW}Building application...${NC}"
docker compose build --no-cache

# Start services
echo -e "${YELLOW}Starting services...${NC}"
docker compose up -d

# Wait for services to be healthy
echo -e "${YELLOW}Waiting for services to be healthy...${NC}"
sleep 10

# Check health
echo -e "${YELLOW}Checking service health...${NC}"
if curl -f http://localhost/health > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Backend is healthy!"
else
    echo -e "${RED}✗${NC} Backend health check failed!"
    echo "Check logs with: docker compose logs backend"
    exit 1
fi

# Show running containers
echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Deployment successful!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Running containers:"
docker compose ps

echo ""
echo "Useful commands:"
echo "  - View logs: docker compose logs -f backend"
echo "  - Stop services: docker compose down"
echo "  - Restart: docker compose restart"
echo ""
echo "Access URLs:"
echo "  - Web App: http://localhost/webapp/"
echo "  - API: http://localhost/api/"
echo "  - API Docs: http://localhost/api/docs"
echo "  - Health: http://localhost/health"
echo ""
