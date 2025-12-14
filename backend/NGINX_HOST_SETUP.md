# Installing Nginx on Host Server (Optional)

Use this guide if you're deploying to a VPS/VM and want Nginx installed on the host OS instead of Docker.

## Prerequisites
- Ubuntu/Debian server
- Docker and Docker Compose installed
- Root or sudo access

## Step 1: Install Nginx on Host

```bash
# Update package list
sudo apt update

# Install Nginx
sudo apt install nginx -y

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Check status
sudo systemctl status nginx
```

## Step 2: Update docker-compose.yml

Remove the Nginx service and expose backend on localhost only:

```yaml
  backend:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: attendance-backend
    env_file:
      - .env
    environment:
      - DB_HOST=postgres
      - DB_PORT=5432
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    ports:
      - "127.0.0.1:8000:8000"  # Only accessible from localhost
    volumes:
      - ./logs:/app/logs
      - ./reports:/app/reports
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    networks:
      - attendance-network
    restart: unless-stopped
```

## Step 3: Create Nginx Site Configuration

```bash
sudo nano /etc/nginx/sites-available/attendance-app
```

Paste this configuration:

```nginx
# Attendance App Backend Configuration

upstream backend_server {
    server 127.0.0.1:8000;
}

server {
    listen 80;
    server_name your-domain.com www.your-domain.com;  # Change this!

    # Maximum upload size
    client_max_body_size 10M;

    # Logging
    access_log /var/log/nginx/attendance-access.log;
    error_log /var/log/nginx/attendance-error.log;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # API endpoints
    location / {
        proxy_pass http://backend_server;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;

        # WebSocket support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # Deny access to hidden files
    location ~ /\. {
        deny all;
    }
}
```

## Step 4: Enable the Site

```bash
# Create symbolic link
sudo ln -s /etc/nginx/sites-available/attendance-app /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

## Step 5: Configure Firewall

```bash
# Allow HTTP and HTTPS
sudo ufw allow 'Nginx Full'

# Check status
sudo ufw status
```

## Step 6: Setup SSL with Let's Encrypt (Production)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get SSL certificate (replace with your domain)
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# Auto-renewal test
sudo certbot renew --dry-run
```

## Step 7: Start Docker Services

```bash
cd /path/to/backend
docker compose up -d
```

## Verification

```bash
# Check Nginx status
sudo systemctl status nginx

# Check if backend is accessible
curl http://localhost:8000/health

# Check through Nginx
curl http://your-domain.com/health
```

## Useful Commands

```bash
# View Nginx logs
sudo tail -f /var/log/nginx/attendance-access.log
sudo tail -f /var/log/nginx/attendance-error.log

# Reload Nginx config
sudo nginx -t && sudo systemctl reload nginx

# Restart Nginx
sudo systemctl restart nginx

# Check what's using port 80
sudo lsof -i :80
```

## Troubleshooting

### Backend not accessible
```bash
# Check if backend is running
docker ps | grep backend

# Check backend logs
docker logs attendance-backend

# Test backend directly
curl http://127.0.0.1:8000/health
```

### Nginx errors
```bash
# Check configuration
sudo nginx -t

# View error log
sudo tail -n 50 /var/log/nginx/error.log
```

### Port 80 already in use
```bash
# Find what's using port 80
sudo lsof -i :80

# Stop the service
sudo systemctl stop <service-name>
```
