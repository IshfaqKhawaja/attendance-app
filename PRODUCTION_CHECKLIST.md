# Production Readiness Checklist

Use this checklist before deploying to production.

## ✅ Backend Configuration

### Security
- [ ] All secrets moved to environment variables
- [ ] JWT secret key generated and secure (32+ characters)
- [ ] Database passwords are strong and unique
- [ ] Email credentials using app-specific passwords
- [ ] CORS origins set to specific domains (not `*`)
- [ ] Rate limiting configured appropriately
- [ ] HTTPS/SSL certificate installed
- [ ] Firewall configured (UFW or similar)
- [ ] OTP not exposed in API responses (except dev mode)
- [ ] No hardcoded credentials in codebase
- [ ] `.env` files in `.gitignore`

### Environment Variables (`.env`)
- [ ] `DB_PASSWORD` - Strong database password
- [ ] `JWT_SECRET_KEY` - Secure random key (use `openssl rand -hex 32`)
- [ ] `SMTP_EMAIL` - Production email address
- [ ] `SMTP_PASSWORD` - App-specific password
- [ ] `ALLOWED_ORIGINS` - Actual domain(s)
- [ ] `ENVIRONMENT=production`
- [ ] `DEBUG=false`
- [ ] `LOG_LEVEL=INFO` or `WARNING`

### Application
- [ ] All `print()` statements replaced with `logger`
- [ ] Proper exception handling (no bare `except:`)
- [ ] Logging configured and working
- [ ] Health check endpoint functional (`/health`)
- [ ] API documentation accessible (`/docs`)
- [ ] Database migrations ready (if using Alembic)
- [ ] Error responses standardized
- [ ] Request/Response validation working

### Infrastructure
- [ ] Docker and Docker Compose installed on server
- [ ] Dockerfile complete and tested
- [ ] `docker-compose.yml` configured
- [ ] PostgreSQL container configured with volumes
- [ ] Redis container configured (for OTP storage)
- [ ] Nginx reverse proxy configured
- [ ] SSL certificate obtained and installed
- [ ] Log rotation configured
- [ ] Backup strategy in place

### Testing
- [ ] All API endpoints tested
- [ ] Authentication flow tested
- [ ] OTP generation and verification tested
- [ ] File uploads tested
- [ ] Report generation tested
- [ ] Database connections tested
- [ ] Load testing performed
- [ ] Error handling tested

---

## ✅ Frontend Configuration

### Environment Setup
- [ ] Production API URL configured in `environment.dart`
- [ ] Debug mode disabled for production
- [ ] Logging disabled for production
- [ ] API timeout set appropriately
- [ ] Environment flavors configured (dev, staging, prod)

### Build Configuration
- [ ] Android signing keystore generated
- [ ] iOS certificates and provisioning profiles configured
- [ ] `key.properties` file created (Android)
- [ ] App version and build number updated
- [ ] App icons and splash screens finalized
- [ ] App name configured correctly

### Security
- [ ] No sensitive data in source code
- [ ] API keys secured
- [ ] Certificate pinning considered
- [ ] Secure storage for tokens verified
- [ ] Biometric auth timeout configured
- [ ] Network security config set (Android)

### Testing
- [ ] App tested on physical devices
- [ ] All user flows tested
- [ ] API integration tested
- [ ] Error handling tested
- [ ] Offline mode tested (if applicable)
- [ ] Different screen sizes tested
- [ ] Performance tested

---

## ✅ Deployment Preparation

### Documentation
- [ ] README.md updated with current info
- [ ] DEPLOYMENT.md reviewed and accurate
- [ ] API documentation complete
- [ ] User guides created (if needed)
- [ ] Admin guides created
- [ ] Troubleshooting guide available

### Monitoring & Logging
- [ ] Log aggregation set up
- [ ] Error tracking configured (Sentry, etc.)
- [ ] Performance monitoring set up
- [ ] Uptime monitoring configured
- [ ] Alert notifications configured
- [ ] Backup monitoring in place

