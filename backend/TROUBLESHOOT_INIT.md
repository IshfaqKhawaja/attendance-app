# Troubleshooting Database Initialization

## Issue: init_db.py not running on server, no data inserted

### Step 1: Check Backend Container Logs

```bash
# SSH to server
ssh root@172.105.41.86

# Check if backend container is running
docker ps | grep backend

# View full backend logs
docker logs attendance-backend

# Look specifically for initialization output
docker logs attendance-backend | grep -i "database initialization"
docker logs attendance-backend | grep -i "creating initial users"
docker logs attendance-backend | grep -i "inserting data"
```

**Expected output should show:**
```
==========================================
Database Initialization Script
==========================================
Waiting for database to be ready...
Database is ready!
Successfully connected to database.
Initializing database for the first time...
Creating database tables...
...
Inserting data into faculty from /app/json_data/faculty_data.json...
...
Creating initial users...
...
==========================================
Starting Gunicorn server...
```

### Step 2: Check if Entrypoint Script is Running

```bash
# Check if entrypoint script exists in container
docker exec attendance-backend ls -la /app/docker-entrypoint.sh

# Check if entrypoint is executable
docker exec attendance-backend stat /app/docker-entrypoint.sh

# View entrypoint script content
docker exec attendance-backend cat /app/docker-entrypoint.sh
```

### Step 3: Check if init_db.py Exists in Container

```bash
# Check if init_db.py exists
docker exec attendance-backend ls -la /app/app/init_db.py

# Check if it's readable
docker exec attendance-backend cat /app/app/init_db.py | head -20
```

### Step 4: Check JSON Data Files in Container

```bash
# Check if json_data directory exists
docker exec attendance-backend ls -la /app/json_data/

# Verify files exist and have content
docker exec attendance-backend wc -l /app/json_data/*.json

# Check first few lines of faculty data
docker exec attendance-backend head -10 /app/json_data/faculty_data.json
```

### Step 5: Manually Run init_db.py (for testing)

```bash
# Enter the container
docker exec -it attendance-backend bash

# Inside container, try running init_db manually
cd /app
python -m app.init_db

# Check for any errors
# Exit container
exit
```

### Step 6: Check Database Connection

```bash
# Check if postgres is accessible from backend
docker exec attendance-backend ping -c 3 postgres

# Check if database exists
docker exec -it attendance-postgres psql -U myuser -d mydb -c "\dt"

# Check if tables exist
docker exec -it attendance-postgres psql -U myuser -d mydb -c "SELECT table_name FROM information_schema.tables WHERE table_schema='public';"
```

### Step 7: Check Entrypoint is Actually Running

```bash
# Check what process started the backend container
docker inspect attendance-backend | grep -A 10 "Entrypoint"
docker inspect attendance-backend | grep -A 10 "Cmd"

# Check running processes in container
docker exec attendance-backend ps aux
```

## Common Issues and Fixes

### Issue 1: Entrypoint not executable
**Symptoms:** Container starts but no initialization logs
**Fix:**
```bash
# On local machine, check file permissions
ls -la backend/docker-entrypoint.sh

# Should show: -rwxr-xr-x (executable)
# If not:
chmod +x backend/docker-entrypoint.sh

# Rebuild
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Issue 2: init_db.py has import errors
**Symptoms:** Container crashes or initialization fails
**Fix:**
```bash
# Check logs for Python errors
docker logs attendance-backend 2>&1 | grep -i "error\|exception\|traceback"

# Common issues:
# - Missing psycopg2: Check if it's in requirements
# - Import path wrong: Should be "from app.core.settings import settings"
```

### Issue 3: Database not ready in time
**Symptoms:** "Could not connect to database" error
**Fix:**
```bash
# Increase wait time in init_db.py
# Or check if postgres is actually running
docker ps | grep postgres
docker logs attendance-postgres
```

### Issue 4: JSON files missing or empty
**Symptoms:** "File does not exist" or "No data in file"
**Fix:**
```bash
# Verify files exist on server
ls -la ~/attendance-app/backend/json_data/

# If missing, copy from local:
scp -r /Users/Ishfaq/Coding/attendance-app/backend/json_data root@172.105.41.86:~/attendance-app/backend/

# Rebuild container
docker compose down
docker compose up -d --build
```

### Issue 5: Entrypoint script has Windows line endings
**Symptoms:** Container fails with "/bin/sh^M: bad interpreter" or similar
**Fix:**
```bash
# On local machine
dos2unix backend/docker-entrypoint.sh
# Or
sed -i 's/\r$//' backend/docker-entrypoint.sh

# Rebuild
docker compose build --no-cache
docker compose up -d
```

### Issue 6: Container starts but init never runs
**Symptoms:** Gunicorn starts immediately, no init logs
**Fix:**
Check Dockerfile ENTRYPOINT and CMD:
```dockerfile
# Should have:
ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["gunicorn", "app.main:app", ...]

# NOT:
CMD ["gunicorn", "app.main:app", ...]  # Without ENTRYPOINT
```

## Quick Debug Commands

```bash
# 1. Check container status
docker ps -a

# 2. Check recent logs (last 100 lines)
docker logs --tail 100 attendance-backend

# 3. Check if postgres is healthy
docker inspect attendance-postgres | grep -i health

# 4. Check if backend can reach postgres
docker exec attendance-backend nc -zv postgres 5432

# 5. Check environment variables in container
docker exec attendance-backend env | grep DB_

# 6. Force re-initialization (DESTROYS DATA!)
docker compose down -v
docker compose build --no-cache
docker compose up -d
docker logs -f attendance-backend
```

## Manual Initialization (Last Resort)

If automatic initialization keeps failing, initialize manually:

```bash
# 1. Enter backend container
docker exec -it attendance-backend bash

# 2. Run init script manually
cd /app
python -m app.init_db

# 3. Check for errors, then exit
exit

# 4. Restart backend container
docker restart attendance-backend
```

Or initialize directly in database:

```bash
# Enter postgres container
docker exec -it attendance-postgres psql -U myuser -d mydb

-- Run table creation SQL
-- (Copy from app/db/models.py statements)

-- Insert data manually
\COPY faculty FROM '/path/to/faculty_data.csv' DELIMITER ',' CSV HEADER;

-- Exit
\q
```
