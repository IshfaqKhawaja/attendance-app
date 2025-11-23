-- Create OTP storage table
-- Run this with: psql -h localhost -U your_user -d your_db -f create_otp_table.sql

CREATE TABLE IF NOT EXISTS otp_storage (
    email          VARCHAR(255) PRIMARY KEY,
    otp            VARCHAR(6) NOT NULL,
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at     TIMESTAMP NOT NULL,
    attempts       INTEGER DEFAULT 0
);

-- Create index for cleanup queries
CREATE INDEX IF NOT EXISTS idx_otp_expires_at ON otp_storage(expires_at);

-- Show table info
\d otp_storage

-- Show success message
SELECT 'OTP storage table created successfully!' AS status;
