# Database Initialization Testing Guide

## What Was Added

I've integrated automatic database initialization into your Docker setup. Here's what happens now:

### **On Container Startup:**
1. ✅ Waits for PostgreSQL to be ready
2. ✅ Checks if database is already initialized
3. ✅ Creates all required tables (if needed)
4. ✅ Creates `teacher_type` enum
5. ✅ Loads initial data from JSON files:
   - `json_data/faculty_data.json` → `faculty` table
   - `json_data/departments.json` → `department` table
   - `json_data/programs.json` → `program` table
6. ✅ Starts Gunicorn server

## Files Added/Modified

### **New Files:**
- `app/init_db.py` - Database initialization script
- `docker-entrypoint.sh` - Container startup script
- `DB_INIT_TESTING.md` - This file

### **Modified Files:**
- `Dockerfile` - Added entrypoint script

## Testing Instructions

### **Step 1: Clean Start (Recommended)**

Remove old containers and volumes:
```bash
cd /Users/Ishfaq/Coding/attendance-app/backend

# Stop and remove everything
docker compose down -v

# This removes:
# - All containers
# - The database volume (fresh start)
```

### **Step 2: Build and Start**

```bash
# Build with no cache to ensure fresh build
docker compose build --no-cache

# Start all services
docker compose up -d

# Or combine both:
docker compose up -d --build
```

### **Step 3: Watch the Initialization**

```bash
# Follow backend logs to see initialization
docker logs -f attendance-backend

# You should see output like:
# ==========================================
# Database Initialization Script
# ==========================================
# Waiting for database to be ready...
# Database is ready!
# Successfully connected to database.
# Creating database tables...
# Creating teacher_type enum...
# Executing statement 1/X...
# All tables created successfully.
# Inserting data into faculty from /app/json_data/faculty_data.json...
# Inserted X rows into faculty
# ...
# Database initialization completed successfully!
# ==========================================
# Starting Gunicorn server...
```

### **Step 4: Verify Database**

Connect to the database and check:
```bash
# Enter the postgres container
docker exec -it attendance-postgres psql -U myuser -d mydb

# Run these SQL commands:
\dt                           # List all tables
SELECT * FROM faculty;         # Check faculty data
SELECT * FROM department;      # Check department data
SELECT * FROM program;         # Check program data
\q                            # Exit
```

### **Step 5: Test the API**

```bash
# Health check
curl http://localhost/health

# Get faculties (should return the loaded data)
curl http://localhost/api/v1/faculties

# Get departments
curl http://localhost/api/v1/departments

# Get programs
curl http://localhost/api/v1/programs
```

## Behavior Details

### **First Run:**
- Creates all tables from scratch
- Loads all JSON data
- Takes ~10-30 seconds depending on data size

### **Subsequent Runs:**
- Detects existing data in `faculty` table
- Skips initialization: "Database already initialized. Skipping setup."
- Starts server immediately (~5 seconds)

### **After Volume Delete:**
- Behaves like first run
- Re-creates everything from scratch

## Troubleshooting

### **Issue: "Could not connect to database"**

Check if postgres is healthy:
```bash
docker ps
docker logs attendance-postgres
```

### **Issue: "Database initialization failed"**

Check backend logs for detailed error:
```bash
docker logs attendance-backend
```

Common causes:
- JSON files missing or malformed
- Database credentials incorrect
- Models.py has syntax errors

### **Issue: "JSON file does not exist"**

Verify JSON files are present:
```bash
docker exec attendance-backend ls -la /app/json_data/
```

### **Issue: Tables not created**

Manual check:
```bash
# Enter postgres container
docker exec -it attendance-postgres psql -U myuser -d mydb

# List tables
\dt

# If no tables, check backend logs for errors
```

### **Issue: Need to re-initialize**

Force re-initialization:
```bash
# Stop containers
docker compose down

# Remove database volume (destroys data!)
docker volume rm backend_postgres_data

# Start fresh
docker compose up -d
```

## Adding More Initial Data

To add more data on initialization:

1. Create JSON file in `json_data/` directory
2. Update `app/init_db.py` in the `main()` function:

```python
insert_json(
    conn,
    os.path.join(json_data_dir, "your_file.json"),
    "your_table",
    ["col1", "col2", "col3"]
)
```

3. Rebuild and restart:
```bash
docker compose down -v
docker compose up -d --build
```

## Logs Location

All logs are mounted to your local directory:
```bash
# Backend logs
tail -f logs/app.log

# Nginx access logs
tail -f logs/access.log

# Nginx error logs
tail -f logs/error.log
```

## Production Considerations

For production deployment:

1. ✅ The init script is **idempotent** (safe to run multiple times)
2. ✅ Skips initialization if data exists
3. ✅ Uses database connection from settings
4. ✅ Proper error handling and logging
5. ⚠️ Consider using proper migrations (Alembic) for schema changes

## Next Steps

After successful initialization, your database is ready with:
- All tables created
- Initial faculty, department, and program data loaded
- Ready to accept API requests

You can now:
- Create users via `/api/v1/users`
- Add teachers, students, courses
- Start tracking attendance
