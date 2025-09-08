import subprocess
import time
import psycopg2
import json
import os

# DB credentials from README
DB_USER = "myuser"
DB_PASSWORD = "mypassword"
DB_NAME = "mydb"
DB_HOST = "localhost"
DB_PORT = "5432"
DOCKER_NAME = "local-postgres"

def run_docker():
    # Remove existing container if present
    subprocess.run(["docker", "rm", "-f", DOCKER_NAME], check=False)
    subprocess.run([
        "docker", "run", "--name", DOCKER_NAME,
        "-e", f"POSTGRES_USER={DB_USER}",
        "-e", f"POSTGRES_PASSWORD={DB_PASSWORD}",
        "-e", f"POSTGRES_DB={DB_NAME}",
        "-p", f"{DB_PORT}:5432", "-d", "postgres:latest"
    ], check=False)
    print("Started PostgreSQL Docker container.")
    time.sleep(5)  # Wait for DB to be ready

def connect_db():
    for _ in range(10):
        try:
            conn = psycopg2.connect(
                dbname=DB_NAME, user=DB_USER, password=DB_PASSWORD,
                host=DB_HOST, port=DB_PORT
            )
            return conn
        except Exception:
            time.sleep(2)
    raise Exception("Could not connect to database.")

def get_table_statements():
        # Extract the statements list from models.py
        import importlib.util
        spec = importlib.util.spec_from_file_location("models", os.path.join(os.path.dirname(__file__), "db/models.py"))
        models = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(models)
        return models.statements

def create_tables(conn):
        cur = conn.cursor()
        # Create teacher_type enum first
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
        for stmt in get_table_statements():
                cur.execute(stmt)
        conn.commit()
        cur.close()
        print("All tables created.")

def insert_json(conn, file_path, table, columns):
    with open(file_path) as f:
        data = json.load(f)
    cur = conn.cursor()
    for item in data:
        values = tuple(item[col] for col in columns)
        placeholders = ','.join(['%s'] * len(values))
        cur.execute(f"INSERT INTO {table} ({','.join(columns)}) VALUES ({placeholders}) ON CONFLICT DO NOTHING", values)
    conn.commit()
    cur.close()
    print(f"Inserted data into {table} from {file_path}")

if __name__ == "__main__":
    run_docker()
    conn = connect_db()
    create_tables(conn)
    insert_json(conn, "json_data/faculty_data.json", "faculty", ["factid", "name"])
    insert_json(conn, "json_data/departments.json", "department", ["deptid", "name", "factid"])
    insert_json(conn, "json_data/programs.json", "program", ["progid", "name", "deptid", "factid"])
    conn.close()
    print("Setup complete.")