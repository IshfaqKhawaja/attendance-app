# Running the Backend

## ✅ Quick Start (Recommended)

```bash
cd backend
./start-dev.sh
```

This script will:
- Create virtual environment if needed
- Install all dependencies
- Start the development server with auto-reload

## 🔧 Manual Start

If you prefer to run manually:

```bash
cd backend

# Activate virtual environment
source .venv/bin/activate

# Unset DEBUG environment variable (important!)
unset DEBUG

# Start server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## 🌐 Access Points

Once running, you can access:

- **API**: http://localhost:8000
- **Interactive Docs**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **Health Check**: http://localhost:8000/health

## 🐛 Troubleshooting

### Issue: `DEBUG` validation error

If you see: `Input should be a valid boolean, unable to interpret input [type=bool_parsing, input_value='WARN']`

**Solution**: You have a `DEBUG=WARN` environment variable. Run:
```bash
unset DEBUG
```

### Issue: `ModuleNotFoundError: No module named 'pydantic_settings'`

**Solution**: Dependencies not installed. Run:
```bash
source .venv/bin/activate
pip install pydantic-settings python-dotenv
```

Or just run `./start-dev.sh` which handles this automatically.

### Issue: `ModuleNotFoundError: No module named 'psycopg'`

**Solution**: Install psycopg:
```bash
source .venv/bin/activate
pip install psycopg psycopg2-binary
```

### Issue: `Form data requires "python-multipart"`

**Solution**: Install python-multipart:
```bash
source .venv/bin/activate
pip install python-multipart
```

### Issue: Port 8000 already in use

**Solution**: Kill the process using port 8000:
```bash
lsof -ti:8000 | xargs kill -9
```

## 📦 Complete Dependency List

The backend requires these packages:

- fastapi
- uvicorn[standard]
- sqlalchemy
- psycopg (PostgreSQL driver v3)
- psycopg2-binary (PostgreSQL driver v2)
- pandas
- openpyxl
- pyjwt
- fpdf
- twilio
- pydantic
- pydantic-settings
- python-dotenv
- gunicorn
- python-multipart

All are installed automatically by `./start-dev.sh`.

## 🎯 Testing

Test if everything is working:

```bash
# Test app loads
source .venv/bin/activate
unset DEBUG
python -c "from app.main import app; print('✅ Success!')"

# Test health endpoint
curl http://localhost:8000/health
```

## 🚀 Production

For production deployment, see:
- [../DEPLOYMENT.md](../DEPLOYMENT.md)
- [../NEXT_STEPS.md](../NEXT_STEPS.md)
