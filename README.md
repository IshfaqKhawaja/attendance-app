# 🎓 Attendance Management System

A full-stack attendance tracking application with a Flutter frontend and FastAPI backend, featuring role-based access control, real-time attendance marking, and comprehensive reporting.

![Version](https://img.shields.io/badge/version-1.0.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Flutter](https://img.shields.io/badge/Flutter-3.8.1+-02569B?logo=flutter)
![FastAPI](https://img.shields.io/badge/FastAPI-0.116.1+-009688?logo=fastapi)

---

## ✨ Features

### 🔐 Authentication & Authorization
- Email-based OTP authentication
- JWT token management with refresh tokens
- Role-based access control (Super Admin, HOD, Teacher, Student)
- Secure token storage

### 👥 User Management
- Faculty, Department, and Program hierarchy
- Teacher management with department assignment
- Student enrollment and tracking
- Bulk student import via Excel

### 📊 Attendance Tracking
- Real-time attendance marking
- Course-wise attendance records
- Date-based attendance history
- Bulk attendance operations
- Attendance notifications

### 📈 Reporting & Analytics
- Excel report generation
- PDF report generation
- Semester-wise reports
- Course-wise attendance summaries
- Student attendance statistics

### 🎨 Modern UI/UX
- Material Design interface
- Light/Dark theme support
- Responsive design
- Intuitive navigation
- Role-specific dashboards

---

## 🏗️ Architecture

### Backend (FastAPI + PostgreSQL)
```
backend/
├── app/
│   ├── api/v1/          # API endpoints
│   ├── core/            # Configuration & security
│   ├── db/              # Database models & CRUD
│   ├── middleware/      # Custom middleware
│   ├── schemas/         # Pydantic schemas
│   ├── services/        # Business logic
│   └── utils/           # Utility functions
├── logs/                # Application logs
├── reports/             # Generated reports
└── json_data/           # Seed data
```

### Frontend (Flutter)
```
app/
├── lib/app/
│   ├── config/          # Environment configuration
│   ├── core/            # Core utilities & services
│   ├── signin/          # Authentication
│   ├── dashboard/       # Role-based dashboards
│   ├── course/          # Course management
│   ├── student/         # Student features
│   └── semester/        # Semester management
```

---

## 🚀 Quick Start

### Prerequisites
- **Backend**: Python 3.9+, Docker (optional)
- **Frontend**: Flutter 3.8.1+
- **Database**: PostgreSQL 15+

### 1. Backend Setup

```bash
cd backend

# Copy environment file
cp .env.development .env

# Install dependencies
pip install -e .

# Start server
uvicorn app.main:app --reload
```

**Or using Docker:**
```bash
docker-compose up -d
```

### 2. Frontend Setup

```bash
cd app

# Install dependencies
flutter pub get

# Run app
flutter run
```

**Access Points:**
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs
- Health Check: http://localhost:8000/health

📖 **Detailed instructions**: [QUICK_START.md](QUICK_START.md)

---

## 🌐 Production Deployment

### Backend Deployment

```bash
cd backend

# Configure production environment
cp .env.example .env
# Edit .env with production values

# Deploy with Docker
./deploy.sh
```

### Frontend Build

```bash
cd app

# Android
./build-release.sh android

# iOS
./build-release.sh ios
```

📖 **Full deployment guide**: [DEPLOYMENT.md](DEPLOYMENT.md)
✅ **Pre-launch checklist**: [PRODUCTION_CHECKLIST.md](PRODUCTION_CHECKLIST.md)

---

## 🔒 Security Features

- ✅ JWT-based authentication
- ✅ Environment-based configuration
- ✅ Rate limiting middleware
- ✅ CORS protection
- ✅ Secure password hashing
- ✅ Request logging
- ✅ Input validation
- ✅ SQL injection prevention
- ✅ XSS protection

---

## 📊 Tech Stack

### Backend
- **Framework**: FastAPI 0.116.1+
- **Database**: PostgreSQL 15
- **ORM**: SQLAlchemy 2.0+
- **Cache**: Redis (optional)
- **Authentication**: JWT
- **Email**: SMTP (Gmail)
- **SMS**: Twilio (optional)
- **Reports**: openpyxl, fpdf
- **Server**: Uvicorn + Gunicorn

### Frontend
- **Framework**: Flutter 3.8.1+
- **State Management**: GetX 4.7.2
- **HTTP Client**: Dio 5.9.0
- **Storage**: flutter_secure_storage 9.2.4
- **Local DB**: sqflite
- **UI**: Material Design

### DevOps
- **Containerization**: Docker + Docker Compose
- **Reverse Proxy**: Nginx
- **SSL**: Let's Encrypt
- **CI/CD**: GitHub Actions (optional)
- **Monitoring**: Logs + Health checks

---

## 📝 API Endpoints

### Authentication
- `POST /authenticate/send_otp` - Send OTP to email
- `POST /authenticate/verify_otp` - Verify OTP and login
- `POST /authenticate/register_teacher` - Register new teacher

### Management
- Faculty, Department, Program, Semester CRUD operations
- Teacher and Student management
- Course management
- Enrollment operations

### Attendance
- `POST /attendance/add_attendence_bulk` - Bulk attendance marking
- `GET /attendance/*` - Attendance queries

### Reports
- `POST /reports/generate_course_report_xls` - Excel reports
- `POST /reports/generate_course_report_pdf` - PDF reports

📖 **Full API documentation**: http://localhost:8000/docs

---

## 🔧 Configuration

### Backend Environment Variables

```bash
# Database
DB_HOST=localhost
DB_PORT=5432
DB_NAME=mydb
DB_USER=myuser
DB_PASSWORD=secure_password

# JWT
JWT_SECRET_KEY=your-secret-key-here
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=15

# Email
SMTP_EMAIL=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# Application
ENVIRONMENT=production
DEBUG=false
ALLOWED_ORIGINS=https://yourdomain.com
```

### Frontend Configuration

Edit `lib/app/config/environment.dart`:

```dart
static const AppConfig production = AppConfig(
  apiBaseUrl: 'https://api.yourdomain.com',
  environment: Environment.production,
  enableDebugMode: false,
);
```

---

## 🧪 Testing

### Backend
```bash
cd backend
pytest
```

### Frontend
```bash
cd app
flutter test
```

### API Testing
Use the interactive API docs: http://localhost:8000/docs

---

## 📚 Documentation

- [Quick Start Guide](QUICK_START.md) - Get started in minutes
- [Deployment Guide](DEPLOYMENT.md) - Production deployment
- [Production Checklist](PRODUCTION_CHECKLIST.md) - Pre-launch checklist
- [Backend README](backend/README.md) - Backend documentation
- [Frontend README](app/README.md) - Frontend documentation

---

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

---

## 📄 License

This project is licensed under the MIT License.

---

## 🆘 Support

### Common Issues

**Port already in use:**
```bash
kill -9 $(lsof -ti:8000)
```

**Docker issues:**
```bash
docker-compose down -v
docker-compose up -d
```

**Database connection failed:**
```bash
docker-compose restart postgres
docker-compose logs postgres
```

### Getting Help

1. Check logs: `docker-compose logs -f`
2. Review health endpoint: http://localhost:8000/health
3. Check API docs: http://localhost:8000/docs
4. Review [QUICK_START.md](QUICK_START.md)

---

## 🙏 Acknowledgments

- FastAPI for the excellent Python framework
- Flutter for the cross-platform framework
- PostgreSQL for the robust database
- All open-source contributors

---

## 📞 Contact

For questions or support, please open an issue or contact the development team.

---

**Made with ❤️ for educational institutions**

---

## 🗺️ Roadmap

- [ ] Mobile app push notifications
- [ ] Advanced analytics dashboard
- [ ] QR code attendance marking
- [ ] Face recognition integration
- [ ] Multi-language support
- [ ] Offline mode support
- [ ] Parent portal
- [ ] SMS notifications
- [ ] Export to multiple formats
- [ ] Calendar integration

---

**Version**: 1.0.0
**Last Updated**: 2025
