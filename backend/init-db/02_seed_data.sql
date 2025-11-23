-- =====================================================
-- Attendance Management System - Seed Data
-- =====================================================
-- This script inserts initial/sample data for testing
-- UPDATED to match existing column naming conventions
-- Comment out this file if you don't want sample data
-- =====================================================

-- Insert sample faculty
INSERT INTO faculty (fact_id, fact_name) VALUES
  ('FACT001', 'Faculty of Engineering'),
  ('FACT002', 'Faculty of Sciences')
ON CONFLICT (fact_id) DO NOTHING;

-- Insert sample departments
INSERT INTO department (dept_id, dept_name, fact_id) VALUES
  ('DEPT001', 'Computer Science', 'FACT001'),
  ('DEPT002', 'Electrical Engineering', 'FACT001'),
  ('DEPT003', 'Mathematics', 'FACT002')
ON CONFLICT (dept_id) DO NOTHING;

-- Insert sample programs
INSERT INTO program (prog_id, prog_name, dept_id) VALUES
  ('PROG001', 'Bachelor of Computer Science', 'DEPT001'),
  ('PROG002', 'Bachelor of Electrical Engineering', 'DEPT002'),
  ('PROG003', 'Bachelor of Mathematics', 'DEPT003')
ON CONFLICT (prog_id) DO NOTHING;

-- Insert sample semesters (adjust dates as needed)
INSERT INTO semester (sem_id, sem_name, start_date, end_date, prog_id) VALUES
  ('SEM001', 'Fall 2024', '2024-09-01', '2024-12-20', 'PROG001'),
  ('SEM002', 'Spring 2025', '2025-01-15', '2025-05-30', 'PROG001'),
  ('SEM003', 'Fall 2024', '2024-09-01', '2024-12-20', 'PROG002')
ON CONFLICT (sem_id) DO NOTHING;

-- Insert sample teachers
INSERT INTO teachers (teacher_id, teacher_name, type, dept_id) VALUES
  ('TEACH001', 'Dr. John Smith', 'PERMANENT', 'DEPT001'),
  ('TEACH002', 'Prof. Sarah Johnson', 'PERMANENT', 'DEPT001'),
  ('TEACH003', 'Mr. Michael Brown', 'GUEST', 'DEPT002'),
  ('TEACH004', 'Dr. Emily Davis', 'CONTRACT', 'DEPT003')
ON CONFLICT (teacher_id) DO NOTHING;

-- Insert sample users (HOD and Super Admin)
INSERT INTO users (user_id, user_name, type, dept_id, fact_id) VALUES
  ('admin@example.com', 'Super Administrator', 'SUPER_ADMIN', NULL, NULL),
  ('hod.cs@example.com', 'CS Department HOD', 'HOD', 'DEPT001', 'FACT001'),
  ('TEACH001', 'Dr. John Smith', 'NORMAL', 'DEPT001', 'FACT001')
ON CONFLICT (user_id) DO NOTHING;

-- Insert sample students
INSERT INTO students (student_id, student_name, phone_number, sem_id) VALUES
  ('STU001', 'Alice Williams', 1234567890, 'SEM001'),
  ('STU002', 'Bob Martinez', 1234567891, 'SEM001'),
  ('STU003', 'Charlie Garcia', 1234567892, 'SEM001'),
  ('STU004', 'Diana Rodriguez', 1234567893, 'SEM002'),
  ('STU005', 'Edward Lopez', 1234567894, 'SEM003')
ON CONFLICT (student_id) DO NOTHING;

-- Insert student enrollments
INSERT INTO student_enrollment (student_id, sem_id) VALUES
  ('STU001', 'SEM001'),
  ('STU002', 'SEM001'),
  ('STU003', 'SEM001'),
  ('STU004', 'SEM002'),
  ('STU005', 'SEM003')
ON CONFLICT (student_id, sem_id) DO NOTHING;

-- Insert sample courses
INSERT INTO course (course_id, course_name, sem_id) VALUES
  ('COURSE001', 'Data Structures', 'SEM001'),
  ('COURSE002', 'Algorithms', 'SEM001'),
  ('COURSE003', 'Database Systems', 'SEM002'),
  ('COURSE004', 'Digital Logic', 'SEM003')
ON CONFLICT (course_id) DO NOTHING;

-- Assign teachers to courses
INSERT INTO teacher_course (teacher_id, course_id) VALUES
  ('TEACH001', 'COURSE001'),
  ('TEACH002', 'COURSE002'),
  ('TEACH001', 'COURSE003'),
  ('TEACH003', 'COURSE004')
ON CONFLICT (teacher_id, course_id) DO NOTHING;

-- Enroll students in courses
INSERT INTO course_student (student_id, course_id) VALUES
  ('STU001', 'COURSE001'),
  ('STU001', 'COURSE002'),
  ('STU002', 'COURSE001'),
  ('STU002', 'COURSE002'),
  ('STU003', 'COURSE001'),
  ('STU004', 'COURSE003'),
  ('STU005', 'COURSE004')
ON CONFLICT (student_id, course_id) DO NOTHING;

-- Success message
SELECT 'Sample data seeded successfully!' AS status;
SELECT
  (SELECT COUNT(*) FROM faculty) AS faculties,
  (SELECT COUNT(*) FROM department) AS departments,
  (SELECT COUNT(*) FROM program) AS programs,
  (SELECT COUNT(*) FROM semester) AS semesters,
  (SELECT COUNT(*) FROM teachers) AS teachers,
  (SELECT COUNT(*) FROM students) AS students,
  (SELECT COUNT(*) FROM course) AS courses,
  (SELECT COUNT(*) FROM users) AS users;
