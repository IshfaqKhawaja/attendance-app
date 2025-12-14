#!/bin/bash
# Fix permissions for Docker volumes on the server

echo "Fixing permissions for logs and reports directories..."

# Create directories if they don't exist
mkdir -p logs reports

# Set ownership to match Docker container user (UID 1000)
sudo chown -R 1000:1000 logs reports

# Set proper permissions
chmod -R 755 logs reports

echo "Permissions fixed successfully!"
echo "You can now restart your Docker containers."
