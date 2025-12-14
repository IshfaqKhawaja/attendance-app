#!/bin/bash
# Script to deploy JSON data files to server and rebuild containers

set -e

# Configuration
SERVER_USER="root"
SERVER_IP="172.105.41.86"
SERVER_PATH="~/attendance-app/backend"

echo "=========================================="
echo "Deploying JSON Data to Server"
echo "=========================================="

# Check if json_data directory exists
if [ ! -d "json_data" ]; then
    echo "ERROR: json_data directory not found!"
    echo "Please run this script from the backend directory"
    exit 1
fi

# Count files
FACULTY_COUNT=$(jq 'length' json_data/faculty_data.json)
DEPT_COUNT=$(jq 'length' json_data/departments.json)
PROG_COUNT=$(jq 'length' json_data/programs.json 2>/dev/null || echo "0")

echo "Local JSON data files:"
echo "  - Faculties: $FACULTY_COUNT"
echo "  - Departments: $DEPT_COUNT"
echo "  - Programs: $PROG_COUNT"
echo ""

# Verify F006 and D028 exist
if grep -q "F006" json_data/faculty_data.json && grep -q "D028" json_data/departments.json; then
    echo "✓ Verified: F006 (Faculty of Engineering) exists"
    echo "✓ Verified: D028 (Computer Engineering) exists"
else
    echo "⚠ WARNING: F006 or D028 not found in JSON files"
fi
echo ""

# Ask for confirmation
read -p "Deploy these files to $SERVER_IP? (y/N): " confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    echo "Deployment cancelled."
    exit 0
fi

echo ""
echo "Step 1: Backing up existing JSON data on server..."
ssh $SERVER_USER@$SERVER_IP "cd $SERVER_PATH && [ -d json_data ] && tar -czf json_data_backup_\$(date +%Y%m%d_%H%M%S).tar.gz json_data/ || true"

echo "Step 2: Copying new JSON data files to server..."
scp -r json_data/ $SERVER_USER@$SERVER_IP:$SERVER_PATH/

echo "Step 3: Verifying files on server..."
ssh $SERVER_USER@$SERVER_IP "ls -lh $SERVER_PATH/json_data/"

echo ""
echo "Step 4: Rebuilding containers with new data..."
read -p "This will DESTROY existing database data. Continue? (y/N): " confirm_rebuild
if [ "$confirm_rebuild" != "y" ] && [ "$confirm_rebuild" != "Y" ]; then
    echo "Rebuild cancelled. JSON files deployed but containers not rebuilt."
    echo "Run manually on server: docker compose down -v && docker compose up -d --build"
    exit 0
fi

ssh $SERVER_USER@$SERVER_IP << 'ENDSSH'
cd ~/attendance-app/backend
echo "Stopping containers and removing volumes..."
docker compose down -v
echo "Rebuilding and starting containers..."
docker compose up -d --build
echo "Waiting for services to be healthy..."
sleep 10
docker compose ps
ENDSSH

echo ""
echo "Step 5: Checking initialization logs..."
ssh $SERVER_USER@$SERVER_IP "docker logs attendance-backend | tail -50"

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Verify deployment:"
echo "  1. Check users: curl http://$SERVER_IP/api/v1/users"
echo "  2. Check faculties: curl http://$SERVER_IP/api/v1/faculties"
echo "  3. SSH and verify: ssh $SERVER_USER@$SERVER_IP"
echo "     docker exec -it attendance-postgres psql -U myuser -d mydb -c \"SELECT * FROM users;\""
