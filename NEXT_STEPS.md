# 🚀 Next Steps - Deployment Guide

Follow these steps in order to deploy your Attendance App to production.

## ⚡ Quick Action Items

### 🔴 CRITICAL (Do First - Before Any Deployment)

1. **Generate Secure JWT Secret**
   ```bash
   openssl rand -hex 32
   ```
   Copy the output and save it for step 3.

2. **Create Strong Database Password**
   Use a password generator or:
   ```bash
   openssl rand -base64 24
   ```

3. **Update `.env` File**
   ```bash
   cd backend
   cp .env.example .env
   nano .env
   ```

   Update these values:
   ```bash
   JWT_SECRET_KEY=<paste-from-step-1>
   DB_PASSWORD=<paste-from-step-2>
   SMTP_EMAIL=your-actual-email@gmail.com
   SMTP_PASSWORD=your-gmail-app-password
   ALLOWED_ORIGINS=https://yourdomain.com
   ENVIRONMENT=production
   DEBUG=false
   ```

4. **Update Frontend API URL**
   ```bash
   nano app/lib/app/config/environment.dart
   ```

   Change production URL:
   ```dart
   static const AppConfig production = AppConfig(
     apiBaseUrl: 'https://api.yourdomain.com',  // YOUR URL HERE
     ...
   );
   ```

---

## 📋 Step-by-Step Deployment

### Option A: Docker Deployment (Recommended)

#### 1. Prepare Server
```bash
# On your server
sudo apt update && sudo apt upgrade -y
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```

#### 2. Deploy Backend
```bash
# Clone repository
git clone <your-repo-url> attendance-app
cd attendance-app/backend

# Configure environment (see CRITICAL steps above)
cp .env.example .env
nano .env

# Deploy
chmod +x deploy.sh
./deploy.sh
```

#### 3. Setup Domain & SSL
```bash
# Install Nginx
sudo apt install nginx -y

# Create Nginx config (see DEPLOYMENT.md for full config)
sudo nano /etc/nginx/sites-available/attendance-app

# Enable site
sudo ln -s /etc/nginx/sites-available/attendance-app /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# Install SSL certificate
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d api.yourdomain.com
```

#### 4. Verify Backend
```bash
# Check health
curl https://api.yourdomain.com/health

# View logs
docker-compose logs -f backend
```

### Option B: Manual Deployment

See [DEPLOYMENT.md](DEPLOYMENT.md) for detailed manual deployment instructions.

---

## 📱 Mobile App Release

### Android Release

#### 1. Generate Signing Key
```bash
keytool -genkey -v -keystore ~/attendance-app-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias attendance-app
```

#### 2. Configure Signing
Create `app/android/key.properties`:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=attendance-app
storeFile=/path/to/attendance-app-key.jks
```

#### 3. Build Release
```bash
cd app
chmod +x build-release.sh
./build-release.sh android
```

#### 4. Test APK
```bash
# Install on device
adb install build/app/outputs/flutter-apk/app-release.apk

# Test thoroughly!
```

#### 5. Upload to Play Store
- Upload the `.aab` file from `build/app/outputs/bundle/release/`
- Fill in store listing
- Submit for review

### iOS Release

#### 1. Configure Xcode
- Open `ios/Runner.xcworkspace` in Xcode
- Set signing certificate
- Set provisioning profile

#### 2. Build
```bash
./build-release.sh ios
```

#### 3. Archive & Upload
- In Xcode: Product → Archive
- Distribute App → App Store Connect
- Submit for review

---

## ✅ Pre-Launch Checklist

Run through this checklist before going live:

### Backend
- [ ] JWT secret is secure and unique (32+ characters)
- [ ] Database password is strong
- [ ] CORS origins set to actual domain (not `*`)
- [ ] `DEBUG=false` in production `.env`
- [ ] SMTP credentials configured and tested
- [ ] Health check passing: `curl https://api.yourdomain.com/health`
- [ ] API docs accessible: https://api.yourdomain.com/docs
- [ ] SSL certificate installed and valid
- [ ] Database backups configured
- [ ] Logs directory exists and writable

### Frontend
- [ ] Production API URL configured
- [ ] Debug mode disabled
- [ ] Logging disabled in production
- [ ] App version updated
- [ ] App signed with production certificate
- [ ] Tested on physical devices
- [ ] All features working with production API

### Security
- [ ] No `.env` files in git
- [ ] No hardcoded credentials in code
- [ ] Rate limiting tested
- [ ] Authentication working
- [ ] OTP not exposed in responses (production)
- [ ] HTTPS enforced
- [ ] Firewall configured

### Testing
- [ ] All API endpoints tested
- [ ] Authentication flow tested
- [ ] File uploads tested
- [ ] Report generation tested
- [ ] Error handling tested
- [ ] Load testing completed