### Backup & Recovery
- [ ] Database backup strategy implemented
- [ ] Backup restoration tested
- [ ] File storage backup configured
- [ ] Disaster recovery plan documented
- [ ] Regular backup schedule automated

### Performance
- [ ] Database indices optimized
- [ ] Query performance reviewed
- [ ] API response times acceptable
- [ ] File upload size limits set
- [ ] Caching strategy implemented (if needed)
- [ ] CDN configured for static assets (if needed)

---

## ✅ Pre-Launch

### Final Checks
- [ ] All tests passing
- [ ] No TODOs or FIXMEs in critical code
- [ ] Code reviewed by team
- [ ] Security audit completed
- [ ] Load testing completed
- [ ] Backup strategy tested
- [ ] Rollback plan documented

### Deployment Steps
- [ ] Server provisioned and configured
- [ ] Domain DNS configured
- [ ] SSL certificate active
- [ ] Environment variables set
- [ ] Database initialized
- [ ] Initial data seeded (if needed)
- [ ] Services started and healthy
- [ ] Health checks passing

### Post-Deployment
- [ ] Smoke tests completed
- [ ] API endpoints accessible
- [ ] Authentication working
- [ ] Database queries working
- [ ] Email sending working
- [ ] Reports generating correctly
- [ ] Monitoring active
- [ ] Logs flowing correctly

---

## ✅ App Store Submission

### Android (Google Play)
- [ ] App signed with production keystore
- [ ] Privacy policy URL ready
- [ ] App screenshots prepared
- [ ] App description written
- [ ] Target API level requirements met
- [ ] Google Play Console account set up
- [ ] App bundle (.aab) generated
- [ ] Release notes prepared

### iOS (App Store)
- [ ] App signed with distribution certificate
- [ ] Privacy policy URL ready
- [ ] App screenshots prepared
- [ ] App description written
- [ ] App Store Connect account set up
- [ ] App archived in Xcode
- [ ] TestFlight testing completed
- [ ] Release notes prepared

---

## 🔧 Post-Launch Monitoring

### First 24 Hours
- [ ] Monitor error rates
- [ ] Check API response times
- [ ] Review log files
- [ ] Monitor server resources
- [ ] Check user registration flow
- [ ] Verify email sending
- [ ] Check database performance
- [ ] Monitor authentication

### First Week
- [ ] Review user feedback
- [ ] Check crash reports
- [ ] Monitor server costs
- [ ] Review backup logs
- [ ] Check database growth
- [ ] Monitor API usage patterns
- [ ] Review security logs
- [ ] Plan updates/fixes

---

## 📝 Critical Environment Variables Reference

### Backend `.env`
```bash
# Database
DB_HOST=postgres
DB_PORT=5432
DB_NAME=mydb
DB_USER=myuser
DB_PASSWORD=<STRONG_PASSWORD>

# JWT
JWT_SECRET_KEY=<GENERATE_WITH: openssl rand -hex 32>
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=15
REFRESH_TOKEN_EXPIRE_DAYS=15

# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_EMAIL=<YOUR_EMAIL>
SMTP_PASSWORD=<APP_SPECIFIC_PASSWORD>

# Application
ENVIRONMENT=production
DEBUG=false
ALLOWED_ORIGINS=<YOUR_DOMAIN>

# Logging
LOG_LEVEL=INFO
```

---

## 🚨 Go/No-Go Decision

**DO NOT DEPLOY** if any of these are unchecked:
- [ ] All security checks passed
- [ ] JWT secret key is secure and unique
- [ ] Database password is strong
- [ ] CORS is properly configured (not `*`)
- [ ] HTTPS/SSL is configured
- [ ] Backups are configured and tested
- [ ] Monitoring is active
- [ ] Rollback plan is ready

---

**Deployment Approved By**: _______________
**Date**: _______________
**Version**: _______________
