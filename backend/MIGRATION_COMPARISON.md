# Migration Comparison: db_setup.py vs Docker Init Scripts

## Overview

You previously used `db_setup.py` to set up the database. We've now created Docker-based initialization scripts that are more production-ready. This document compares both approaches.

## What `db_setup.py` Does

### Tables Created (from models.py)

1. **faculty** - fact_id, fact_name
2. **department** - dept_id, dept_name, fact_id
3. **program** - prog_id, prog_name, dept_id
4. **semester** - sem_id, sem_name, start_date, end_date, prog_id
5. **teachers** - teacher_id, teacher_name, type, dept_id
6. **students** - student_id, student_name, phone_number, sem_id
7. **course** - course_id, course_name, sem_id
8. **student_enrollment** - student_id, sem_id
9. **teacher_course** - teacher_id, course_id
10. **course_student** - student_id, course_id
11. **attendance** - attendance_id, student_id, course_id, date, present, created_at
12. **otp_storage** - email, otp, created_at, expires_at, attempts
13. **users** - user_id, user_name, type, dept_id, fact_id

### Enums Created
- teacher_type (PERMANENT, GUEST, CONTRACT)
- user_type (NORMAL, HOD, SUPER_ADMIN)

### Initial Data (from JSON files)
- Loads faculty_data.json → faculty table
- Loads departments.json → department table
- Loads programs.json → program table

## What New Docker Scripts Do

### Tables Created (from init-db/01_init_schema.sql)

1. **faculty** - factid, name, created_at, updated_at
2. **department** - deptid, name, factid, created_at, updated_at
3. **program** - progid, name, deptid, factid, created_at, updated_at
4. **semester** - semid, name, startdate, enddate, progid, created_at, updated_at
5. **teachers** - teacherid, name, type, deptid, created_at, updated_at
6. **students** - studentid, name, phonenumber, progid, semid, deptid, created_at, updated_at
7. **student_enrollment** - student_id, sem_id, enrolled_at
8. **course** - courseid, name, semid, progid, deptid, factid, created_at, updated_at
9. **teacher_course** - teacherid, courseid, semid, deptid, progid, factid, assigned_at
10. **course_students** - studentid, courseid, progid, semid, deptid, enrolled_at
11. **attendance** - attendanceid, studentid, courseid, date, present, semid, deptid, progid, created_at, updated_at
12. **users** - userid, name, type, deptid, factid, created_at, updated_at
13. **otp_storage** - email, otp, created_at, expires_at, attempts

### Enums Created
- teacher_type (PERMANENT, GUEST, CONTRACT) ✓
- user_type (NORMAL, HOD, SUPER_ADMIN) ✓

### Initial Data (from init-db/02_seed_data.sql)
- Sample faculties, departments, programs
- Sample semesters with dates
- Sample teachers
- Sample students
- Sample courses
- Sample users (HOD, Super Admin)
- Course enrollments and assignments

## Key Differences

### ✅ Improvements in Docker Scripts

| Feature | db_setup.py | Docker Scripts | Status |
|---------|-------------|----------------|--------|
| **Column Names** | Inconsistent (fact_id, teacher_id) | Consistent (factid, teacherid) | ⚠️ Different |
| **Timestamps** | Only in attendance | All tables | ✅ Better |
| **Indexes** | Basic | Comprehensive (20+ indexes) | ✅ Better |
| **Foreign Keys** | Basic | Complete with all relationships | ✅ Better |
| **Students Table** | Missing prog_id, dept_id | Has prog_id, sem_id, dept_id | ✅ Better |
| **Course Table** | Only sem_id | Has sem_id, prog_id, dept_id, fact_id | ✅ Better |
| **Teacher Course** | Only teacher_id, course_id | Complete with all IDs | ✅ Better |
| **Course Students** | Called course_student | Called course_students | ⚠️ Different |
| **Attendance** | Missing sem_id, dept_id, prog_id | Complete tracking | ✅ Better |

### ⚠️ Column Name Incompatibility

**IMPORTANT**: The column names are different between the two approaches:

| Table | db_setup.py (models.py) | Docker Scripts |
|-------|------------------------|----------------|
| faculty | fact_id, fact_name | factid, name |
| department | dept_id, dept_name, fact_id | deptid, name, factid |
| program | prog_id, prog_name, dept_id | progid, name, deptid, factid |
| semester | sem_id, sem_name, start_date, end_date | semid, name, startdate, enddate |
| teachers | teacher_id, teacher_name | teacherid, name |
| students | student_id, student_name, phone_number, sem_id | studentid, name, phonenumber, progid, semid, deptid |
| course | course_id, course_name, sem_id | courseid, name, semid, progid, deptid, factid |
| attendance | attendance_id | attendanceid |
| users | user_id, user_name | userid, name |

**This means your existing codebase expects the old column names!**

## Recommendation

### Option 1: Update Docker Scripts to Match Existing Code (RECOMMENDED)

Update `init-db/01_init_schema.sql` to use the same column names as your existing code. This requires no code changes.

### Option 2: Update All Code to Match New Schema

Update all CRUD operations and models in the backend to use new column names. This is more work but gives better schema.

### Option 3: Keep Using db_setup.py (Temporary)

Continue using `db_setup.py` for now, but enhance it with:
- More comprehensive indexes
- Timestamp columns
- Better foreign key relationships

## What You Should Do Now

### Immediate Action Required

**The Docker init scripts won't work with your current backend code because column names are different.**

I recommend **Option 1**: Update the Docker scripts to match your existing column naming. This is the safest and quickest path.

Would you like me to:

1. **Update init-db/01_init_schema.sql to match your existing column names?** (RECOMMENDED)
2. **Enhance db_setup.py instead to add missing tables and features?**
3. **Create a migration script to rename columns in existing databases?**

### Missing Tables in db_setup.py

The Docker scripts include one additional consideration:
- **student_enrollment** table exists in both ✓
- **course_students** (Docker) vs **course_student** (db_setup) - Similar but different name

### Missing in db_setup.py Schema

1. **Timestamp columns** (created_at, updated_at) - Important for auditing
2. **Comprehensive indexes** - Important for performance
3. **Complete foreign keys** - Students missing prog_id and dept_id
4. **Course missing** - prog_id, dept_id, fact_id references

## Testing the Current Setup

To verify your current database schema matches db_setup.py:

```bash
docker exec -it local-postgres psql -U myuser -d mydb -c "\d students"
```

Look at the column names to confirm which schema you're using.

## Summary

- ✅ **db_setup.py creates all essential tables**
- ✅ **Docker scripts are more production-ready**
- ⚠️ **Column names are INCOMPATIBLE between the two**
- ⚠️ **Docker scripts won't work with your current code without changes**

**Next Step**: Choose which option above you'd like me to implement.
