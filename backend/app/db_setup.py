"""
Manual database setup script for server.
Run this directly on the server to initialize/populate the database.

Usage:
    python -m app.db_setup
"""
import psycopg
import json
import os
import sys

# Default DB credentials - will be overridden by environment variables if set
DB_USER = os.getenv("DB_USER", "myuser")
DB_PASSWORD = os.getenv("DB_PASSWORD", "mypassword")
DB_NAME = os.getenv("DB_NAME", "mydb")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")

def connect_db():
    """Connect to the database."""
    print(f"Connecting to database at {DB_HOST}:{DB_PORT}...")
    try:
        conn = psycopg.connect(
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            host=DB_HOST,
            port=DB_PORT
        )
        print("✓ Connected to database successfully!")
        return conn
    except Exception as e:
        print(f"✗ Failed to connect to database: {e}")
        sys.exit(1)

def get_table_statements():
    """Extract the statements list from models.py."""
    import importlib.util
    models_path = os.path.join(os.path.dirname(__file__), "db/models.py")
    spec = importlib.util.spec_from_file_location("models", models_path)
    models = importlib.util.module_from_spec(spec) 
    spec.loader.exec_module(models)
    return models.statements

def extract_object_name(stmt):
    """Extract table/index/enum name from SQL statement."""
    stmt_upper = stmt.upper().strip()
    stmt_clean = stmt.strip()

    # Check for CREATE TYPE (enum)
    if "CREATE TYPE" in stmt_upper:
        import re
        match = re.search(r"CREATE TYPE\s+(\w+)", stmt_clean, re.IGNORECASE)
        if match:
            return f"enum: {match.group(1)}"

    # Check for CREATE TABLE
    if "CREATE TABLE" in stmt_upper:
        import re
        match = re.search(r"CREATE TABLE\s+(?:IF NOT EXISTS\s+)?(\w+)", stmt_clean, re.IGNORECASE)
        if match:
            return f"table: {match.group(1)}"

    # Check for CREATE INDEX
    if "CREATE INDEX" in stmt_upper:
        import re
        match = re.search(r"CREATE INDEX\s+(?:IF NOT EXISTS\s+)?(\w+)", stmt_clean, re.IGNORECASE)
        if match:
            return f"index: {match.group(1)}"

    return "statement"

def create_tables(conn):
    """Create all database tables using statements from models.py."""
    print("\nCreating database tables and enums...")
    cur = conn.cursor()
    try:
        # Get all statements from models.py (includes enums and tables)
        statements = get_table_statements()
        created_objects = {"enum": [], "table": [], "index": []}

        for i, stmt in enumerate(statements, 1):
            cur.execute(stmt)
            obj_name = extract_object_name(stmt)
            print(f"  ✓ [{i}/{len(statements)}] Created {obj_name}")

            # Track created objects
            if obj_name.startswith("enum:"):
                created_objects["enum"].append(obj_name.split(": ")[1])
            elif obj_name.startswith("table:"):
                created_objects["table"].append(obj_name.split(": ")[1])
            elif obj_name.startswith("index:"):
                created_objects["index"].append(obj_name.split(": ")[1])

        conn.commit()

        # Print summary of created objects
        print("\n" + "-" * 40)
        print("Created Objects Summary:")
        print(f"  Enums ({len(created_objects['enum'])}): {', '.join(created_objects['enum'])}")
        print(f"  Tables ({len(created_objects['table'])}): {', '.join(created_objects['table'])}")
        print(f"  Indexes ({len(created_objects['index'])}): {', '.join(created_objects['index'])}")
        print("-" * 40)
        print("✓ All tables created successfully!")
    except Exception as e:
        conn.rollback()
        print(f"✗ Failed to create tables: {e}")
        raise
    finally:
        cur.close()

