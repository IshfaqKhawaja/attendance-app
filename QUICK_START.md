# Quick Start Guide

Get the Attendance App up and running in minutes!

## 🚀 Local Development Setup

### Backend Setup (5 minutes)

1. **Navigate to backend directory**
   ```bash
   cd backend
   ```

2. **Copy environment file**
   ```bash
   cp .env.development .env
   ```

3. **Start development server**
   ```bash
   ./start-dev.sh
   ```

   Or manually:
   ```bash
   # Install dependencies
   pip install -e .

   # Start server
   uvicorn app.main:app --reload --env-file .env.development
   ```

4. **Access API**
   - API: http://localhost:8000
   - Docs: http://localhost:8000/docs
   - Health: http://localhost:8000/health

### Frontend Setup (5 minutes)

1. **Navigate to app directory**
   ```bash
   cd app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

   Or for specific device:
   ```bash
   flutter run -d chrome  # Web
   flutter run -d android # Android
   flutter run -d ios     # iOS
   ```

---

## 🐳 Docker Setup (Even Easier!)

### Start Everything with Docker

```bash
cd backend
docker-compose up -d
```

This starts:
- PostgreSQL (port 5432)
- Redis (port 6379)
- Backend API (port 8000)

### Check Status
```bash
docker-compose ps
docker-compose logs -f backend
```

### Stop Everything
```bash
docker-compose down
```

---

## 🔑 Default Configuration

### Development Environment

The `.env.development` file contains safe defaults for local development:

- **Database**: PostgreSQL on port 5433
- **API Port**: 8000
- **JWT**: Development secret (insecure)
- **CORS**: Allows localhost
- **Debug**: Enabled
- **Logging**: Verbose

### Test Credentials

For development, you can use:
- Email OTP is returned in API response (dev mode only)
- Check logs for OTP codes

---

## 📝 Common Tasks

### View Backend Logs
```bash
cd backend
docker-compose logs -f backend
```

### Access Database
```bash
docker-compose exec postgres psql -U myuser -d mydb
```

### Rebuild Backend
```bash
docker-compose build --no-cache backend
docker-compose up -d backend
```

### Reset Database
```bash
docker-compose down -v  # Warning: Deletes all data!
docker-compose up -d
```

### Hot Reload (Backend)
```bash
cd backend
uvicorn app.main:app --reload
```

### Hot Reload (Frontend)
```bash
cd app
flutter run
# Press 'r' to hot reload
# Press 'R' to hot restart
```

---

## 🧪 Testing

### Test Backend API
```bash
# Health check
curl http://localhost:8000/health

# Send OTP (dev mode returns OTP)
curl -X POST http://localhost:8000/authenticate/send_otp \
  -H "Content-Type: application/json" \
  -d '{"email_id": "test@example.com"}'

# Get all initial data
curl http://localhost:8000/initial/get_all_data
```

### Test Frontend
```bash
cd app
flutter test
```

---

## 🔧 Troubleshooting

### Port Already in Use
```bash
# Find process using port 8000
lsof -ti:8000

# Kill process
kill -9 $(lsof -ti:8000)
```

### Docker Issues
```bash
# Remove all containers and start fresh
docker-compose down -v
docker system prune -a  # Warning: Removes all Docker data!
docker-compose up -d
```

### Database Connection Failed
```bash
# Check if PostgreSQL is running
docker-compose ps postgres

# Restart PostgreSQL
docker-compose restart postgres

# Check logs
docker-compose logs postgres
```

### Flutter Build Issues
```bash
# Clean build
flutter clean
flutter pub get
flutter run
```

---

## 📚 Next Steps

1. **Read Full Documentation**
   - [DEPLOYMENT.md](DEPLOYMENT.md) - Production deployment
   - [PRODUCTION_CHECKLIST.md](PRODUCTION_CHECKLIST.md) - Pre-launch checklist

2. **Explore API**
   - Open http://localhost:8000/docs
   - Try out different endpoints
   - Check request/response formats

3. **Customize**
   - Update environment variables
   - Modify API endpoints
   - Customize app theme

4. **Deploy**
   - Follow deployment guide
   - Set up production environment
   - Configure domains and SSL

---

## 💡 Tips

- **Backend**: Runs on port 8000 by default
- **Frontend**: Configure API URL in `lib/app/config/environment.dart`
- **Logs**: Check `backend/logs/app.log` for detailed logs
- **Database**: PostgreSQL data persists in Docker volume
- **Redis**: Used for OTP storage (optional in development)

---

## 🆘 Need Help?

- Check logs: `docker-compose logs -f`
- Check health: `curl http://localhost:8000/health`
- Review docs: http://localhost:8000/docs
- View errors in terminal output

---

**Happy Coding! 🎉**
