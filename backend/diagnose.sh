#!/bin/bash
# Quick diagnostic script to check why init_db.py isn't running

echo "=========================================="
echo "Database Initialization Diagnostics"
echo "=========================================="
echo ""

echo "1. Checking backend container status..."
docker ps -a | grep backend
echo ""

echo "2. Checking backend logs for initialization..."
echo "--- Last 50 lines of backend logs ---"
docker logs --tail 50 attendance-backend
echo ""

echo "3. Checking if entrypoint script exists..."
docker exec attendance-backend ls -la /app/docker-entrypoint.sh 2>&1 || echo "ENTRYPOINT NOT FOUND!"
echo ""

echo "4. Checking if init_db.py exists..."
docker exec attendance-backend ls -la /app/app/init_db.py 2>&1 || echo "INIT_DB.PY NOT FOUND!"
echo ""

echo "5. Checking json_data directory..."
docker exec attendance-backend ls -la /app/json_data/ 2>&1 || echo "JSON_DATA DIRECTORY NOT FOUND!"
echo ""

echo "6. Checking database tables..."
docker exec -it attendance-postgres psql -U myuser -d mydb -c "\dt" 2>&1
echo ""

echo "7. Checking if postgres is accessible from backend..."
docker exec attendance-backend nc -zv postgres 5432 2>&1
echo ""

echo "8. Checking environment variables..."
docker exec attendance-backend env | grep -E "DB_|REDIS_"
echo ""

echo "=========================================="
echo "Manual Test: Running init_db.py"
echo "=========================================="
echo "Attempting to run init_db manually..."
docker exec attendance-backend python -m app.init_db 2>&1
echo ""

echo "=========================================="
echo "Diagnosis Complete"
echo "=========================================="