---

## 🧪 Quick Tests

### Test Backend API

```bash
# Health check
curl https://api.yourdomain.com/health

# Send OTP (should NOT return OTP in production)
curl -X POST https://api.yourdomain.com/authenticate/send_otp \
  -H "Content-Type: application/json" \
  -d '{"email_id": "test@example.com"}'

# Get initial data (should return 401 without auth)
curl https://api.yourdomain.com/initial/get_all_data
```

### Test Rate Limiting

```bash
# Run 100 requests quickly
for i in {1..100}; do
  curl https://api.yourdomain.com/health &
done

# Should get 429 errors after limit
```

### Test CORS

Open browser console on a different domain and try:
```javascript
fetch('https://api.yourdomain.com/health')
  .then(r => r.json())
  .then(console.log)
  .catch(console.error);
```

Should fail if CORS configured correctly!

---

## 📊 Monitoring Setup

### 1. Enable Application Monitoring
```bash
# Install monitoring tools
pip install sentry-sdk

# Add to app/main.py (optional)
import sentry_sdk
sentry_sdk.init(dsn="your-sentry-dsn")
```

### 2. Setup Log Monitoring
```bash
# View live logs
docker-compose logs -f backend

# Setup log rotation
sudo nano /etc/logrotate.d/attendance-app
```

### 3. Setup Uptime Monitoring
Use services like:
- UptimeRobot (free)
- Pingdom
- DataDog
- New Relic

Monitor: `https://api.yourdomain.com/health`

---

## 🔄 Regular Maintenance

### Daily
- [ ] Check health endpoint
- [ ] Monitor error logs
- [ ] Check disk space

### Weekly
- [ ] Review application logs
- [ ] Check database size
- [ ] Monitor API response times
- [ ] Review user feedback

### Monthly
- [ ] Update dependencies
- [ ] Review security logs
- [ ] Test backups
- [ ] Update documentation

---

## 🚨 Troubleshooting

### Backend Won't Start
```bash
# Check logs
docker-compose logs backend

# Check environment
docker-compose exec backend env | grep -E "DB|JWT"

# Restart
docker-compose restart backend
```

### Database Issues
```bash
# Check if PostgreSQL is running
docker-compose ps postgres

# Access database
docker-compose exec postgres psql -U myuser -d mydb

# Check logs
docker-compose logs postgres
```

### SSL Issues
```bash
# Check certificate
sudo certbot certificates

# Renew
sudo certbot renew --dry-run

# Check Nginx
sudo nginx -t
```

### App Can't Connect to API
1. Check frontend environment configuration
2. Verify API URL is correct and accessible
3. Check CORS configuration
4. Test API directly with curl
5. Check network/firewall

---

## 📚 Reference Documents

- **[README.md](README.md)** - Main project documentation
- **[QUICK_START.md](QUICK_START.md)** - Local development setup
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Detailed deployment guide
- **[PRODUCTION_CHECKLIST.md](PRODUCTION_CHECKLIST.md)** - Complete checklist
- **[PRODUCTION_READY_SUMMARY.md](PRODUCTION_READY_SUMMARY.md)** - What was changed

---

## 💡 Pro Tips

1. **Test locally first**: Always test Docker deployment locally before server deployment
2. **Backup before deploy**: Take database backup before any deployment
3. **Use staging**: Set up a staging environment to test changes
4. **Monitor logs**: Keep an eye on logs for first 24-48 hours
5. **Have rollback plan**: Keep previous version ready to rollback
6. **Document changes**: Keep deployment log of what you changed
7. **Test backups**: Regularly test backup restoration
8. **Security updates**: Keep dependencies updated
9. **Rate limiting**: Adjust based on actual usage patterns
10. **Scale gradually**: Start with smaller resources, scale as needed

---

## 🎯 Success Indicators

Your deployment is successful when:

✅ Health endpoint returns HTTP 200
✅ API docs are accessible
✅ Authentication works
✅ Frontend app can connect and login
✅ All CRUD operations work
✅ Reports generate successfully
✅ No error logs
✅ Response times < 500ms
✅ Database queries efficient
✅ Backups running
✅ SSL certificate valid
✅ CORS working correctly
✅ Rate limiting active

---

## 🆘 Getting Help

If you encounter issues:

1. Check logs: `docker-compose logs -f`
2. Review troubleshooting section above
3. Check health endpoint
4. Review [DEPLOYMENT.md](DEPLOYMENT.md)
5. Check API docs for endpoint testing
6. Verify all environment variables
7. Test with curl commands above

---

## 🎉 You're Ready!

Follow these steps in order, and you'll have a production-ready application running smoothly!

**Good luck with your deployment! 🚀**

---

**Document Version**: 1.0.0
**Last Updated**: 2025
