"""
Database initialization script for Docker container.
Creates tables and loads initial data from JSON files.
"""
import time
import psycopg2
import json
import os
import sys
from app.core.settings import settings

def wait_for_db(max_retries=30, retry_interval=2):
    """Wait for database to be ready."""
    print("Waiting for database to be ready...")
    for attempt in range(max_retries):
        try:
            conn = psycopg2.connect(
                dbname=settings.DB_NAME,
                user=settings.DB_USER,
                password=settings.DB_PASSWORD,
                host=settings.DB_HOST,
                port=settings.DB_PORT
            )
            conn.close()
            print("Database is ready!")
            return True
        except psycopg2.OperationalError as e:
            print(f"Attempt {attempt + 1}/{max_retries}: Database not ready yet... ({e})")
            time.sleep(retry_interval)

    print("ERROR: Could not connect to database after maximum retries.")
    return False

def connect_db():
    """Connect to the database."""
    try:
        conn = psycopg2.connect(
            dbname=settings.DB_NAME,
            user=settings.DB_USER,
            password=settings.DB_PASSWORD,
            host=settings.DB_HOST,
            port=settings.DB_PORT
        )
        print("Successfully connected to database.")
        return conn
    except Exception as e:
        print(f"ERROR: Could not connect to database: {e}")
        raise

def get_table_statements():
    """Extract table creation statements from models.py."""
    try:
        import importlib.util
        models_path = os.path.join(os.path.dirname(__file__), "db/models.py")
        spec = importlib.util.spec_from_file_location("models", models_path)
        models = importlib.util.module_from_spec(spec)  # type: ignore
        spec.loader.exec_module(models)  # type: ignore
        return models.statements
    except Exception as e:
        print(f"ERROR: Could not load models.py: {e}")
        raise

def create_tables(conn):
    """Create database tables."""
    print("Creating database tables...")
    cur = conn.cursor()

    try:
        # Create teacher_type enum first
        print("Creating teacher_type enum...")
        cur.execute("""
        DO $$
        BEGIN
            IF NOT EXISTS (
                SELECT 1 FROM pg_type WHERE typname = 'teacher_type'
            ) THEN
                CREATE TYPE teacher_type AS ENUM (
                    'PERMANENT',
                    'GUEST',
                    'CONTRACT'
                );
            END IF;
        END
        $$;
        """)

        # Create tables
        statements = get_table_statements()
        for i, stmt in enumerate(statements):
            print(f"Executing statement {i + 1}/{len(statements)}...")
            cur.execute(stmt)

        conn.commit()
        print("All tables created successfully.")
    except Exception as e:
        conn.rollback()
        print(f"ERROR: Failed to create tables: {e}")
        raise
    finally:
        cur.close()

def insert_json(conn, file_path, table, columns):
    """Insert data from JSON file into database table."""
    print(f"Inserting data into {table} from {file_path}...")

    if not os.path.exists(file_path):
        print(f"WARNING: File {file_path} does not exist. Skipping.")
        return

    try:
        with open(file_path) as f:
            data = json.load(f)

        if not data:
            print(f"WARNING: No data in {file_path}. Skipping.")
            return

        cur = conn.cursor()
        inserted = 0

        for item in data:
            values = tuple(item[col] for col in columns)
            placeholders = ','.join(['%s'] * len(values))
            cur.execute(
                f"INSERT INTO {table} ({','.join(columns)}) VALUES ({placeholders}) ON CONFLICT DO NOTHING",
                values
            )
            if cur.rowcount > 0:
                inserted += 1

        conn.commit()
        cur.close()
        print(f"Inserted {inserted} rows into {table}")
    except Exception as e:
        conn.rollback()
        print(f"ERROR: Failed to insert data into {table}: {e}")
        raise

def insert_initial_users(conn):
    """Insert initial HOD and SUPER_ADMIN users."""
    print("Creating initial users...")

    try:
        cur = conn.cursor()

        # User 1: HOD for Computer Engineering Department (D028, F006)
        user1 = {
            "user_id": "cs@test.com",
            "user_name": "Computer Engineering HOD",
            "type": "HOD",
            "dept_id": "D028",  # Department of Computer Engineering
            "fact_id": "F006"   # Faculty of Engineering & Technology
        }

        # User 2: Super Admin (no department/faculty association)
        user2 = {
            "user_id": "superadmin@test.com",
            "user_name": "Super Admin",
            "type": "SUPER_ADMIN",
            "dept_id": None,
            "fact_id": None
        }

        inserted = 0

        for user in [user1, user2]:
            cur.execute(
                """
                INSERT INTO users (user_id, user_name, type, dept_id, fact_id)
                VALUES (%s, %s, %s, %s, %s)
                ON CONFLICT (user_id) DO NOTHING
                """,
                (user["user_id"], user["user_name"], user["type"], user["dept_id"], user["fact_id"])
            )
            if cur.rowcount > 0:
                inserted += 1
                print(f"  ✓ Created user: {user['user_name']} ({user['user_id']}) as {user['type']}")
                if user["dept_id"]:
                    print(f"    - Assigned to: Department {user['dept_id']}, Faculty {user['fact_id']}")
            else:
                print(f"  - User already exists: {user['user_id']}")

        conn.commit()
        cur.close()
        print(f"Initial users setup complete. Created {inserted} new user(s).")

    except Exception as e:
        conn.rollback()
        print(f"ERROR: Failed to create initial users: {e}")
        raise

def check_if_initialized(conn):
    """Check if database is already initialized."""
    try:
        cur = conn.cursor()
        cur.execute("SELECT COUNT(*) FROM faculty")
        count = cur.fetchone()[0]
        cur.close()
        return count > 0
    except psycopg2.errors.UndefinedTable:
        return False
    except Exception:
        return False

def main():
    """Main initialization function."""
    print("=" * 60)
    print("Database Initialization Script")
    print("=" * 60)

    # Wait for database to be ready
    if not wait_for_db():
        sys.exit(1)

    # Connect to database
    conn = connect_db()

    try:
        # Check if already initialized
        if check_if_initialized(conn):
            print("Database already initialized.")
            print("Checking and inserting users if missing...")

            # Still try to insert users even if DB is initialized
            insert_initial_users(conn)

            print("=" * 60)
            print("User check completed!")
            print("=" * 60)
            return

        print("Initializing database for the first time...")

        # Create tables
        create_tables(conn)

        # Insert initial data
        json_data_dir = "/app/json_data"

        insert_json(
            conn,
            os.path.join(json_data_dir, "faculty_data.json"),
            "faculty",
            ["fact_id", "fact_name"]
        )

        insert_json(
            conn,
            os.path.join(json_data_dir, "departments.json"),
            "department",
            ["dept_id", "dept_name", "fact_id"]
        )

        insert_json(
            conn,
            os.path.join(json_data_dir, "programs.json"),
            "program",
            ["prog_id", "prog_name", "dept_id"]
        )

        # Insert initial users
        insert_initial_users(conn)

        print("=" * 60)
        print("Database initialization completed successfully!")
        print("=" * 60)

    except Exception as e:
        print("=" * 60)
        print(f"FATAL ERROR: Database initialization failed: {e}")
        print("=" * 60)
        sys.exit(1)
    finally:
        conn.close()

if __name__ == "__main__":
    main()
