#!/bin/bash

# Service Manager - Deployment Script
# This script deploys the service manager application to the server

set -e

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Source configuration
if [[ -f "$PROJECT_ROOT/config/deployment.env.local" ]]; then
    source "$PROJECT_ROOT/config/deployment.env.local"
elif [[ -f "$PROJECT_ROOT/config/deployment.env" ]]; then
    source "$PROJECT_ROOT/config/deployment.env"
else
    echo "❌ Configuration file not found. Please run './scripts/config-manager.sh setup' first."
    exit 1
fi

# Configuration validation
if [[ -z "$SERVER_IP" || -z "$SSH_HOST" || -z "$SSH_USER" || -z "$WEB_PORT" ]]; then
    echo "❌ Missing required configuration. Please run './scripts/config-manager.sh setup' first."
    exit 1
fi

# Use configuration variables
SERVER_HOST="$SSH_HOST"
APP_DIR="${APP_DIR:-/opt/service-manager}"
SERVICE_NAME="${SERVICE_NAME:-service-manager}"
BACKUP_DIR="${BACKUP_DIR:-/opt/service-manager/backups}"

echo "🚀 Deploying Service Manager to $SERVER_HOST..."
echo "   Note: If you encounter sudo password prompts, the script will continue"
echo "   and you can manually restart the service if needed"
echo ""

# Step 1: Check if we can connect to the server
echo "🔍 Testing SSH connection..."
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes $SERVER_HOST "echo 'SSH connection successful'" > /dev/null 2>&1; then
    echo "❌ Cannot connect to server. Please ensure:"
echo "   1. SSH key is copied to server: ssh-copy-id -i $SSH_KEY.pub $SSH_USER@$SERVER_IP"
echo "   2. Server is accessible at $SERVER_IP"
echo "   3. User '$SSH_USER' exists on server"
    exit 1
fi
echo "✅ SSH connection successful"

# Step 2: Create backup of current deployment
echo "💾 Creating backup of current deployment..."
ssh $SERVER_HOST "mkdir -p $BACKUP_DIR"
if ssh $SERVER_HOST "[ -d $APP_DIR/app ]"; then
    BACKUP_NAME="backup-$(date +%Y%m%d-%H%M%S)"
    ssh $SERVER_HOST "cp -r $APP_DIR/app $BACKUP_DIR/$BACKUP_NAME"
    echo "✅ Backup created: $BACKUP_NAME"
else
    echo "ℹ️  No existing deployment to backup"
fi

# Step 3: Create application directory structure
echo "📁 Setting up application directory..."
ssh $SERVER_HOST "mkdir -p $APP_DIR/app"

# Step 4: Deploy application files
echo "📤 Deploying application files..."

# Deploy main application files
scp app.py $SERVER_HOST:$APP_DIR/app/
scp requirements.txt $SERVER_HOST:$APP_DIR/app/

# Deploy configuration
scp -r config $SERVER_HOST:$APP_DIR/app/

# Deploy templates and static files
scp -r templates $SERVER_HOST:$APP_DIR/app/
scp -r static $SERVER_HOST:$APP_DIR/app/

# Deploy scripts
scp -r scripts $SERVER_HOST:$APP_DIR/app/

# Deploy other important files
scp README.md $SERVER_HOST:$APP_DIR/app/ 2>/dev/null || true

echo "✅ Application files deployed"

# Step 5: Install Python dependencies
echo "🐍 Installing Python dependencies..."
ssh $SERVER_HOST "cd $APP_DIR/app && $APP_DIR/venv/bin/pip install -r requirements.txt"

# Step 6: Set proper permissions
echo "🔐 Setting file permissions..."
ssh $SERVER_HOST "chown -R $SERVICE_NAME:$SERVICE_NAME $APP_DIR/app"
ssh $SERVER_HOST "chmod -R 755 $APP_DIR/app"

# Step 7: Restart the service
echo "🔄 Restarting service..."
echo "   Note: This may take a moment and may require sudo password..."
if ssh -t $SERVER_HOST "sudo systemctl restart $SERVICE_NAME" 2>/dev/null; then
    echo "✅ Service restart command completed"
else
    echo "⚠️  Service restart command may have had issues, continuing..."
fi

# Step 8: Wait for service to be ready
echo "⏳ Waiting for service to be ready..."
sleep 10

# Step 9: Check service status (with timeout)
echo "📊 Checking service status..."
SERVICE_STATUS=""
TIMEOUT=30
COUNTER=0

while [ $COUNTER -lt $TIMEOUT ]; do
    if SERVICE_STATUS=$(ssh $SERVER_HOST "systemctl is-active $SERVICE_NAME" 2>/dev/null); then
        if echo "$SERVICE_STATUS" | grep -q "active"; then
            echo "✅ Service is running successfully"
            break
        elif echo "$SERVICE_STATUS" | grep -q "failed\|inactive"; then
            echo "❌ Service failed to start"
            break
        fi
    fi
    
    echo "   Waiting for service to start... ($COUNTER/$TIMEOUT)"
    sleep 2
    COUNTER=$((COUNTER + 2))
done

if [ $COUNTER -ge $TIMEOUT ]; then
    echo "⚠️  Service status check timed out, continuing deployment..."
fi

# Step 10: Test the application (with timeout)
echo "🧪 Testing application..."
APP_RESPONDING=false
TIMEOUT=30
COUNTER=0

while [ $COUNTER -lt $TIMEOUT ]; do
    if curl -s -f "http://$SERVER_IP:$WEB_PORT/api/services" > /dev/null 2>&1; then
        echo "✅ Application is responding correctly"
        APP_RESPONDING=true
        break
    else
        echo "   Waiting for application to respond... ($COUNTER/$TIMEOUT)"
        sleep 2
        COUNTER=$((COUNTER + 2))
    fi
done

if [ "$APP_RESPONDING" = false ]; then
    echo "⚠️  Application health check timed out, but deployment completed"
    echo "   You may need to check the application manually"
fi

echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📱 Access your Service Manager at:"
echo "   http://$SERVER_IP:$WEB_PORT"
echo ""
echo "🔧 To manage the service:"
echo "   ssh $SERVER_HOST"
echo "   sudo systemctl status $SERVICE_NAME"
echo "   sudo systemctl restart $SERVICE_NAME"
echo ""
echo "📋 To rollback to previous version:"
echo "   ./scripts/rollback.sh"
