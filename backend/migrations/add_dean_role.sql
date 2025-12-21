-- Migration: Add DEAN role to user_type enum
-- Run this on the server to add the DEAN role to existing database

-- Add DEAN to the user_type enum (after HOD)
ALTER TYPE user_type ADD VALUE IF NOT EXISTS 'DEAN' AFTER 'HOD';

-- Insert the Dean user (if not exists)
INSERT INTO users (user_id, user_name, type, dept_id, fact_id)
VALUES ('dean@test.com', 'Faculty of Engineering Dean', 'DEAN', NULL, 'F006')
ON CONFLICT (user_id) DO NOTHING;

-- Verify the changes
SELECT * FROM users WHERE type = 'DEAN';
