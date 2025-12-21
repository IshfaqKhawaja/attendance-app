#!/bin/bash
# Production deployment script for Attendance App Backend
# Run this script on the server to deploy the latest changes

set -e  # Exit on error

echo "========================================="
echo "Attendance App Backend - Deployment"
echo "========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo -e "${BLUE}Working directory: $SCRIPT_DIR${NC}"

# Step 1: Pull latest code from git
echo ""
echo -e "${YELLOW}Step 1: Pulling latest code from git...${NC}"
if git pull origin main; then
    echo -e "${GREEN}✓${NC} Git pull successful"
else
    echo -e "${YELLOW}!${NC} Git pull failed. Continuing with existing code..."
fi

# Step 2: Check if .env file exists
echo ""
echo -e "${YELLOW}Step 2: Checking environment configuration...${NC}"
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo "Please create .env file from .env.example"
    echo "  cp .env.example .env"
    echo "  nano .env  # Edit with your values"
    exit 1
fi
echo -e "${GREEN}✓${NC} Environment file found"

# Step 3: Check webapp directory
echo ""
echo -e "${YELLOW}Step 3: Checking webapp directory...${NC}"
if [ ! -d webapp ]; then
    echo -e "${YELLOW}Warning: webapp directory not found!${NC}"
    echo "Creating empty webapp directory..."
    mkdir -p webapp
    echo "To deploy the web app, build the Flutter app locally with:"
    echo "  cd ../app && flutter build web --release --base-href=/webapp/"
    echo "  cp -r build/web/* ../backend/webapp/"
    echo "Then commit and push the webapp folder, or copy files manually."
elif [ ! -f webapp/index.html ]; then
    echo -e "${YELLOW}Warning: webapp/index.html not found!${NC}"
    echo "The webapp directory exists but appears empty."
    echo "Make sure to build and copy the Flutter web app."
else
    echo -e "${GREEN}✓${NC} Webapp directory found with index.html"
fi

# Step 4: Check if Docker is running
echo ""
echo -e "${YELLOW}Step 4: Checking Docker...${NC}"
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not running!${NC}"
    echo "Please start Docker and try again."
    echo "  sudo systemctl start docker"
    exit 1
fi
echo -e "${GREEN}✓${NC} Docker is running"

# Step 5: Load environment variables
echo ""
echo -e "${YELLOW}Step 5: Loading environment variables...${NC}"
set -a
source .env
set +a
echo -e "${GREEN}✓${NC} Environment variables loaded"

# Step 6: Stop existing containers
echo ""
echo -e "${YELLOW}Step 6: Stopping existing containers...${NC}"
docker compose down || true
echo -e "${GREEN}✓${NC} Containers stopped"

# Step 7: Build the application
echo ""
echo -e "${YELLOW}Step 7: Building application (this may take a while)...${NC}"
docker compose build --no-cache
echo -e "${GREEN}✓${NC} Build complete"

# Step 8: Start services
echo ""
echo -e "${YELLOW}Step 8: Starting services...${NC}"
docker compose up -d
echo -e "${GREEN}✓${NC} Services started"

# Step 9: Wait for services to be healthy
echo ""
echo -e "${YELLOW}Step 9: Waiting for services to be healthy...${NC}"
echo "Waiting 15 seconds for containers to initialize..."
sleep 15

# Check container status
echo ""
echo "Container status:"
docker compose ps

# Step 10: Check health
echo ""
echo -e "${YELLOW}Step 10: Checking service health...${NC}"

# Check backend health through nginx
MAX_RETRIES=5
RETRY_COUNT=0
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -sf http://localhost/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} Backend is healthy!"
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo "Health check failed, retrying in 5 seconds... ($RETRY_COUNT/$MAX_RETRIES)"
            sleep 5
        else
            echo -e "${RED}✗${NC} Backend health check failed after $MAX_RETRIES attempts!"
            echo ""
            echo "Checking container logs..."
            echo "--- Backend Logs ---"
            docker compose logs --tail=30 backend
            echo ""
            echo "--- Nginx Logs ---"
            docker compose logs --tail=10 nginx
            exit 1
        fi
    fi
done

# Check webapp
echo ""
echo -e "${YELLOW}Checking webapp accessibility...${NC}"
if curl -sf http://localhost/webapp/ > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Webapp is accessible!"
else
    echo -e "${YELLOW}!${NC} Webapp not accessible (may be empty or not built)"
fi

# Step 11: Run database migrations
echo ""
echo -e "${YELLOW}Step 11: Running database migrations...${NC}"

# Add DEAN role to user_type enum if it doesn't exist
echo "Adding DEAN role to user_type enum..."
docker exec attendance-postgres psql -U myuser -d mydb -c "ALTER TYPE user_type ADD VALUE IF NOT EXISTS 'DEAN' AFTER 'HOD';" 2>/dev/null || echo "  - DEAN role already exists or enum update skipped"

# Insert Dean user if not exists
echo "Creating Dean user..."
docker exec attendance-postgres psql -U myuser -d mydb -c "INSERT INTO users (user_id, user_name, type, dept_id, fact_id) VALUES ('dean@test.com', 'Faculty of Engineering Dean', 'DEAN', NULL, 'F006') ON CONFLICT (user_id) DO NOTHING;" 2>/dev/null && echo -e "${GREEN}✓${NC} Dean user created/verified" || echo -e "${YELLOW}!${NC} Could not create Dean user (may already exist)"

echo -e "${GREEN}✓${NC} Database migrations complete"

# Get server IP
SERVER_IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "localhost")

# Show success message
echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}   Deployment successful!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo "Running containers:"
docker compose ps
echo ""
echo -e "${BLUE}Access URLs:${NC}"
echo "  - Web App:  http://${SERVER_IP}/webapp/"
echo "  - API:      http://${SERVER_IP}/api/"
echo "  - API Docs: http://${SERVER_IP}/api/docs"
echo "  - Health:   http://${SERVER_IP}/health"
echo ""
echo -e "${BLUE}Useful commands:${NC}"
echo "  - View logs:     docker compose logs -f"
echo "  - Backend logs:  docker compose logs -f backend"
echo "  - Stop services: docker compose down"
echo "  - Restart:       docker compose restart"
echo "  - Shell access:  docker compose exec backend /bin/sh"
echo ""
