# Initial Users Configuration

## Overview

The database initialization script now automatically creates two initial users on first deployment.

## Initial Users

### 1. HOD User
- **Email/User ID**: `cs@test.com`
- **Name**: Computer Engineering
- **Type**: `HOD` (Head of Department)
- **Department**: D028 - Department of Computer Engineering
- **Faculty**: F006 - Faculty of Engineering & Technology
- **Purpose**: Department administrator for Computer Engineering

### 2. Super Admin User
- **Email/User ID**: `superadmin@test.com`
- **Name**: Super Admin
- **Type**: `SUPER_ADMIN`
- **Department**: None (null)
- **Faculty**: None (null)
- **Purpose**: System-wide administrator with full access

## User Types

The system supports three user types (defined in the `user_type` enum):
1. **NORMAL** - Regular users
2. **HOD** - Head of Department (department-level admin)
3. **SUPER_ADMIN** - System-wide administrator

## How It Works

### On First Deployment:
1. Database tables are created
2. Initial data (faculties, departments, programs) is loaded from JSON files
3. **Two initial users are automatically created**
4. Backend starts accepting requests

### On Subsequent Deployments:
- The script checks if users already exist (by user_id)
- Uses `ON CONFLICT DO NOTHING` to prevent duplicates
- Skips user creation if they already exist
- Shows status: "User already exists: cs@test.com"

## Testing the Users

### Check if users were created:

```bash
# Connect to database
docker exec -it attendance-postgres psql -U myuser -d mydb

# Query users table
SELECT * FROM users;

# Expected output:
#       user_id        |       user_name       |    type     | dept_id | fact_id
# --------------------+-----------------------+-------------+---------+---------
#  cs@test.com        | Computer Engineering  | HOD         | D028    | F006
#  superadmin@test.com| Super Admin           | SUPER_ADMIN |         |
```

### Test API endpoints:

```bash
# Get HOD user
curl http://localhost/api/v1/users/cs@test.com

# Get Super Admin user
curl http://localhost/api/v1/users/superadmin@test.com

# List all users
curl http://localhost/api/v1/users
```

## Authentication Flow

Based on the authentication system:

1. **Login/Registration**:
   - Users authenticate using their email (user_id)
   - System checks if user exists in database
   - OTP is sent for verification

2. **Access Control**:
   - `NORMAL` users: Basic access
   - `HOD`: Department-level administration
   - `SUPER_ADMIN`: Full system access

## Modifying Initial Users

To change the initial users, edit [app/init_db.py](app/init_db.py):

```python
def insert_initial_users(conn):
    """Insert initial HOD and SUPER_ADMIN users."""

    # Modify these dictionaries:
    user1 = {
        "user_id": "your-email@example.com",  # Change email
        "user_name": "Your Name",              # Change name
        "type": "HOD",                          # HOD or SUPER_ADMIN
        "dept_id": "D028",                      # Department ID (or None)
        "fact_id": "F006"                       # Faculty ID (or None)
    }
```

After modifying:
```bash
# Rebuild and restart
docker compose down -v  # WARNING: Destroys all data!
docker compose up -d --build
```

## Adding More Initial Users

To add additional users at initialization:

1. Edit [app/init_db.py](app/init_db.py)
2. Add more user dictionaries to the `insert_initial_users()` function
3. Append to the list: `for user in [user1, user2, user3, ...]:`
4. Rebuild: `docker compose down -v && docker compose up -d --build`

## Security Notes

### Production Deployment:

⚠️ **IMPORTANT**: These are test credentials for development only!

For production:
1. Change the email addresses to real organizational emails
2. Implement proper authentication (password-based, SSO, etc.)
3. Add email verification
4. Use environment variables for initial admin credentials
5. Remove or disable test accounts after deployment
6. Implement password policies and 2FA

### Current Authentication:
- The system uses OTP (One-Time Password) for authentication
- OTPs are stored in Redis
- No passwords are stored in the database
- Email verification is required for login

## Troubleshooting

### Users not created:

```bash
# Check backend logs
docker logs attendance-backend | grep "Creating initial users"

# Should show:
# Creating initial users...
#   ✓ Created user: Computer Engineering (cs@test.com) as HOD
#   ✓ Created user: Super Admin (superadmin@test.com) as SUPER_ADMIN
# Initial users setup complete. Created 2 new user(s).
```

### Users already exist:

```bash
# If you see:
#   - User already exists: cs@test.com
#   - User already exists: superadmin@test.com

# This is normal on subsequent deployments
# To recreate, delete the volume:
docker compose down -v
docker compose up -d --build
```

### Department not found error:

If you get a foreign key constraint error:
- Verify D028 (Computer Engineering) exists in departments table
- Check json_data/departments.json contains the department
- Ensure departments are loaded before users

## Integration with Frontend

When building a frontend login:

```javascript
// Example login flow
const loginUser = async (email) => {
  // 1. Check if user exists
  const response = await fetch(`/api/v1/users/${email}`);

  if (response.ok) {
    const user = await response.json();
    // user.type will be: 'NORMAL', 'HOD', or 'SUPER_ADMIN'

    // 2. Send OTP
    // 3. Verify OTP
    // 4. Grant access based on user.type
  }
};
```

## Next Steps

After initial deployment with these users:
1. Login as `superadmin@test.com` to access admin panel
2. Use `cs@test.com` for department-level operations
3. Create additional HODs for other departments via API
4. Add NORMAL users (teachers, students) as needed
