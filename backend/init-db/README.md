# Database Initialization Scripts

This folder contains SQL scripts that are automatically executed when the PostgreSQL Docker container starts for the first time.

## How it works

When you run `docker-compose up` or `./setup.sh`, PostgreSQL will automatically execute all `.sql` and `.sh` files in this directory in alphabetical order.

## Files

### 01_init_schema.sql
- Creates all database tables with proper relationships
- Creates enum types (teacher_type, user_type)
- Creates indexes for better query performance
- **Always executed**: This file uses `CREATE TABLE IF NOT EXISTS` so it's safe to run multiple times

### 02_seed_data.sql
- Inserts sample/initial data for testing
- Includes sample faculties, departments, programs, semesters, teachers, students, courses, and users
- **Optional**: You can delete or comment out this file if you don't want sample data in production

## Usage

### For Development
Keep both files to get a fully populated database for testing.

### For Production
1. Keep `01_init_schema.sql` - Required for table creation
2. **Delete or rename** `02_seed_data.sql` if you don't want sample data
3. Or create your own production data script

## Adding Custom Scripts

You can add more initialization scripts by creating new `.sql` files with a numeric prefix:
- `03_custom_data.sql`
- `04_additional_setup.sql`
- etc.

Scripts are executed in alphabetical order.

## Notes

- All scripts use `IF NOT EXISTS` or `ON CONFLICT` clauses to be idempotent
- Scripts will only run on the first container startup (when the data volume is empty)
- To re-run scripts, you need to delete the Docker volume: `docker-compose down -v`
- All timestamps use `CURRENT_TIMESTAMP` in UTC

## Manual Execution

If you need to run these scripts manually:

```bash
# From the backend directory
docker exec -i attendance-postgres psql -U myuser -d mydb < init-db/01_init_schema.sql
docker exec -i attendance-postgres psql -U myuser -d mydb < init-db/02_seed_data.sql
```

Or connect to the database directly:

```bash
docker exec -it attendance-postgres psql -U myuser -d mydb
```
