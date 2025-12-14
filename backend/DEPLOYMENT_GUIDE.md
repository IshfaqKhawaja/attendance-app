# Server Deployment & Data Loading Guide

## Current Issue

Your server has **different data** than your local `json_data/` folder:

### Server Data (Current):
```
Faculty:
- FACT001: Faculty of Engineering
- FACT002: Faculty of Sciences

Departments:
- DEPT001: Computer Science (FACT001)
- DEPT002: Electrical Engineering (FACT001)
- DEPT003: Mathematics (FACT002)
```

### Local JSON Data:
Your `json_data/` folder has the **full university data** with:
- 13 Faculties (F001-F013)
- 68 Departments (D000-D068)
- Programs for each department

## Solution: Deploy the Full Data

### Step 1: Verify JSON Files Exist on Server

SSH into your server and check:

```bash
ssh user@172.105.41.86
cd ~/attendance-app/backend

# Check if json_data directory exists and has files
ls -la json_data/

# Should show:
# faculty_data.json
# departments.json
# programs.json

# Check file contents
head -20 json_data/faculty_data.json
head -20 json_data/departments.json
```

### Step 2: Backup Current Data (Optional)

If you want to keep the test data:

```bash
# On server
docker exec -it attendance-postgres pg_dump -U myuser -d mydb > backup_$(date +%Y%m%d).sql
```

### Step 3: Reset and Reload with Full Data

```bash
# On server
cd ~/attendance-app/backend

# Stop and remove containers + volumes (DESTROYS ALL DATA!)
docker compose down -v

# Pull latest code (if using git)
git pull origin main

# Verify json_data files are correct
cat json_data/faculty_data.json | head -20

# Rebuild and start
docker compose up -d --build

# Watch initialization logs
docker logs -f attendance-backend
```

### Step 4: Verify Data Loaded

```bash
# Check faculties
docker exec -it attendance-postgres psql -U myuser -d mydb -c "SELECT COUNT(*) FROM faculty;"
# Should show: 13 rows (or your actual count)

# Check departments
docker exec -it attendance-postgres psql -U myuser -d mydb -c "SELECT COUNT(*) FROM department;"
# Should show: 68+ rows

# Check programs
docker exec -it attendance-postgres psql -U myuser -d mydb -c "SELECT COUNT(*) FROM program;"

# Check users
docker exec -it attendance-postgres psql -U myuser -d mydb -c "SELECT * FROM users;"
# Should show:
#   cs@test.com (HOD for Computer department)
#   superadmin@test.com (SUPER_ADMIN)
```

### Step 5: Verify Users Were Created Correctly

```bash
# Check backend logs for user creation
docker logs attendance-backend | grep -A 10 "Creating initial users"

# Should show something like:
# Creating initial users...
# Available faculties: [('F006', 'Faculty of Engineering & Technology'), ...]
# Available departments: [('D028', 'Department of Computer Engineering', 'F006'), ...]
# Found Computer department: Department of Computer Engineering (D028) in faculty F006
#   ✓ Created user: Computer Engineering HOD (cs@test.com) as HOD
#     - Assigned to: Department D028, Faculty F006
#   ✓ Created user: Super Admin (superadmin@test.com) as SUPER_ADMIN
# Initial users setup complete. Created 2 new user(s).
```

## Understanding the Issue

The init script now **intelligently finds** the Computer Science/Engineering department:

1. Queries the database for departments with "computer" in the name
2. Assigns `cs@test.com` to that department
3. Falls back to first department if no Computer dept found
4. Creates `superadmin@test.com` with no department (full access)

## If JSON Files Don't Exist on Server

If `json_data/` is missing on the server, you need to copy them:

### Option 1: Copy from Local Machine

```bash
# From your local machine
scp -r /Users/Ishfaq/Coding/attendance-app/backend/json_data user@172.105.41.86:~/attendance-app/backend/
```

### Option 2: Use Git

```bash
# Make sure json_data is NOT in .gitignore
# On local machine
cd /Users/Ishfaq/Coding/attendance-app/backend
git status json_data/

# If it's ignored, remove from .gitignore
# Then commit and push
git add json_data/
git commit -m "Add initial JSON data files"
git push origin main

# On server
git pull origin main
```

### Option 3: Create Minimal Test Data

If you want to start with minimal data for testing:

Create these files on the server:

**json_data/faculty_data.json**:
```json
[
  {"fact_id": "F006", "fact_name": "Faculty of Engineering & Technology"},
  {"fact_id": "F003", "fact_name": "Faculty of Sciences"}
]
```

**json_data/departments.json**:
```json
[
  {"dept_id": "D028", "dept_name": "Department of Computer Engineering", "fact_id": "F006"},
  {"dept_id": "D018", "dept_name": "Department of Computer Science", "fact_id": "F003"}
]
```

**json_data/programs.json**:
```json
[
  {"prog_id": "P001", "prog_name": "B.Tech Computer Engineering", "dept_id": "D028"},
  {"prog_id": "P002", "prog_name": "M.Tech Computer Engineering", "dept_id": "D028"}
]
```

## Checking What Data is Currently Loaded

```bash
# On server
docker exec -it attendance-postgres psql -U myuser -d mydb

# Then run these queries:

-- See all faculties
SELECT * FROM faculty;

-- See all departments
SELECT * FROM department ORDER BY dept_id;

-- Find Computer departments
SELECT * FROM department WHERE dept_name ILIKE '%computer%';

-- See all users
SELECT * FROM users;

-- Exit
\q
```

## Manual User Creation (If Needed)

If initialization didn't create users, you can create them manually:

```bash
docker exec -it attendance-postgres psql -U myuser -d mydb

-- Create Super Admin
INSERT INTO users (user_id, user_name, type, dept_id, fact_id)
VALUES ('superadmin@test.com', 'Super Admin', 'SUPER_ADMIN', NULL, NULL);

-- Create HOD for Computer Engineering (adjust IDs to match your data)
INSERT INTO users (user_id, user_name, type, dept_id, fact_id)
VALUES ('cs@test.com', 'Computer Engineering HOD', 'HOD', 'DEPT001', 'FACT001');

-- Verify
SELECT * FROM users;
```

## Testing After Deployment

```bash
# Test health
curl http://172.105.41.86/health

# Test users API
curl http://172.105.41.86/api/v1/users

# Test specific user
curl http://172.105.41.86/api/v1/users/cs@test.com
curl http://172.105.41.86/api/v1/users/superadmin@test.com

# Test faculties
curl http://172.105.41.86/api/v1/faculties

# Test departments
curl http://172.105.41.86/api/v1/departments
```

## Quick Deployment Checklist

- [ ] SSH into server: `ssh user@172.105.41.86`
- [ ] Navigate to backend: `cd ~/attendance-app/backend`
- [ ] Verify JSON files exist: `ls json_data/`
- [ ] Stop containers: `docker compose down -v`
- [ ] Start with rebuild: `docker compose up -d --build`
- [ ] Check logs: `docker logs -f attendance-backend`
- [ ] Verify data: Run SQL queries above
- [ ] Test API: `curl http://172.105.41.86/health`
- [ ] Check users: `curl http://172.105.41.86/api/v1/users`

## Summary

The updated `init_db.py` now:
✅ Works with any faculty/department IDs
✅ Automatically finds Computer department
✅ Creates users with correct associations
✅ Logs what IDs it found and used
✅ Falls back gracefully if data is missing

Just redeploy on your server and the users will be created correctly!
