#!/usr/bin/env python3
"""
Migration script to create the otp_storage table.
Run this after updating the schema in models.py
"""

import sys
from pathlib import Path

# Add parent directory to path
backend_dir = Path(__file__).parent.parent
sys.path.insert(0, str(backend_dir))

from app.db.connection import connection_to_db


def create_otp_table():
    """Create the otp_storage table if it doesn't exist."""
    conn = connection_to_db()

    try:
        with conn.cursor() as cur:
            print("Creating otp_storage table...")

            # Create table
            cur.execute("""
                CREATE TABLE IF NOT EXISTS otp_storage (
                    email          VARCHAR(255) PRIMARY KEY,
                    otp            VARCHAR(6) NOT NULL,
                    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
                    expires_at     TIMESTAMP NOT NULL,
                    attempts       INTEGER DEFAULT 0
                )
            """)

            # Create index for cleanup queries
            cur.execute("""
                CREATE INDEX IF NOT EXISTS idx_otp_expires_at
                ON otp_storage(expires_at)
            """)

        conn.commit()
        print("✓ otp_storage table created successfully!")

        # Show table info
        with conn.cursor() as cur:
            cur.execute("""
                SELECT column_name, data_type, is_nullable
                FROM information_schema.columns
                WHERE table_name = 'otp_storage'
                ORDER BY ordinal_position
            """)
            print("\nTable structure:")
            for row in cur.fetchall():
                print(f"  - {row[0]}: {row[1]} ({'NULL' if row[2] == 'YES' else 'NOT NULL'})")

        return True

    except Exception as e:
        conn.rollback()
        print(f"✗ Error creating otp_storage table: {e}")
        return False
    finally:
        conn.close()


if __name__ == "__main__":
    print("=" * 60)
    print("OTP Storage Table Creation Script")
    print("=" * 60)

    success = create_otp_table()

    if success:
        print("\n✓ Migration completed successfully!")
        print("\nYou can now restart your backend server.")
        print("OTPs will be stored in the database instead of JSON files.")
        sys.exit(0)
    else:
        print("\n✗ Migration failed!")
        sys.exit(1)
