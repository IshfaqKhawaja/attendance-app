# Attendance App - Production Deployment Guide

This guide will help you deploy the Attendance App backend to a production server and build the Flutter app for distribution.

## 📋 Prerequisites

### Backend Requirements
- Ubuntu 20.04+ or similar Linux server
- Docker and Docker Compose installed
- Domain name (optional but recommended)
- SSL certificate (recommended)
- At least 2GB RAM, 2 CPU cores, 20GB storage

### Frontend Requirements
- Flutter SDK 3.8.1+
- Xcode (for iOS builds)
- Android Studio / Android SDK (for Android builds)

---

## 🔧 Backend Deployment

### Step 1: Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### Step 2: Clone Repository

```bash
# Clone your repository
git clone <your-repo-url> attendance-app
cd attendance-app/backend
```

### Step 3: Configure Environment

```bash
# Create production environment file
cp .env.example .env

# Edit .env with your production values
nano .env
```

**Important**: Set these critical values in `.env`:

```bash
# Database
DB_HOST=postgres
DB_PORT=5432
DB_NAME=mydb
DB_USER=myuser
DB_PASSWORD=STRONG_PASSWORD_HERE  # Change this!

# JWT (CRITICAL - Generate a secure key!)
JWT_SECRET_KEY=GENERATE_A_SECURE_RANDOM_KEY_HERE  # Use: openssl rand -hex 32
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=15
REFRESH_TOKEN_EXPIRE_DAYS=15

# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_EMAIL=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_USE_TLS=true

# Application
APP_NAME=Attendance App Backend
APP_VERSION=1.0.0
DEBUG=false
ENVIRONMENT=production

# CORS (Replace with your actual domain)
ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com

# Rate Limiting
RATE_LIMIT_PER_MINUTE=60

# Logging
LOG_LEVEL=INFO
LOG_FILE=logs/app.log
```

**Generate secure JWT secret key:**
```bash
openssl rand -hex 32
```

### Step 4: Deploy with Docker

```bash
# Make deploy script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

The script will:
- Build Docker images
- Start PostgreSQL, Redis, and Backend containers
- Run health checks
- Display running services

### Step 5: Verify Deployment

```bash
# Check if services are running
docker-compose ps

# Check backend health
curl http://localhost:8000/health

# View logs
docker-compose logs -f backend

# View API documentation
# Open browser: http://your-server-ip:8000/docs
```

### Step 6: Setup Nginx (Reverse Proxy)

```bash
# Install Nginx
sudo apt install nginx -y

# Create Nginx configuration
sudo nano /etc/nginx/sites-available/attendance-app
```

Add this configuration:

```nginx
server {
    listen 80;
    server_name api.yourdomain.com;

    client_max_body_size 100M;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # WebSocket support (if needed)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

```bash
# Enable site
sudo ln -s /etc/nginx/sites-available/attendance-app /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

### Step 7: Setup SSL with Let's Encrypt

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Obtain SSL certificate
sudo certbot --nginx -d api.yourdomain.com

# Auto-renewal is configured automatically
# Test renewal with:
sudo certbot renew --dry-run
```

### Step 8: Configure Firewall

```bash
# Allow SSH, HTTP, and HTTPS
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

---

## 📱 Flutter App Build

### Step 1: Configure Production Environment

Edit `lib/app/config/environment.dart`:

```dart
static const AppConfig production = AppConfig(
  environment: Environment.production,
  apiBaseUrl: 'https://api.yourdomain.com',  // Your production API URL
  enableLogging: false,
  enableDebugMode: false,
  apiTimeout: 15,
  appName: 'Attendance App',
);
```

### Step 2: Android Build

#### Configure Signing

1. Generate keystore:
```bash
keytool -genkey -v -keystore ~/attendance-app-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias attendance-app
```

2. Create `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=attendance-app
storeFile=/path/to/attendance-app-key.jks
```

3. Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

#### Build APK/AAB

```bash
# Make build script executable
chmod +x build-release.sh

# Build Android (APK and AAB)
./build-release.sh android

# Or build manually
flutter build apk --release --dart-define=FLAVOR=production
flutter build appbundle --release --dart-define=FLAVOR=production
```

Output files:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### Step 3: iOS Build

1. Open `ios/Runner.xcworkspace` in Xcode
2. Set signing certificate and provisioning profile
3. Select "Any iOS Device"
4. Product → Archive
5. Distribute App → App Store Connect

Or use command line:
```bash
./build-release.sh ios
```

---

## 🔄 Continuous Deployment

### Backend Updates

```bash
# Pull latest code
cd attendance-app/backend
git pull origin main

# Redeploy
./deploy.sh
```

### Database Migrations

```bash
# Access container
docker-compose exec backend bash

# Run migrations (if using Alembic)
alembic upgrade head
```

---

## 📊 Monitoring & Maintenance

### View Logs

```bash
# Backend logs
docker-compose logs -f backend

# Postgres logs
docker-compose logs -f postgres

# All services
docker-compose logs -f
```

### Backup Database

```bash
# Backup
docker-compose exec postgres pg_dump -U myuser mydb > backup_$(date +%Y%m%d).sql

# Restore
docker-compose exec -T postgres psql -U myuser mydb < backup_20240101.sql
```

### Monitor Resources

```bash
# View container stats
docker stats

# View disk usage
docker system df
```

### Restart Services

```bash
# Restart backend only
docker-compose restart backend

# Restart all services
docker-compose restart

# Stop all services
docker-compose down

# Start all services
docker-compose up -d
```

---

## 🔒 Security Checklist

- [ ] Change default database password
- [ ] Generate secure JWT secret key
- [ ] Configure proper CORS origins (not `*`)
- [ ] Enable HTTPS with SSL certificate
- [ ] Set up firewall rules
- [ ] Configure rate limiting appropriately
- [ ] Remove debug/development features
- [ ] Set strong email app passwords
- [ ] Regular security updates
- [ ] Enable database backups
- [ ] Monitor logs for suspicious activity
- [ ] Use secrets manager in production (AWS Secrets Manager, etc.)

---

## 🐛 Troubleshooting

### Backend won't start

```bash
# Check logs
docker-compose logs backend

# Check if ports are in use
sudo netstat -tulpn | grep :8000

# Restart services
docker-compose restart
```

### Database connection errors

```bash
# Check if Postgres is running
docker-compose ps postgres

# Check database logs
docker-compose logs postgres

# Verify credentials in .env file
cat .env | grep DB_
```

### SSL/HTTPS issues

```bash
# Check certificate status
sudo certbot certificates

# Renew certificate
sudo certbot renew

# Check Nginx configuration
sudo nginx -t
```

---

## 📞 Support

For issues or questions:
- Check logs first: `docker-compose logs -f`
- Review health endpoint: `curl http://localhost:8000/health`
- Check API docs: `http://your-server/docs`

---

## 📝 Notes

1. **Environment Variables**: Never commit `.env` files to version control
2. **Secrets**: Use a secrets manager in production
3. **Backups**: Schedule regular database backups
4. **Updates**: Keep dependencies and Docker images updated
5. **Monitoring**: Set up monitoring and alerting for production

---

**Last Updated**: 2025
**Version**: 1.0.0