def insert_json(conn, file_path, table, columns):
    """Insert data from JSON file into database table."""
    print(f"\nInserting data into {table}...")

    if not os.path.exists(file_path):
        print(f"  ✗ File not found: {file_path}")
        return

    try:
        with open(file_path) as f:
            data = json.load(f)

        if not data:
            print(f"  ⚠ No data in {file_path}")
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
        print(f"  ✓ Inserted {inserted} rows into {table}")
    except Exception as e:
        conn.rollback()
        print(f"  ✗ Failed to insert data into {table}: {e}")
        raise

def insert_users(conn):
    """Insert initial users."""
    print("\nCreating initial users...")
    cur = conn.cursor()

    try:
        # Check if D028 and F006 exist
        cur.execute("SELECT EXISTS(SELECT 1 FROM department WHERE dept_id='D028')")
        d028_exists = cur.fetchone()[0]

        cur.execute("SELECT EXISTS(SELECT 1 FROM faculty WHERE fact_id='F006')")
        f006_exists = cur.fetchone()[0]

        if d028_exists and f006_exists:
            print("  ✓ Found D028 and F006 in database")
            dept_id = "D028"
            fact_id = "F006"
        else:
            print(f"  ⚠ D028 exists={d028_exists}, F006 exists={f006_exists}")
            print("  ⚠ Using NULL for dept_id and fact_id")
            dept_id = None
            fact_id = None

        users = [
            {
                "user_id": "cs@test.com",
                "user_name": "Computer Engineering HOD",
                "type": "HOD",
                "dept_id": dept_id,
                "fact_id": fact_id
            },
            {
                "user_id": "dean@test.com",
                "user_name": "Faculty of Engineering Dean",
                "type": "DEAN",
                "dept_id": None,
                "fact_id": fact_id
            },
            {
                "user_id": "superadmin@test.com",
                "user_name": "Super Admin",
                "type": "SUPER_ADMIN",
                "dept_id": None,
                "fact_id": None
            }
        ]

        inserted = 0
        for user in users:
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
                print(f"  ✓ Created user: {user['user_name']} ({user['user_id']})")
            else:
                print(f"  - User already exists: {user['user_id']}")

        conn.commit()
        cur.close()
        print(f"✓ User setup complete! Created {inserted} new user(s).")
    except Exception as e:
        conn.rollback()
        print(f"✗ Failed to create users: {e}")
        raise

def main():
    """Main setup function."""
    print("=" * 60)
    print("Manual Database Setup Script")
    print("=" * 60)
    print(f"\nDatabase Configuration:")
    print(f"  Host: {DB_HOST}")
    print(f"  Port: {DB_PORT}")
    print(f"  Database: {DB_NAME}")
    print(f"  User: {DB_USER}")

    # Connect to database
    conn = connect_db()

    try:
        # Create tables
        create_tables(conn)

        # Insert data from JSON files
        json_data_dir = os.path.join(os.path.dirname(__file__), "../json_data")

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
        insert_users(conn)

        print("\n" + "=" * 60)
        print("✓ Database setup completed successfully!")
        print("=" * 60)

        # Show summary
        cur = conn.cursor()
        cur.execute("""
            SELECT
                (SELECT COUNT(*) FROM faculty) as faculties,
                (SELECT COUNT(*) FROM department) as departments,
                (SELECT COUNT(*) FROM program) as programs,
                (SELECT COUNT(*) FROM users) as users
        """)
        counts = cur.fetchone()
        cur.close()

        print("\nDatabase Summary:")
        print(f"  Faculties: {counts[0]}")
        print(f"  Departments: {counts[1]}")
        print(f"  Programs: {counts[2]}")
        print(f"  Users: {counts[3]}")

    except Exception as e:
        print("\n" + "=" * 60)
        print(f"✗ FATAL ERROR: Database setup failed!")
        print(f"Error: {e}")
        print("=" * 60)
        sys.exit(1)
    finally:
        conn.close()

if __name__ == "__main__":
    main()