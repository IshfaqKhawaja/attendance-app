# Attendance Management System - Deployment Guide

This guide will help you deploy the Attendance Management System in production.

## Prerequisites

- Docker and Docker Compose installed
- Git installed
- Basic understanding of Docker and PostgreSQL

## Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd attendance-app/backend
```

### 2. Configure Environment Variables

```bash
# Copy the example environment file
cp .env.example .env

# Edit the .env file with your production values
nano .env  # or use your preferred editor
```

**Important**: Update these values in `.env`:
- `DB_PASSWORD`: Use a strong password
- `JWT_SECRET_KEY`: Generate a secure key
- `SMTP_EMAIL` and `SMTP_PASSWORD`: For email OTP
- `TWILIO_*`: If using SMS notifications
- `ALLOWED_ORIGINS`: Your frontend URL(s)

### 3. Setup Database

The setup script will:
- Start PostgreSQL and Redis containers
- Create all database tables
- Insert initial data (if you keep 02_seed_data.sql)

```bash
# Make the setup script executable
chmod +x setup.sh

# Run the setup
./setup.sh
```

### 4. Start the Application

```bash
# Start all services (database, redis, backend)
docker-compose up -d

# View logs
docker-compose logs -f backend

# Check service status
docker-compose ps
```

The API will be available at `http://localhost:8000`

## Production Configuration

### Database Initialization

The database is automatically initialized using scripts in `init-db/`:

1. **`01_init_schema.sql`** - Creates all tables (REQUIRED)
2. **`02_seed_data.sql`** - Inserts sample data (OPTIONAL)

For production, you may want to:
- Delete or rename `02_seed_data.sql` to start with an empty database
- Create your own `02_production_data.sql` with your actual initial data

### Security Best Practices

1. **Strong Passwords**
   ```bash
   # Generate a strong database password
   openssl rand -base64 32

   # Generate a JWT secret key
   python -c "import secrets; print(secrets.token_hex(32))"
   ```

2. **Environment Variables**
   - Never commit `.env` to version control
   - Use different secrets for each environment (dev, staging, prod)
   - Restrict database access to application only

3. **CORS Configuration**
   - Update `ALLOWED_ORIGINS` in `.env` with your frontend domain
   - Never use `*` in production

4. **HTTPS/SSL**
   - Use a reverse proxy (nginx) with SSL certificates
   - Redirect HTTP to HTTPS
   - Use Let's Encrypt for free SSL certificates

### Docker Compose Production Setup

For production, modify `docker-compose.yml`:

```yaml
backend:
  environment:
    - DEBUG=false
    - ENVIRONMENT=production
  restart: always  # Auto-restart on failure
```

## Database Backup

### Automated Backup Script

```bash
#!/bin/bash
# backup_db.sh

BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/attendance_db_$DATE.sql"

mkdir -p $BACKUP_DIR

docker exec attendance-postgres pg_dump -U myuser mydb > $BACKUP_FILE

# Compress the backup
gzip $BACKUP_FILE

# Remove backups older than 7 days
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete

echo "Backup created: $BACKUP_FILE.gz"
```

### Restore from Backup

```bash
# Extract the backup
gunzip backup_file.sql.gz

# Restore to database
docker exec -i attendance-postgres psql -U myuser -d mydb < backup_file.sql
```

### Schedule Automated Backups

Add to crontab:
```bash
# Daily backup at 2 AM
0 2 * * * /path/to/backup_db.sh
```

## Monitoring and Logs

### View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f postgres

# Last 100 lines
docker-compose logs --tail=100 backend
```

### Health Checks

```bash
# Check if services are running
docker-compose ps

# Check backend health endpoint
curl http://localhost:8000/health

# Check database connection
docker exec attendance-postgres pg_isready -U myuser -d mydb
```

### Database Monitoring

```bash
# Connect to database
docker exec -it attendance-postgres psql -U myuser -d mydb

# Check table sizes
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

# Check active connections
SELECT * FROM pg_stat_activity;

# Check database size
SELECT pg_size_pretty(pg_database_size('mydb'));
```

## Maintenance

### Update Application

```bash
# Pull latest changes
git pull origin main

# Rebuild and restart
docker-compose down
docker-compose build
docker-compose up -d
```

### Database Migrations

For schema changes, create new migration scripts in `init-db/` with sequential numbering:
- `03_add_new_table.sql`
- `04_modify_column.sql`

Or use alembic for versioned migrations (if already set up).

### Clean Up Docker Resources

```bash
# Remove stopped containers
docker-compose down

# Remove volumes (WARNING: This deletes all data!)
docker-compose down -v

# Clean up unused Docker resources
docker system prune -a
```

## Scaling

### Horizontal Scaling

For high traffic, you can scale the backend:

```bash
# Run multiple backend instances
docker-compose up -d --scale backend=3
```

Add a load balancer (nginx) in front of multiple backend instances.

### Database Optimization

1. **Indexes**: Already created in `01_init_schema.sql`
2. **Connection Pooling**: Configure in application
3. **Query Optimization**: Use EXPLAIN ANALYZE for slow queries
4. **Vacuuming**: PostgreSQL auto-vacuum should be enabled

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker-compose logs backend

# Check if ports are available
lsof -i :8000  # Backend
lsof -i :5432  # PostgreSQL

# Restart services
docker-compose restart
```

### Database Connection Issues

```bash
# Check if PostgreSQL is running
docker-compose ps postgres

# Check database logs
docker-compose logs postgres

# Verify connection inside container
docker exec -it attendance-postgres psql -U myuser -d mydb
```

### Reset Everything

```bash
# Stop and remove all containers and volumes
docker-compose down -v

# Remove the data directories
rm -rf logs/* reports/*

# Start fresh
./setup.sh
docker-compose up -d
```

## Support

For issues and questions:
- Check logs first: `docker-compose logs`
- Review this deployment guide
- Check environment configuration in `.env`
- Verify database connectivity

## Security Checklist

Before deploying to production:

- [ ] Changed default database password
- [ ] Generated new JWT secret key
- [ ] Updated SMTP credentials
- [ ] Set ALLOWED_ORIGINS to production domain
- [ ] Disabled DEBUG mode
- [ ] Set up SSL/HTTPS
- [ ] Configured firewall rules
- [ ] Set up automated backups
- [ ] Reviewed and secured all endpoints
- [ ] Implemented rate limiting
- [ ] Set up monitoring and alerts
- [ ] Removed sample data (02_seed_data.sql) if not needed
